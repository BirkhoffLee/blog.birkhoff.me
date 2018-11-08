---
title: 第一次用 Docker 自架 v2ray + shadowsocks 翻牆伺服器就上手
tags:
permalink: use-docker-to-deploy-vmess-and-ss-using-docker
id: 5acda53481f41f000158dc07
updated: '2017-11-12 16:16:14'
date: 2017-11-10 19:12:24
---

## How It Works
我們接下來將使用 v2ray 架設使用 VMess 與 ShadowSocks 協議翻墻的伺服器。我們主要將使用 VMess 進行翻墻，ShadowSocks 僅作為備用。

VMess 部分我們將將流量偽裝成正常的 **https** 流量並使用 **WebSocket** 進行與 `nginx-proxy` 的通訊，由 `nginx-proxy` 進行 reverse proxying，SSL 憑證由 `jrcs/letsencrypt-nginx-proxy-companion` 自動向 [Let's Encrypt](https://letsencrypt.org/) 申請並套用。

ShadowSocks 部分則使用**原版協定**，且**不使用混淆參數**。（v2ray 目前尚未實作這些部分，希望未來可以看到）

> Update: 目前還是推薦使用純 shadowsocks，使用 `chacha20-ietf-poly1305`（或 `xchacha20-ietf-poly1305`）、`origin` 協定、混淆使用 `simple_obfs_http`


## 本文示範環境

使用系統為 CentOS 7，採用 Google Cloud Platform 日本機房。
我將假設 v2ray 資料夾位於 `~/v2ray`，以下的檔案都將放置於此。

`$ docker version`:
```
Client:
... (略)
Server:
 Version:      17.09.0-ce
 API version:  1.32 (minimum version 1.12)
 Go version:   go1.8.3
 Git commit:   afdb6d4
 Built:        Tue Sep 26 22:42:49 2017
 OS/Arch:      linux/amd64
 Experimental: false
```

## 前備條件

Docker:
```
$ sudo yum install -y yum-utils device-mapper-persistent-data lvm2
$ sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
$ sudo yum install -y docker-ce
$ sudo systemctl start docker
$ sudo usermod -aG docker $USER
$ docker version
```

docker-compose:
```
$ sudo curl -L https://github.com/docker/compose/releases/download/1.17.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
$ sudo chmod +x /usr/local/bin/docker-compose
$ docker-compose --version
```

下載/建立所需資料夾與檔案：
```
$ mkdir -p ~/v2ray
$ cd ~/v2ray
$ curl -L https://raw.githubusercontent.com/jwilder/nginx-proxy/master/nginx.tmpl > nginx.tmpl
$ mkdir v2ray_logs
$ mkdir -p ~/v2ray/nginx/vhost.d/
```

另外，請將防火墻設定為允許下列規則的 ingress traffic（tcp/udp 都要）：

* nginx: 80, 443
* ShadowSocks: 19477, 19478

## 撰寫 v2ray 設定檔

`config.json`:

* 將 `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` 換為一個隨機的 UUID，你可以在這裡產生一個：https://www.uuidgenerator.net/
* 將 `[SOME_SECURE_PASSWORD]` 換為 ShadowSocks 的連線密碼，盡量超過 16 個字元。

```json
{
  "log": {
    "access": "/var/log/v2ray/access.log",
    "error": "/var/log/v2ray/error.log",
    "loglevel": "warning"
  },
  "inbound": {
    "port": 19487,
    "protocol": "vmess",
    "settings": {
      "clients": [{
        "id": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
        "level": 1,
        "alterId": 9487
      }]
    },
    "streamSettings": {
      "network": "ws",
      "wsSettings": {
        "connectionReuse": false,
        "path": "/"
      }
    },
    "detour": {
      "to": "vmess-detour"
    }
  },
  "outbound": {
    "protocol": "freedom",
    "settings": {}
  },
  "inboundDetour": [{
      "protocol": "vmess",
      "port": "45000-45999",
      "tag": "vmess-detour",
      "settings": {},
      "allocate": {
        "strategy": "random",
        "concurrency": 5,
        "refresh": 5
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "connectionReuse": false,
          "path": "/"
        }
      }
    },
    {
      "protocol": "shadowsocks",
      "port": 19477,
      "settings": {
        "method": "aes-256-cfb",
        "password": "[SOME_SECURE_PASSWORD]",
        "udp": true,
        "level": 1
      }
    },
    {
      "protocol": "shadowsocks",
      "port": 19478,
      "settings": {
        "method": "aes-256-cfb",
        "password": "[SOME_SECURE_PASSWORD]",
        "udp": true,
        "level": 1
      }
    }
  ],
  "outboundDetour": [{
    "protocol": "blackhole",
    "settings": {},
    "tag": "blocked"
  }],
  "routing": {
    "strategy": "rules",
    "settings": {
      "rules": [{
        "type": "field",
        "ip": [
          "0.0.0.0/8",
          "10.0.0.0/8",
          "100.64.0.0/10",
          "127.0.0.0/8",
          "169.254.0.0/16",
          "172.16.0.0/12",
          "192.0.0.0/24",
          "192.0.2.0/24",
          "192.168.0.0/16",
          "198.18.0.0/15",
          "198.51.100.0/24",
          "203.0.113.0/24",
          "::1/128",
          "fc00::/7",
          "fe80::/10"
        ],
        "outboundTag": "blocked"
      }]
    }
  }
}
```

## 設定 docker-compose 以快速部署

`docker-compose.yml`:

* 將 `v2ray.example.com` 換為你的網域名稱
* 將 `michael@example.com` 換為你的 email，接收憑證過期提醒用，不需認證

```yaml
version: '3'

services:
  v2ray:
    container_name: v2ray
    image: v2ray/official
    restart: unless-stopped
    command: v2ray -config=/etc/v2ray/config.json
    expose:
      - "19487" # v2ray port
    ports:
      - "19477-19478:19477-19478" # ShadowSocks
      - "19487:19487" # v2ray port
      - "19477-19478:19477-19478/udp" # ShadowSocks
      - "19487:19487/udp" # v2ray port
    volumes:
      - ./v2ray_logs:/var/log/v2ray/
      - ./config.json:/etc/v2ray/config.json:ro
    environment:
      - "VIRTUAL_HOST=v2ray.example.com"
      - "VIRTUAL_PORT=19487"
      - "LETSENCRYPT_HOST=v2ray.example.com"
      - "LETSENCRYPT_EMAIL=michael@example.com"

  nginx:
    image: nginx
    labels:
      com.github.jrcs.letsencrypt_nginx_proxy_companion.nginx_proxy: "true"
    container_name: nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/conf.d:/etc/nginx/conf.d
      - ./nginx/vhost.d:/etc/nginx/vhost.d
      - ./nginx/html:/usr/share/nginx/html
      - ./nginx/certs:/etc/nginx/certs:ro

  nginx-gen:
    image: jwilder/docker-gen
    command: -notify-sighup nginx -watch -wait 5s:30s /etc/docker-gen/templates/nginx.tmpl /etc/nginx/conf.d/default.conf
    container_name: nginx-gen
    restart: unless-stopped
    volumes:
      - ./nginx/conf.d:/etc/nginx/conf.d
      - ./nginx/vhost.d:/etc/nginx/vhost.d
      - ./nginx/html:/usr/share/nginx/html
      - ./nginx/certs:/etc/nginx/certs:ro
      - /var/run/docker.sock:/tmp/docker.sock:ro
      - ./nginx.tmpl:/etc/docker-gen/templates/nginx.tmpl:ro

  nginx-letsencrypt:
    image: jrcs/letsencrypt-nginx-proxy-companion
    container_name: nginx-letsencrypt
    restart: unless-stopped
    volumes:
      - ./nginx/conf.d:/etc/nginx/conf.d
      - ./nginx/vhost.d:/etc/nginx/vhost.d
      - ./nginx/html:/usr/share/nginx/html
      - ./nginx/certs:/etc/nginx/certs:rw
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      NGINX_DOCKER_GEN_CONTAINER: "nginx-gen"
      NGINX_PROXY_CONTAINER: "nginx"
```

## 新增 nginx virtual host 設定檔
在 `~/v2ray/nginx/vhost.d/` 下建立名為 `你的網域名稱_location` 的檔案

```
proxy_redirect off;
proxy_http_version 1.1;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";
proxy_set_header Host $http_host;
if ($http_upgrade = "websocket" ) {
    proxy_pass http://v2ray:19487;
}
```


## 部署

```
$ docker-compose up -d
$ docker-compose logs -f
```

這會啟動 v2ray 並開始輸出日誌（按 Ctrl+C 退出）。

## 設定 v2ray client

* 到 [https://www.v2ray.com/chapter_01/3rd_party.html](https://www.v2ray.com/chapter_01/3rd_party.html) 尋找一個喜歡的 client，下載並安裝
* 進入 server 設定畫面，填寫你伺服器的 IP address，port 為 `443`
* User ID 或 UUID 請填寫你修改的 UUID
* alterId 請修改為 `9487`
* 加密方式選擇 `aes-128-cfb`
* 傳輸協定使用 `WebSocket`，path 指定為 `/`

## 設定 ShadowSocks client

* 在 Google 尋找一個喜歡的 ShadowSocks client，下載並安裝
* 進入 server 設定畫面，填寫你伺服器的 IP address，port 為 `19477` 或 `19478`，隨便挑一個
* Password 填寫你指定的密碼
* 加密方式選擇 `aes-256-cfb`
* 傳輸協定與混淆（Protocol 與 Obfs） 選擇 `origin` 與 `plain`，兩個 Param 都不填
* UDP 可開啟

## 結語

這樣應該就沒問題了，至於 v2ray 那邊有自動切換 port 的部分我還沒測試，以上設定檔是使用 https://htfy96.github.io/v2ray-config-gen 產生的設定檔進行修改的，應該沒什麼大問題，還請協助測試。
