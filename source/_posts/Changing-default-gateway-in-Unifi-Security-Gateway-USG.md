---
title: Changing default gateway in Unifi Security Gateway (USG)
categories:
  - null
tags:
  - null
comments: true
toc: false
date: 2019-06-12 07:38:40
---

<!-- more -->

I've recently replaced my home network hardware with the Unifi family, and I've been satisified about them.

I live in China, and I have a Linux box that runs transparent proxy. I need to change the DHCP default gateway to something else, but it was nowhere found in the GUI. After some searching I have the solution here. First SSH into your USG, and do the following:

```bash
configure
show service dhcp-server shared-network-name # check your network name
set service dhcp-server shared-network-name NETWORK_NAME_HERE subnet YOUR_SUBNET_HERE default-router NEW_GATEWAT_IP
delete service dhcp-server shared-network-name NETWORK_NAME_HERE subnet YOUR_SUBNET_HERE dns-server ORIGINAL_DNS_IP
set service dhcp-server shared-network-name NETWORK_NAME_HERE subnet YOUR_SUBNET_HERE dns-server NEW_DNS_IP
commit
save
exit
```

Remember to follow [this](https://help.ubnt.com/hc/en-us/articles/215458888-UniFi-USG-Advanced-Configuration) to make the config persistant.
