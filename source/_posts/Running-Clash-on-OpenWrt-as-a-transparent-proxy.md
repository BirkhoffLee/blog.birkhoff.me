---
title: Running Clash on OpenWrt as a transparent proxy
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

So recently I switched to a x86 mini computer that runs Proxmox VE, which has an OpenWRT VM running as a router. In this blog post, I'm using [Clash][1], a new software that is quite the same to [Surge][2]. They both support "rules" mode that routes internet traffic on your will. It’s so convenient that you don’t have to use *gfwlist* anymore, and they are more precise and customizable, like you can route Google to a Hong Kong proxy, YouTube to United States, Netflix to Japan and so forth. Clash also has a *redir* mode which can be used with *iptables* to redirect the TCP packets. We're also gonna utilize [Unbound][3] and [DNSCrypt-proxy][4] to solve the DNS pollution issue.

# Download the tools
```bash
$ mkdir /etc/clash
$ cd /etc/clash
$ wget https://github.com/Dreamacro/clash/releases/download/v0.13.0/clash-linux-amd64.tar.gz
$ tar -xzvf clash-linux-amd64.tar.gz
$ mv clash-linux-amd64 clash
```

```bash
$ mkdir /etc/unbound
$ opkg update && opkg install unbound
```

Follow this guide to install DNSCrypt-proxy: [https://github.com/jedisct1/dnscrypt-proxy/wiki/Installation-on-OpenWRT][5]

# Make them into services
Put the following script to `/etc/init.d/clash`:

```bash
#!/bin/sh /etc/rc.common

START=90

USE_PROCD=1

start_service() {
        procd_open_instance
        procd_set_param command /etc/clash/clash -d /etc/clash
        procd_set_param respawn 300 0 5 # threshold, timeout, retry
        procd_set_param file /etc/clash/config.yml
        procd_set_param stdout 1
        procd_set_param stderr 1
        procd_set_param pidfile /var/run/clash.pid
        procd_close_instance
}
```

Then run the following to make it executable:

```bash
$ chmod +x /etc/init.d/clash
```

This init.d script also immediately restarts clash when it exits for whatever reason. If it crashes 5 times in 5 minutes, it won’t be restarted anymore.

The logs are in `/var/log/messages`.

# Write Clash Configuration
I'm not covering how to write Clash configuration in this blog post, but these options must be set as follows:

```yaml
redir-port: 9090
allow-lan: true
external-controller: 0.0.0.0:6170
dns:
  enable: true
  ipv6: false
  listen: 0.0.0.0:53
  enhanced-mode: redir-host
  nameserver:
    - 127.0.0.1:5353
```

Let’s tear it down. `9090` is the redir port, `allow-lan` allows other devices in LAN to access the proxy and `external-controller` is the API that we’re gonna use later to control Clash.

Clash will now forward DNS requests from `:53` to *unbound* (`:5353`), which forwards DNS requests to *DNSCrypt-proxy* (`:5678`). *DNSCrypt-proxy* will then securely get the correct DNS responses using [DoH][6].

# Configure dnsmasq
```bash
# Disable dnsmasq DNS server
$ uci set 'dhcp.@dnsmasq[0].port=0'

# Configure dnsmasq to send a DNS Server DHCP option with its LAN IP
# since it does not do this by default when port is configured.
$ lan_address=$(uci get network.lan.ipaddr)
$ uci add_list "dhcp.lan.dhcp_option=option:dns-server,$lan_address"

$ uci commit
```

# Configure DNSCrypt-proxy
Use the example config with these options changed:

```bash
server_names = ['cloudflare', 'google']
listen_addresses = ['0.0.0.0:5678']
fallback_resolver = '119.29.29.29:53'
ignore_system_dns = true
forwarding_rules = 'forwarding-rules.txt'
```

# Configure Unbound
First download *named.cache* from InterNIC:

```bash
$ wget ftp://FTP.INTERNIC.NET/domain/named.cache -O/etc/unbound/root.hints
```

Then enable manual config so we can configure *Unbound* directly using it’s config file:

```bash
$ uci set 'unbound.@unbound[0].manual_conf=1'
```

To make China domains solve through `119.29.29.29` instead of foreign *DNSCrypt-proxy*, we’re using [https://github.com/felixonmars/dnsmasq-china-list][7].

```bash
$ cd
$ git clone https://github.com/felixonmars/dnsmasq-china-list.git
$ cd dnsmasq-china-list
$ make SERVER=119.29.29.29 unbound
$ mkdir /etc/unbound/unbound.conf.d
$ cp accelerated-domains.china.unbound.conf /etc/unbound/unbound.conf.d
```

Finally, this is the config I’m currently using:

```yaml
include: "/etc/unbound/unbound.conf.d/accelerated-domains.china.unbound.conf"

server:
	verbosity: 1
	directory: "/etc/unbound"
	num-threads: 2
	msg-cache-slabs: 1
	rrset-cache-slabs: 1
	infra-cache-slabs: 1
	key-cache-slabs: 1
	interface: 127.0.0.1
	access-control: 127.0.0.0/8 allow
	outgoing-num-tcp: 256
	incoming-num-tcp: 1024
	outgoing-port-permit: "10240-65335"
	outgoing-range: 60
	num-queries-per-thread: 30
	msg-buffer-size: 8192
	infra-cache-numhosts: 200
	key-cache-size: 100k
	neg-cache-size: 10k
	target-fetch-policy: "2 1 0 0 0 0"
	harden-large-queries: yes
	harden-short-bufsize: yes
	port: 5353
	so-rcvbuf: 4m
	so-sndbuf: 4m
	so-reuseport: yes
	msg-cache-size: 64m
	rrset-cache-size: 128m
	cache-max-ttl: 3600
	do-ip4: yes
	do-ip6: yes
	do-udp: yes
	do-tcp: yes
	tcp-upstream: no
	use-syslog: yes
	log-queries: no
	root-hints: "/etc/unbound/root.hints"
	hide-identity: yes
	hide-version: yes
	identity: ""
	version: ""
	harden-glue: yes
	private-address: 10.0.0.0/8
	private-address: 172.16.0.0/12
	private-address: 192.168.0.0/16
	private-address: 169.254.0.0/16
	private-address: fd00::/8
	private-address: fe80::/10
	private-address: ::ffff:0:0/96
	unwanted-reply-threshold: 10000000
	do-not-query-localhost: no
	prefetch: yes
	minimal-responses: no
	module-config: "iterator"
forward-zone:
    name: "."
    forward-addr: 127.0.0.1@5678
```

# Launch the services
Run the following to make *Clash*, *DNScrypt-proxy* and *Unbound* launch at system startup:

```bash
$ service clash enable
$ service dnscrypt-proxy enable
$ service unbound enable
```

Apply the changes:

```bash
$ service dnscrypt-proxy restart
$ service unbound restart
$ service clash restart
```

# Redirect the traffic to Clash
Go to `https://ROUTER_IP/cgi-bin/luci/admin/network/firewall/custom`, append the following to the end of rules. **Be aware that you need to change `YOUR_SSH_PORT`.**

```bash
iptables -t nat -N clash_lan
iptables -t nat -A clash_lan -d 0.0.0.0/8 -j RETURN
iptables -t nat -A clash_lan -d 10.0.0.0/8 -j RETURN
iptables -t nat -A clash_lan -d 127.0.0.0/8 -j RETURN
iptables -t nat -A clash_lan -d 169.254.0.0/16 -j RETURN
iptables -t nat -A clash_lan -d 172.16.0.0/12 -j RETURN
iptables -t nat -A clash_lan -d 192.168.0.0/16 -j RETURN
iptables -t nat -A clash_lan -d 224.0.0.0/4 -j RETURN
iptables -t nat -A clash_lan -d 240.0.0.0/4 -j RETURN

# Disable the proxy for 10.0.0.123
# iptables -t nat -A clash_lan -s 10.0.0.123 -j RETURN

iptables -t nat -A clash_lan -p tcp --dport YOUR_SSH_PORT -j ACCEPT
iptables -t nat -A clash_lan -p tcp --dport 80 -j REDIRECT --to-ports 9090
iptables -t nat -A clash_lan -p tcp --dport 443 -j REDIRECT --to-ports 9090
iptables -t nat -A clash_lan -p tcp --dport 53 -j REDIRECT --to-ports 53

iptables -t nat -A PREROUTING -p tcp -j clash_lan

# Chromecast
iptables -t nat -A PREROUTING -s IP_CIDR_OF_CHROMECAST_IF_YOU_HAVE_ANY -p udp --dport 53 -j REDIRECT --to-ports 53
iptables -t nat -A PREROUTING -s IP_CIDR_OF_CHROMECAST_IF_YOU_HAVE_ANY -p tcp --dport 53 -j REDIRECT --to-ports 53
```

You can now open your browser now and go to `https://ipinfo.io` to see if it works!

# Control Clash
Remember `external-controller`? We’re gonna make use of it… right now.

There’s a fantastic web interface that does exactly the work: [http://clash.razord.top/][8]. Use your OpenWrt IP address, and port `6170`.

Be ware that Clash does *not* remember your choices of servers between restarts.

# Check the logs

```bash
$ logread -e clash -f
```

# Last words
I’m also using WireGuard to connect back to my home network when I’m not in house. If you want to know further more how to configure WireGuard to work with this approach (Clash + Unbound), comment down below.

# Resources
- [https://github.com/Dreamacro/clash][9]
- [https://blog.phoenixlzx.com/2016/04/27/better-dns-with-unbound/][10]
- [https://github.com/SukkaW/Koolshare-Clash][11]
- [https://openwrt.org/docs/guide-user/services/dns/unbound][12]

[1]:	https://github.com/Dreamacro/clash
[2]:	https://www.nssurge.com
[3]:	https://www.nlnetlabs.nl/projects/unbound
[4]:	https://github.com/jedisct1/dnscrypt-proxy
[5]:	https://github.com/jedisct1/dnscrypt-proxy/wiki/Installation-on-OpenWRT
[6]:	https://en.wikipedia.org/wiki/DNS_over_HTTPS
[7]:	https://github.com/felixonmars/dnsmasq-china-list.git
[8]:	http://clash.razord.top/
[9]:	https://github.com/Dreamacro/clash
[10]:	https://blog.phoenixlzx.com/2016/04/27/better-dns-with-unbound/
[11]:	https://github.com/SukkaW/Koolshare-Clash
[12]:	https://openwrt.org/docs/guide-user/services/dns/unbound
