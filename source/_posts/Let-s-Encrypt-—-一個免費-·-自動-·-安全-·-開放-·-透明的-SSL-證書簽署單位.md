---
title: Let's Encrypt — 一個免費 · 自動 · 安全 · 開放 · 透明的 SSL 證書簽署單位
tags:
permalink: lets-encrypt-introduction
id: 5acda53481f41f000158dbe3
updated: '2017-01-08 00:18:34'
date: 2015-11-10 19:31:00
---

在如今這個網絡發達的時代，網絡交易、私人聊天、線上會議等**涉及個人（或公司）隱私**這些服務並不少見。但是如果這些隱私**沒有加密**，使用**明文傳輸**的話，很容易就會**被不法人士竊取**，**造成使用者的損失**。於是，各種服務（例如臉書、Outlook、Twitter、網絡銀行等）均開始推薦（或強制）使用 **https** 連線至主機。像這個部落格，也是強制全部使用 **https** 連線。

但是 **https** 連線是需要 **SSL Certificate （SSL 證書）** 的。這些證書通常由 **Symantec (前 VerSign)**, **COMODO**, **GlobalSign** 等 **受信賴的證書簽署單位 (Certificate Authority)** 所簽發的。且這些證書需要每年付費，且費用並不低。所以很多站長**並不想付費購買證書**，造成了**資訊傳輸安全性**的一大問題。

現在 **ISRG (Internet Security Research Group)** 與 mozilla, akamai, cisco, identrust, facebook 等其他互聯網巨頭共同開設了 **Let’s Encrypt** 服務。口號是 `免費，自動化，開放。 (free, automated, and open)`。最吸引各位的當然就是其免費的證書簽發服務。 自動化是什麼？能吃嗎（X）。自動化代表：**自動設定**。

什麼！？自動設定！？不可能吧？想必你一定是這樣想的。然而，**事實就是如此**。只要**在你的主機上安裝 Let’s Encrypt 的設定套件，執行幾行指令，就會自動依據你主機的環境將其設定完成**。（而且全過程非常快，而且免費）

2015/12/5 更新：Let’s Encrypt 已於 12/3 開放公測，各位朋友均可使用。本站也已經更新使用 Let’s Encrypt 證書。

Let’s Encrypt 的官方網站：[https://letsencrypt.org](https://letsencrypt.org)
