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
* 2 \* 8 GiB 3200 MHz RAM
* NVIDIA RTX 2080 overclocked
* 240 Hz monitor
* DX12, DXR on, FFR off

I fixed it by doing the followings:

* When playing BFV, make sure you do NOT overclock your GPU. You can still use Afterburner and RTSS as long as you set the application detection level to high in RTSS, otherwise the game will crash.
* Go to `bfv.exe` and go to the Properties \> Compatibility, check `Disable full screen optimizations` and click on `Change high DPI settings`. Check the box that says "Override high DPI scaling behavior. Scaling performed by”. Select "Application" in the drop down box. Click ok.
* On my machine, after some point it runs out of memory when in-game, it also causes stuttering. Use [https://www.wagnardsoft.com/content/intelligent-standby-list-cleaner-v1000-released][1] to solve it. This is a known Windows issue.
* Run DDU to do a clean-reinstall of the graphics drivers. Remember to screenshot the settings in the NVIDIA control panel, as running DDU will erase them as well.

By the way:

* In Nvidia Control Panel, make sure BFV's Maximum pre-rendered frames is set to `Use the 3D application setting`, otherwise it causes CPU bottleneck on my machine. This improves FPS.
* If you have a high-end machine, turn off Motion Blur in-game, which improves FPS.
* Using Fullscreen is fine. It will not crash the game.

[1]:	https://www.wagnardsoft.com/content/intelligent-standby-list-cleaner-v1000-released "Intelligent standby list cleaner"
