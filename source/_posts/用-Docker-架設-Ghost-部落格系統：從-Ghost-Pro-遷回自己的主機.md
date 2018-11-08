---
title: 用 Docker 架設 Ghost 部落格系統：從 Ghost(Pro) 遷回自己的主機
tags:
permalink: migrate-from-ghost-pro-to-self-hosted
id: 5acda53481f41f000158dc09
updated: '2018-08-22 15:07:24'
date: 2018-03-13 13:21:54
---

前幾天 Ghost(Pro) 又開始催繳了，付款畫面上沒寫多少錢，發了封郵件問了一下結賬金額是多少。不問不知道，一問不得了，一年居然要 $96！當下看到這個數字我嚇到吃手手，想了一下還是遷回自己的主機比較實在，便宜又好管理。下面將記錄我遷回來的過程。

## 拿回部落格檔案
1. 首先，進入舊的 Ghost 後台，選擇左側的 Labs，接著按下 Export your content 旁的按鈕，即可取回部落格的所有檔案（除了媒體、主題檔案）。
2. 點選左側的 Design，然後將你要保留的主題下載回來。
3. 寫信至 Ghost(Pro) 客服中心，要求取回 image files。客服會打包成 .zip 丟到 Dropbox 然後給你連結。（先不用下載回來）

## 前言
以下將使用 [jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy) 與 [JrCs/docker-letsencrypt-nginx-proxy-companion](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion) 來自動設定 nginx 反向代理伺服器與向 letsencrypt 請求免費 SSL 證書並自動套用。

當然並不會這麼麻煩，我用了 [evertramos/docker-compose-letsencrypt-nginx-proxy-companion](https://github.com/evertramos/docker-compose-letsencrypt-nginx-proxy-companion) 來自動設定 nginx-proxy 與 docker-letsencrypt-nginx-proxy-companion，所以一切都將變得很簡單（根本是繞口令）。

> 2018/8/22 更新：強烈建議使用 [Traefik](https://traefik.io) 而不是以上的套件

順帶一提，我的伺服器環境是 CentOS 7，Docker Server 版本為 `17.12.1-ce`。

## 事前準備

伺服器要有下列東西：
1. git
2. wget
3. unzip

與 docker 跟 docker-compose，用下面指令安裝：
```
$ sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2
$ sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
$ sudo yum install docker-ce
$ sudo systemctl start docker
$ sudo curl -L https://github.com/docker/compose/releases/download/1.19.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
$ sudo chmod +x /usr/local/bin/docker-compose
```

首先，`ssh` 進你的伺服器，然後跑下面指令：
```
$ git clone https://github.com/evertramos/docker-compose-letsencrypt-nginx-proxy-companion
$ cd docker-compose-letsencrypt-nginx-proxy-companion
$ cp .env.sample .env
$ chmod +x start.sh
```

接著根據需求修改 `.env`，我個人修改了 `NGINX_FILES_PATH` 以及將最下方這幾行 uncomment：
```
#NGINX_WEB_LOG_MAX_SIZE=4m
#NGINX_WEB_LOG_MAX_FILE=10

#NGINX_GEN_LOG_MAX_SIZE=2m
#NGINX_GEN_LOG_MAX_FILE=10

#NGINX_LETSENCRYPT_LOG_MAX_SIZE=2m
#NGINX_LETSENCRYPT_LOG_MAX_FILE=10
```

修改完畢之後執行下列指令即可啟動 nginx：
```
$ ./start.sh
```

## 設定 Ghost

接著，在別的地方建立一個 `docker-compose.yml`：

```yaml
version: '3.1'

services:

  ghost:
    image: ghost:alpine
    restart: unless-stopped
    volumes:
      - ${GHOST_IMAGES_PATH}:/var/lib/ghost/content/images
    environment:
      # see https://docs.ghost.org/docs/config#section-running-ghost-with-config-env-variables
      VIRTUAL_HOST: ${DOMAINS}
      LETSENCRYPT_HOST: ${DOMAINS}
      LETSENCRYPT_EMAIL: ${SSL_EMAIL}
      database__client: mysql
      database__connection__host: db
      database__connection__user: ${MYSQL_USER}
      database__connection__password: ${MYSQL_ROOT_PASSWORD}
      database__connection__database: ${MYSQL_DATABASE}
      mail__transport: SMTP
      mail__options__service: Mailgun
      mail__options__auth__user: ${MAILGUN_USER}
      mail__options__auth__pass: ${MAILGUN_PASS}
      url: ${PUBLIC_URL}

  db:
    image: mysql:5.7
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}

networks:
    default:
       external:
         name: ${NETWORK}
```

以及一個 `.env` 檔案：

```
DOMAINS=[這裡填入域名，如 blog.birkhoff.me]
SSL_EMAIL=[這裡填入你的 email，letsencrypt 通知用，不會進行驗證]

NETWORK=webproxy
GHOST_IMAGES_PATH=./ghost_images

MYSQL_USER=root
MYSQL_ROOT_PASSWORD=[這裡填入一個強隨機密碼]
MYSQL_DATABASE=ghost

PUBLIC_URL=[網址，如 https://blog.birkhoff.me]

MAILGUN_USER=[這裡填入 Mailgun SMTP 賬號]
MAILGUN_PASS=[這裡填入 Mailgun SMTP 密碼]
```

接著打開 Ghost(Pro) 客服給的照片檔案壓縮檔 Dropbox 網址，在「直接下載」上按下右鍵，然後複製連結網址。

```
$ wget -O img.zip [在這裡貼上網址]
$ unzip img.zip
$ rm img.zip
$ mv images/ ghost_images/
```

這樣媒體檔案遷移就完成了！接著就可以啟動 Ghost 了：
```
$ docker-compose up
```

剛啟動會噴出一大堆超級多錯誤，不過都不用管它，理論上不會有問題。接著進入後台（[https://example.com/ghost](https://example.com/ghost) ）依照指示設定部落格。

## 匯入設定與主題、後續處理
這個其實也沒什麼好說的，原來匯出的地方都有匯入的選項，直接匯入即可。另外要移除一個多出來的預設使用者，然後 Tags 也會多出一個。手動移除即可。
