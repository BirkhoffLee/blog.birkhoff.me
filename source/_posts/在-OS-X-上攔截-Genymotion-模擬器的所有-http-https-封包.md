---
title: 在 OS X 上攔截 Genymotion 模擬器的所有 http/https 封包
tags:
permalink: capture-genymotion-https-package-osx
id: 5acda53481f41f000158dbfe
updated: '2016-07-22 22:35:00'
date: 2016-07-22 21:54:36
---

[OWASP ZAP](https://www.owasp.org/index.php/OWASP_Zed_Attack_Proxy_Project) 是一套開源且免費的滲透安全測試軟體，由非常多的志工打造而成，適合開發者或安全測試人員使用。要抓 Genymotion 模擬出的 Android device 的 http/https 封包時就非常適合用它。

### Environment
* OS X 10.11.5
* OWASP ZAP 2.5.0
* Genymotion 2.7.2
* Emulated Android 5.0.0

### Step 1
打開 OWASP ZAP，在彈出的「Do you want to persist the ZAP Session」對話框中選擇第一個選項並按「Start」。
![](/content/images/2016/07/capture-genymotion-osx-1.png)

### Step 2
打開「Tools」>「Options」，然後點選「Save」，並且將憑證檔案儲存到桌面上。
![](/content/images/2016/07/capture-genymotion-osx-2.png)

### Step 3
進入 Genymotion，啟動你的 Android device，將你的憑證檔案直接拖到模擬器 player 視窗內。

### Step 4
進入「Settings」>「Security」，點選「Install from SD card」然後進入「Internal storage」>「Download」並點選你的憑證檔案。
![](/content/images/2016/07/capture-genymotion-osx-3.png)

### Step 5
OWASP ZAP 預設會監聽 `localhost:8080`，我們需要將所有網絡流量丟給 OWASP ZAP 處理，所以需要在 Wi-Fi 選項中設定 proxy 代理。

進入「Settings」>「Wi-Fi」，按住「WiredSSID」然後點選「Modify Network」，
將「Advanced options」打勾，將「Proxy」選項設定為「Manual」。
請將出現的設定依下列填入：

> `Proxy hostname: 10.0.3.2`
  `Proxy port: 8080`

然後按下「SAVE」就完成了！最終的設定會像下圖：
![](/content/images/2016/07/capture-genymotion-osx-4.png)

其中的 `10.0.3.2` 是 Genymotion 中的一個固定 ipv4 位置，專門用來指向執行 Genymotion 的主機。

### Step 6
接下來，所有的 http(s) 流量會全部在 OWASP ZAP 中出現，如下圖：
![](/content/images/2016/07/capture-genymotion-osx-5.png)
