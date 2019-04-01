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

So recently I switched to a x86 mini computer that runs Proxmox VE, which has an OpenWRT VM running as a router. In this blog post, I'm using [Clash][1], a new software that is quite the same to [Surge][3]. They both support "rules" mode that routes internet traffic on your will. It’s so convenient that you don’t have to use gfwlist anymore, and they are more precise and customizable, like you can route Google to a Hong Kong proxy, YouTube to United States, Netflix to Japan and so forth. Clash also has a *redir* mode which can be used with *iptables* to redirect the TCP packets. We're also gonna utilize [Overture][8] which solves the DNS pollution issue.

# Download the tools
```bash
$ mkdir /etc/clash
$ cd /etc/clash
$ wget https://github.com/Dreamacro/clash/releases/download/v0.13.0/clash-linux-amd64.tar.gz
$ tar -xzvf clash-linux-amd64.tar.gz
$ mv clash-linux-amd64 clash
```

```bash
$ mkdir /etc/overture
$ cd /etc/overture
$ wget https://github.com/shawn1m/overture/releases/download/v1.5-rc8/overture-linux-amd64.zip
$ unzip overture-linux-amd64.zip
$ mv overture-linux-amd64 overture
```

# Make them into services
Put the following script to `/etc/init.d/clash`:

```bash
#!/bin/sh /etc/rc.common

START=90

USE_PROCD=1

start_service() {
        procd_open_instance
        procd_set_param command /etc/clash/clash -d /etc/clash
        procd_set_param respawn
        procd_set_param stdout 1
        procd_set_param stderr 1
        procd_close_instance
}
```

... and the following to `/etc/init.d/overture`:

```bash
#!/bin/sh /etc/rc.common

START=90

USE_PROCD=1

start_service() {
        procd_open_instance
        procd_set_param command /etc/overture/overture -c /etc/overture/config.json
        procd_set_param respawn
        procd_set_param stdout 1
        procd_set_param stderr 1
        procd_close_instance
}
```

Then run the following to make them executable:

```bash
$ chmod +x /etc/init.d/clash
$ chmod +x /etc/init.d/overture
```

# Write Clash Configuration
I'm not covering how to write Clash configuration in this blog post, but these options must be set as follows:

```yaml
redir-port: 9090
allow-lan: true
external-controller: 0.0.0.0:6170
dns:
  enable: true
  ipv6: false
  listen: 0.0.0.0:5353
  enhanced-mode: redir-host
  nameserver:
    - 127.0.0.1:5555
  fallback:
```

Let’s tear it down. `9090` is the redir port, `allow-lan` allows other devices in LAN to access the proxy and `external-controller` is the API that we’re gonna use later to control Clash.

We will set up `dnsmasq` on OpenWRT to forward DNS requests to Clash, on `127.0.0.1:5353`, and Clash will resolve domain names through `127.0.0.1:5555`, which is Overture that we will set up later.

# Configure dnsmasq
Go to `https://ROUTER_IP/cgi-bin/luci/admin/network/dhcp`.

- General Settings
  - DNS forwardings: `127.0.0.1#5353`
- Resolv and Hosts Files
  - Check `Ignore resolve file`
- Advanced Settings
  - Check `No negative cache`
  - DNS server port: `53`
  - Size of DNS query cache: to a reasonable size that you desire

# Configure Overture
```bash
$ cd /etc/overture
$ vim config.json
```

I personally use the following configuration, and you should definitely modify it depending on your network environment.

