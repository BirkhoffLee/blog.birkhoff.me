---
title: Solution to Battlefield V keeping crashing on Win10
categories:
  - null
tags:
  - null
comments: true
toc: false
date: 2019-05-02 20:35:02
---

<!-- more -->

Today I wanted to play BFV and upon launching it just crashes without any error message. My environment:

* i7-7700k, overclocked to 4.8 GHz
* 8 GiB 3200 MHz RAM \* 2
* NVIDIA RTX 2080 overclocked (core +120 MHz, mem +700 MHz)
* 240 Hz monitor
* DX12 and DXR on

I fixed it by doing the followings:

1. Completely close MSI Afterburner and RTSS or other overlays you have. They are NOT compatible with DX12 games.
2. Go to `bfv.exe` and go to the Properties \> Compatibility, check `Disable full screen optimizations` and click on `Change high DPI settings`. Check the box that says "Override high DPI scaling behavior. Scaling performed by”. Select "Application" in the drop down box. Click ok.
3. On my machine, after some point it runs out of memory when in-game, it also causes stuttering. Use [https://www.wagnardsoft.com/content/intelligent-standby-list-cleaner-v1000-released][1] to solve it.
4. Run DDU to do a clean-reinstall of the graphics drivers.

That’s it. If any of the above worked for you, make sure to let me know in the comments section down below!

[1]:	https://www.wagnardsoft.com/content/intelligent-standby-list-cleaner-v1000-released "Intelligent standby list cleaner"