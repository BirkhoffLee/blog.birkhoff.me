---
title: Change GRUB timeout in OpenWrt to speed qup boot process
categories:
  - null
tags:
  - null
comments: true
toc: false
date: 2019-01-17 23:57:55
---

Recently I’m playing with my OpenWrt router on a PVE machine, and I noticed that there’s a 5 second timeout in the boot procedure.
<!-- more -->
It’s important to have a router boot up fast. So I searched online how to change the timeout setting. Unfortunately OpenWrt isn’t Debian, while most tutorials I found online is Debian or RHEL. So stuff works quite differently.

After some digging I found that you can actually override `/boot/grub/grub.cfg`,  because there’s no `grub-mkconfig`. But `/boot` was read-only for me, so I first had to run 

```bash
$ mount -o remount,rw /boot
```

And finally I could do

```bash
$ vim /boot/grub/grub.cfg
```

According to the GRUB documentation:

```bash
'GRUB_TIMEOUT'
     Boot the default entry this many seconds after the menu is
     displayed, unless a key is pressed.  The default is '5'.  Set to
     '0' to boot immediately without displaying the menu, or to '-1' to
     wait indefinitely.

     If 'GRUB_TIMEOUT_STYLE' is set to 'countdown' or 'hidden', the
     timeout is instead counted before the menu is displayed.
```

I set `GRUB_TIMEOUT` to `0`, and it worked flawlessly.