---
title: Setting up a WireGuard server on OpenWRT
categories:
  - null
tags:
  - null
comments: true
toc: false
date: 2019-02-21 22:02:57
---

Sometimes it can be useful to be able to connect back to your home network to access some internal resources. I’ll share how I set up a WireGuard server on OpenWRT.

<!-- more -->

First install some WireGuard packages.

```bash
$ opkg update
$ opkg install kmod-wireguard luci-app-wireguard luci-proto-wireguard wireguard wireguard-tools
```

Next go to [https://openwrt/cgi-bin/luci/admin/network/iface_add][1], name the VPN interface *wg0*, select *WireGuard VPN* for *Protocol of the new interface* and press submit.

We need to generate some keypairs for the server and clients. Make sure to keep them safe.

```bash
$ mkdir -p /etc/wireguard
$ wg genkey | tee /etc/wireguard/server-privatekey | wg pubkey > /etc/wireguard/server-publickey
$ wg genkey | tee client-privatekey | wg pubkey > client-publickey
```

Head to the configuration page of *wg0* interface ([https://openwrt/cgi-bin/luci/admin/network/network/wg0][2]). In *General Setup* tab, paste the content of `/etc/wireguard/server-privatekey` into *Private Key*. You can change *Listen Port* to any unused port you like. In *IP Addresses*, choose a subnet IP CIDR, for example `10.200.200.1/24`. This will be the subnet of the VPN.

Next, let’s configure some peers. Some backgrounds here. First, WireGuard does not have the concept of server/client, instead, every WireGuard device is regarded as a *peer* to each other. Before establishing a successful connection, a proper config setup on both side is required.

Add a peer using the *Add* button. The peer we’re configuring here will be the “client”. In * Public Key*, paste the content of `/etc/wireguard/client-publickey`. In *Allowed IPs*, enter a random IP address in the subnet you previously chose, for example `10.200.200.2/24`. This will be the client’s internal IP address.

Next, make sure *Route Allowed IPs* is checked. You most likely won’t need to configure *Endpoint Host* and *Endpoint Port* as we will be manually connecting to the OpenWRT WireGuard device on the client, instead of having OpenWRT aggressively establishing a connection. Put the recommended value `25` into *Persistent Keep Alive*.

In *Firewall Settings* tab, assign *lan* zone for the interface.

Hit *Save & Apply*.

Next run the following to make a new *Traffic Rule* in OpenWRT firewall. Make sure to change `99999` to your previously chosen port for WireGuard interface.

```bash
uci add firewall rule
uci set firewall.@rule[-1].src="*"
uci set firewall.@rule[-1].target="ACCEPT"
uci set firewall.@rule[-1].proto="udp"
uci set firewall.@rule[-1].dest_port="99999"
uci set firewall.@rule[-1].name="Allow-Wireguard-Inbound"
uci commit firewall
/etc/init.d/firewall restart
```

The router side is done, I’ll demonstrate how to set up WireGuard on iOS. Download WireGuard app at [https://itunes.apple.com/us/app/wireguard/id1441195209?mt=8][3]. Open the app, press the *+* button on the top-right side and choose *Create from scratch*. Put any name you like on the *Name* field. Paste the keypairs of the client into their respective fields. In *Addresses*, put the exact same of what you specified in *Allowed IPs* of the client peer, e.g. `10.200.200.2/24`. In *DNS servers*, put the router’s LAN IP address in. Don’t touch *Listen port* and *MTU* unless you know what you’re doing.

Add a new peer down below, and paste the server’s public key into *Public key*. Leave *Preshared key* field empty. In *Endpoint*, specify the router’s IP address or a domain name, ending with `:port`. For example `vpn.foobar.dev:1234`. Put `0.0.0.0/0` into *Allowed IPs*. Leave the rest default and hit save. Connect to the server and you should be able to access your home’s internal network on the public Internet.

[1]:	https://openwrt/cgi-bin/luci/admin/network/iface_add
[2]:	https://openwrt/cgi-bin/luci/admin/network/network/wg0
[3]:	https://itunes.apple.com/us/app/wireguard/id1441195209?mt=8