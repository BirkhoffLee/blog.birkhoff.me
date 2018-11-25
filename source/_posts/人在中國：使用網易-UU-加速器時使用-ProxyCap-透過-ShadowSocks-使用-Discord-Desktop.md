---
title: 人在中國：使用網易 UU 加速器時使用 ProxyCap 透過 ShadowSocks 使用 Discord Desktop
tags:
permalink: uu-proxycap-ss-discord-companion
id: 5b7e8e2068ef6f00014c2d1e
updated: '2018-08-24 16:29:28'
date: 2018-08-23 18:36:16
---

> Edit: 目前最佳解還是 Discord Web 版（本文介紹的方式可能不穩定、且軟體需付費）

# 場景
* 需要使用*網易 UU 網遊加速器*來降低國際遊戲的延遲
* Discord Desktop 連線不穩定
    * Web 版本雖可使用 browser-specified proxy, 但 web 版本限制多不考慮
    * Desktop 版本不可設定 proxy
* 使用 ShadowSocks 上網

## ProxyCap
[ProxyCap](http://www.proxycap.com) 可以讓*所有*或*部分* Windows application 透過一個 SOCKS/HTTP proxy 連線至 internet，其他 alternative 有：
* Proxifier：非常 modern，但是不支援 UDP，再見
* SocksCap64：停止維護，且必須透過 SocksCap64 啟動要 proxy 的應用程式，與 UU 似乎有衝突
* SSTAP：停止維護，且似乎只支援 system-wide proxying，UI 很難用
* WideCap：有 bug，unfriendly UI
* FreeCap：據說 bug 多、而且上次更新是十年前，沒有打算使用

考慮以上狀況，ProxyCap 是最佳選擇：
* 支援 UDP
* 官網寫支援 Windows 10 表示有在維護
* UI 非常簡單易用，輕鬆上手！
* 不需要透過自身啟動要 proxy 的應用程式，直接啟動即可

## ShadowSocks (SS)
我使用 SS 進行對外 TCP/UDP 通訊，且 SS client 會在本地開一個 `127.0.0.1:1080` 的 Socks5 proxy，若要使用 SS 通訊需要使用該 Socks5 proxy。

## UU 加速器
分為四種加速模式 (資料來自  https://steamcommunity.com/groups/NeteaseUU/discussions/3/144512753468418878/)
1. 模式一 PPTP VPN
2. 模式二 L2TP VPN：穿透比 PPTP 強
3. 模式三 OpenVPN：要安裝虛擬網卡
4. 模式四 LSP

其中模式 4 會弄壞 ProxyCap、模式三有幾率弄壞 SS。因此採用模式二

# 可能的解決方案
1. 透過 Router 透明代理 SS（見 Merlin 固件），強制所有 discord 的 domain 走 SS
    * 一般 Router 計算能力通常不佳，除非使用軟路由否則一般都很不穩、速度很慢，而且很不方便使用
2. 軟體層想辦法讓 Discord 跑去用 SS
    1. 中國某些加速器會幫你順便加速 Discord，例如奇游加速器。不過奇游的效果遠不如 UU，而且奇游加速會對電腦的網絡出奇效，例如你的 SS 本來可以跑滿 100Mbps，開了奇游加速會減速到 300KBps（黑人問號.jpg）
    2. 以上提到的 ProxyCap
    3. Proxifier：UDP 轉發有問題
    4. SSTAP：已停止維護、且介面設計很奇怪很難使用
3. 使用 Discord Web 版：有一些小限制
4. 肉身翻牆（我也想呀 QQ）

# 設定

## UU
選擇模式只要在選擇節點的時候只勾選**模式二**即可：

![UU_mode_2](/content/images/2018/08/UU_mode_2.png)

## SS
要支援 UDP 轉發。

## ProxyCap

**ProxyCap** 是付費軟體

![ProxyCap1](/content/images/2018/08/ProxyCap1.png)

![ProxyCap2](/content/images/2018/08/ProxyCap2.png)

![ProxyCap3](/content/images/2018/08/ProxyCap3.png)

Rules 新增完之後，double-click 新的 entry 可以修改更多細項，如：
* Proxy 方式/Proxy chain
* Program list：可以繼續新增要 proxy 的 application

# 效果
* 遊戲透過 L2TP VPN 連線至 UU 的某個超神奇遊戲專線伺服器**大幅**降低 latency 與 loss
* Discord 透過 ProxyCap 再透過 SS 再透過你的某台伺服器**大幅**降低 latency 與 loss 且提升穩定性
    * 蘇州電信 100M/20M FTTB 實測：Discord 香港從直連 ping 200+ 掉到 50 ~ 70 ms
    * Discord 被 GFW 封鎖的情況可以順便解決

# 小結
活在中國真痛苦。然後不要想著順便用 SS 加速遊戲，你想多了。
這篇文章有可能有問題，不過現階段我是這樣用的。如果有更多解決方案或細節我會繼續更新。