```json
{
  "BindAddress": ":5555",
  "PrimaryDNS": [
    {
      "Name": "DNSPod-53UDP",
      "Address": "119.29.29.29:53",
      "Protocol": "udp",
      "SOCKS5Address": "",
      "Timeout": 6,
      "EDNSClientSubnet": {
        "Policy": "auto",
        "ExternalIP": ""
      }
    },
    {
      "Name": "Rubyfish-DoT",
      "Address": "dns.rubyfish.cn:853",
      "Protocol": "tcp-tls",
      "SOCKS5Address": "",
      "Timeout": 6,
      "EDNSClientSubnet": {
        "Policy": "auto",
        "ExternalIP": ""
      }
    },
    {
      "Name": "sDNS-53UDP",
      "Address": "1.2.4.8:53",
      "Protocol": "udp",
      "SOCKS5Address": "",
      "Timeout": 6,
      "EDNSClientSubnet": {
        "Policy": "auto",
        "ExternalIP": ""
      }
    }
  ],
  "AlternativeDNS": [
    {
      "Name": "1111-DoT",
      "Address": "1.1.1.1:853",
      "Protocol": "tcp-tls",
      "SOCKS5Address": "",
      "Timeout": 6,
      "EDNSClientSubnet":{
        "Policy": "disable",
        "ExternalIP": ""
      }
    },
    {
      "Name": "OpenDNS-UDP5353",
      "Address": "208.67.222.222:5353",
      "Protocol": "udp",
      "SOCKS5Address": "",
      "Timeout": 6,
      "EDNSClientSubnet": {
        "Policy": "disable",
        "ExternalIP": ""
      }
    }
  ],
  "OnlyPrimaryDNS": false,
  "IPv6UseAlternativeDNS": false,
  "WhenPrimaryDNSAnswerNoneUse": "PrimaryDNS",
  "IPNetworkFile": {
    "Primary": "./ip_network_primary",
    "Alternative": "./ip_network_alternative"
  },
  "DomainFile": {
    "Primary": "./domain_primary",
    "Alternative": "./domain_alternative"
  },
  "HostsFile": "./hosts",
  "MinimumTTL": 60,
  "DomainTTLFile" : "./domain_ttl",
  "CacheSize" : 500,
  "RejectQType": [255]
}
```

Run the following to generate important blacklists/whitelists:

```bash
$ wget -O ip_network_primary https://raw.githubusercontent.com/17mon/china_ip_list/master/china_ip_list.txt
$ wget -O domain_primary https://api.birkhoff.me/v1/chndomains
$ > ip_network_alternative
$ > domain_alternative
$ > domain_ttl
$ rm ip_network_primary_sample ip_network_alternative_sample domain_primary_sample domain_alternative_sample domain_ttl_sample
```

# Launch Clash and Overture
Run the following to make Clashh and Overture launch at system startup:

```bash
$ service clash enable
$ service overture enable
```

You can control them using:

```bash
$ service clash start
$ service clash stop
$ service clash restart
$ service overture start
$ service overture stop
$ service overture restart
```

# Redirect the traffic to Clash
First, run these to create an IP address whitelist ipset:

```bash
ipset -F clash_whitelist && ipset -X clash_whitelist
ipset -! create clash_whitelist nethash && ipset flush clash_whitelist
ip_lan="0.0.0.0/8 10.0.0.0/8 100.64.0.0/10 127.0.0.0/8 169.254.0.0/16 172.16.0.0/12 192.168.0.0/16 224.0.0.0/4 240.0.0.0/4"
for ip in $ip_lan; do
    ipset -! add clash_whitelist $ip
done
```

Go to `https://ROUTER_IP/cgi-bin/luci/admin/network/firewall/custom`, append the following to the end of rules. **Be aware that you need to change `YOUR_SSH_PORT`.**

```bash
iptables -t nat -N clash
iptables -t nat -A PREROUTING -p tcp -j clash
iptables -t nat -A clash -m set --match-set clash_whitelist dst -j ACCEPT
iptables -t nat -A clash -p tcp --dport YOUR_SSH_PORT -j ACCEPT
iptables -t nat -A clash -p tcp --dport 80 -j REDIRECT --to-ports 9090
iptables -t nat -A clash -p tcp --dport 443 -j REDIRECT --to-ports 9090
iptables -t nat -A clash -p tcp --dport 53 -j REDIRECT --to-ports 53
```

(some of the instructions were taken from [SukkaW/Koolshare-Clash][9])

You can now open your browser now and go to `https://ipinfo.io` to see if it works!

# Control Clash
Remember the `external-controller`? We’re gonna make use of it… right now.

There’s a fantastic web interface that does exactly the work: [http://clash.razord.top/][7]. Use your OpenWrt IP address, and port `6170`.

# Check the logs

```bash
$ logread -e clash -f
$ logread -e overture -f
```

# Resources
- https://github.com/Dreamacro/clash
- https://github.com/shawn1m/overture
- https://github.com/SukkaW/Koolshare-Clash

[1]:	https://github.com/Dreamacro/clash
[2]:	https://github.com/Dreamacro/clash
[3]:	https://www.nssurge.com
[4]:	https://raw.githubusercontent.com/lhie1/Rules/master/Clash/General_dns.yml
[5]:	https://raw.githubusercontent.com/lhie1/Rules/master/Clash/Rule.yml
[7]:	http://clash.razord.top/
[8]:	https://github.com/shawn1m/overture
[9]:  https://github.com/SukkaW/Koolshare-Clash/blob/master/koolclash/scripts/koolclash_control.sh
