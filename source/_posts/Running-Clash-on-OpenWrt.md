---
title: Running Clash on OpenWrt
categories:
  - null
tags:
  - null
comments: true
toc: false
date: 2019-01-19 02:49:55
---

As you would have been aware of that I live in China where internet is under strict censorship. I’ve been discovering ways to access the blocked internet resources.
<!-- more -->

So recently I switched to a x86 mini computer which runs Proxmox VE. On PVE there’s OpenWrt and iKuai(I’m gonna replace this sneaky stuff). I’m not covering these stuff in this blog post, instead I’m writing down how I deployed a ShadowSocks client implementation that routes traffic intelligently on my OpenWrt.

We are gonna use Clash, you must have be aware of it because it’s in the title. Clash is a new software that is nearly the same to [Surge][1]. They both support “rules” mode which routes internet traffic depends on your rules. You can choose `google.com` to go through `proxy1`, `baidu.com` to `DIRECT`, where `DIRECT` means “don’t proxy”, etc. It’s so convenient that you don’t have to use GFWList anymore, and they are more precise and customizable.

Clash has a redir mode which can transparent proxy the traffic sent to `redir-port`. These are what we are going to do:

1. Download Clash to OpenWrt
2. Write some configurations
3. Configure OpenWrt
4. Route the traffic to Clash
5. Run Clash
5. Profit!

# Download Clash
It’s quite simple.

```bash
$ mkdir /etc/clash
$ cd /etc/clash
$ wget https://github.com/Dreamacro/clash/releases/download/v0.10.2/clash-linux.gz
$ gzip -d clash-linux.gz
$ chmod +x clash-linux
$ mv clash-linux clash
```

# Write Clash Configuration
It’s the most complicated step in this process. It depends on whether your ShadowSocks service provider provides a managed clash configuration. If you don’t, check these out:
* [https://raw.githubusercontent.com/lhie1/Rules/master/Clash/General\_dns.yml][2]
* [https://raw.githubusercontent.com/lhie1/Rules/master/Clash/Rule.yml][3]
You’ll still have to manually write the `Proxy` section. Ultimately, your Clash config **must** at least have these lines:

```yaml
port: 8888
socks-port: 8889
redir-port: 8887
allow-lan: true
mode: Rule
log-level: info
external-controller: 0.0.0.0:6170
dns:
  enable: true
  listen: 0.0.0.0:53
  enhanced-mode: redir-host
  nameserver:
    - 119.29.29.29
    - 223.5.5.5
  fallback:
    - 114.114.114.114
    - 8.8.8.8
Proxy:
...
```

Let’s tear it down. `8887` is the redir port,`external-controller` is for the API that we’re gonna use later to control Clash. We will use the `dns` provided by Clash to resolve all the domains. Notice that the port in `dns` is `53`, we’re going to talk about this in the next section.

# Configure OpenWrt
We’re going to change the port of OpenWrt DNS server to something else than 53, or it’ll conflict with Clash’s one.

Open up `[https://luci.openwrt/cgi-bin/luci/admin/network/dhcp]`, go to `Advanced Settings`, find `DNS server port` and change it to something else, like for example `5555`. Hit `Save & Apply` and done.

# Route the traffic to Clash
It’s fairly simple, just run the following two commands to configure *iptables*. Aware of that you need to change `YOUR_SSH_PORT`. `8887` is the redir port we previously configured.

```bash
$ iptables -t nat -A PREROUTING -p tcp --dport YOUR_SSH_PORT -j ACCEPT
$ iptables -t nat -A PREROUTING -p tcp -j REDIRECT --to-ports 8887
```

# Run Clash
Congratulation to your last step. Run the following to launch Clash.

```bash
$ cd /etc/clash
$ ./clash -d .
```

You can open your browser (make sure to disable proxies on your computer) and open `https://www.google.com` and see if it works! If it does, `Ctrl+C` to terminate Clash, and run the following to keep Clash running in background.

```bash
$ ./clash -d . &
```

# Control Clash
Remember the `external-controller`? We’re gonna make use of it… right now.
There’s a fantastic web interface that does exactly the work: [http://clash.razord.top/][4]. Use your OpenWrt IP address, and the `external-controller` port to authenticate. Be aware that it’s in Chinese.

[1]:	https://www.nssurge.com
[2]:	https://raw.githubusercontent.com/lhie1/Rules/master/Clash/General_dns.yml
[3]:	https://raw.githubusercontent.com/lhie1/Rules/master/Clash/Rule.yml
[4]:	http://clash.razord.top/