---
title: 赫布學習法 ─ The Hebb's Rule
tags:
permalink: the-hebbs-rule
id: 5acda53481f41f000158dbff
updated: '2016-09-21 22:04:21'
date: 2016-07-28 21:14:55
---

大家好這裡是非常久沒出文章的 lemo，~~抱著贖罪的感情來寫文章~~。

讓我們來看看今天的主角 *Hebb's Rule* ，以下是 Hebb's Rule 的完整定義。

> Let us assume that the persistence or repetition of a reverberatory activity (or "trace") tends to induce lasting cellular changes that add to its stability... **When an axon of cell A is near enough to excite a cell B and repeatedly or persistently takes part in firing it, some growth process or metabolic change takes place in one or both cells such that A's efficiency, as one of the cells firing B, is increased**. -- Hebb

意思大致為若 A 和 B 之間夠近足以互相刺激，並且反覆刺激，則 A 和 B 之間的傳遞效能就會增加。

![alt](/content/images/2016/07/out.png)

上圖為這次用來分析的類神經網路(抱歉圖可能畫的不好看,第一次用Graphviz畫。),而根據這個架構來看,<b>A 和 B 傳遞效能增加的部份為Weight</b>,所以根據Hebb's Rule來說,我們可以定義一個公式來更新Weight:
![alt](https://wikimedia.org/api/rest_v1/media/math/render/svg/a9321e2586026ab8b355aa2af95b4811462eb112)

然而我們為了能夠讓它達到我們的預期目標,我們將兩個訊號(χ)改成預期輸入(ρ)輸出(t)組,我會將輸入、輸出、權重(Weight)以矩陣表示。

得公式: W = ρ×t

這種算法雖然還是不如預期,但在輸入的P與預期輸入正交時,產出的就是預期輸出,原因是兩矩陣正交。偷偷告訴你這種可能性很小,為了取代這種方法,我們必須重線性代數拿出一向工具,它叫偽逆矩陣(Pseudo inverse)[連結在這](https://ccjou.wordpress.com/tag/pseudo-inverse/)

偽逆矩陣特性(A*是偽逆矩陣):
![alt](https://s0.wp.com/latex.php?latex=XX%5E%5Cast+A%5E%5Cast%3DX&bg=ffffff&fg=000000&s=0)
![alt](https://s0.wp.com/latex.php?latex=XAA%5E%5Cast%3DA%5E%5Cast&bg=ffffff&fg=000000&s=0)

公式為:   A* = A(轉置)/(A(轉置)×A)

我們可以用上面的方法,帶入預期輸入ρ求出其偽逆矩陣,再與預期輸出相乘後得一權重矩陣(weight),便可配置在你的類神經網路內喔~

如果看不懂可以寄信問我[email](mailto:he88723@gmail.com),抱歉這次寫得很爛QQ<br/><br/>
對了這一系列主要以探討算法,不會寫到code喔~
