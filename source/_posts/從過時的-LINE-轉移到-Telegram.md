---
title: 從過時的 LINE 轉移到 Telegram
tags:
permalink: move-to-telegram-from-line
id: 5acda53481f41f000158dbf2
updated: '2016-06-25 01:01:43'
date: 2016-05-12 21:57:42
---

這幾年 LINE 在臺灣可說是十分風靡，但如今，LINE 的設計變得越來越複雜，十分的難用、而且安全性並不高。
可能你不會對自己的聊天軟體要求很高的安全性，但是你應該還是不太想被人家看到聊天記錄，而且想使用有更多更實用的功能吧？

#### Telegram 介紹
[Telegram Messenger LLP](https://telegram.org/) 是獨立的非營利公司，其設立在柏林，且由 [Nikolai Durov](https://en.wikipedia.org/wiki/Nikolai_Durov) 以及 [Pavel Durov](https://en.wikipedia.org/wiki/Pavel_Durov) ── 俄羅斯最大的社交網站 [VKontakte](https://vk.com/) 的創始人 ── 所設立！[Telegram Messenger LLP](https://telegram.org/) 使用了 Nikolai Durov 專門為其研發的 [MTProto](https://core.telegram.org/mtproto) 通訊協定作為整個軟體對伺服器的通訊基礎！

[Telegram](https://telegram.org/) 跟 [LINE](http://line.me/) 的幾項大對比：
1. LINE 不支援 bot API，即聊天機器人（最近剛開始支援，不過功能也不夠多元）
2. LINE 安全性不高，反觀 Telegram，連恐怖組織 ISIS 都指定用它做通訊
3. Telegram 官方承諾所有功能都永遠不需要付費，包含永久免費的貼圖系列：此處貼圖因全由使用者上傳，而永久免費。
4. Telegram 訊息傳送、APP 執行速度超快。
5. Telegram 支援各種平台，包括：[Android](https://telegram.org/dl/android)、[iOS](https://telegram.org/dl/ios)、[OS X](https://macos.telegram.org/)、[Windows/Linux 版](https://desktop.telegram.org/)、[網頁版](https://telegram.org/dl/webogram) 以及 [Windows Phone](https://telegram.org/dl/wp) 版本等
6. Telegram 可以針對單一條訊息回覆，還可以轉發單一或多條訊息。光是前者就能省下超多時間了！
7. Telegram 可以 「@」（標註）使用者！
8. LINE 只有群組，反觀 Telegram 還有「頻道」及更多種群組種類
9. Telegram 絕大部分的技術都已經由官方開源出來了。
10. 你不覺得 LINE 的界面很複雜嗎，一大堆有的沒的。

一個一個羅列出來倒是不太可能，因為真的差太多了！你有想象過在 Telegram 上看新聞、看天氣、找搞笑影音、調鬧鐘、管理 Docker 容器，甚至執行 bash、php、python、node.js、java 程式嗎？

#### Telegram 的安全性
Telegram 是經由專用的 [MTProto 通訊協議](https://core.telegram.org/mtproto) 以對稱式 AES 加密演算法（256 bits）、RSA 加密演算法（2048 bits）與 Diffie–Hellman key exchange 為基礎與伺服器進行通訊的。

這些可能說的太籠統，來看看官方多有信心：
三年前 Telegram 剛剛起步的時候，Pavel Durov 宣佈只要有任何人成功破解已攔截的通話訊息，他願意提供 200,000 BTC 做為獎金！（依照當時匯率來看，約為 3,289,600,000 台幣）

Telegram 分兩種聊天模式：

* 一般聊天模式：使用用戶端對伺服器端的加密通訊，且可以經由多重裝置登入。
* 秘密聊天模式：使用端對端（P2P）的加密通訊，且只能經由兩個特定裝置登入。

官方宣稱，當兩名使用者進行通訊時，第三方（包含管理人員）皆無法存取使用者的通訊內容。當使用者在進行秘密聊天時，訊息包含多媒體皆可以被指定為「自解構」的訊息。當訊息被使用者閱讀之後，訊息在指定的時間內會自動銷毀。一旦訊息過期，訊息會在使用者的裝置上消失。

### 註冊 Telegram 賬號
這個並不難！只要你拿起你身邊的裝置，打開 https://telegram.org ，就可以在上面找到你裝置的 Telegram 應用程式下載連結了！
接著，你只要按照應用程式內的指示註冊即可，不需要輸入什麼電子郵件、密碼還是什麼換機密碼，通通不用！只要手機簡訊認證就可以了！
註冊之後，請記得要在設定選單中設定你的使用者名稱（username），才能正常使用。

#### 開始使用 Telegram
Telegram 與 LINE 的差別是非常大的，一下是小弟為各位整理的一些內容。如果有缺漏的部分，您也可以在下方留言區提醒小弟！

##### 好友
首先，你要有一個認知：Telegram 的「好友」這個東西我們基本上不用它。你可以隨時向任何人建立對話，只要在搜尋方塊中輸入使用者的名字（或 username）就可以囉！

##### 群組
Telegram 的群組稱為「Group」，也就是類似於 LINE 群組的東西。Telegram 的群組分為兩類：

* 普通群組：與 LINE 的群組類似，且上限為 200 位使用者
* 超級群組（Supergroup）優於普通群組的地方：
    * 使用者上限為 5,000 人
    * 訊息 PIN 功能，即置頂功能
    * 管理者可以刪除任何訊息
    * 可建立自定義的邀請加入連結
    * 可以看到加入群組之前的歷史聊天記錄

頻道管理員可隨時將普通群組免費升級至超級群組，讓群組更加強大。

> 官方詳細說明：https://telegram.org/faq#q-what-39s-the-difference-between-groups-supergroups-and-channel

##### 頻道
頻道是一個有些類似群組的東西，但是性質卻不太一樣。
你可以這樣理解：使用者「訂閱」頻道，然後頻道管理者會以**頻道的名字、大頭照**在頻道內「廣播」訊息，但是使用者無法發言。而且，頻道是可以有無上限的訂閱人的！

##### 貼圖
Telegram 的貼圖不像 LINE 那樣由官方製作或是審核，在 Telegram 上面的貼圖全部都是由使用者自行上傳提供給大眾免費使用的！如果你也想自己做一套貼圖，你可以與 [@Stickers](https://telegram.me/stickers) 進行操作！只要貼圖提交給他並符合技術規範，就可以立刻發佈貼圖，不需要 LINE 那樣的官方繁雜審核喔！

##### bot 開發
Telegram 有提供一系列方便的 API 給開發者使用，且官方有非常完整的 API 文件！而且，依靠社群的強大力量，光是 NPM 上就有超多的 Telegram bot 套件！目前來說，https://github.com/mast/telegram-bot-api 算是還不錯的一個。

#### 結語
Telegram 是個新興、實用、安全的聊天軟體，它比目前流行的 WhatsApp、Messenger 或 LINE 都要安全的多。而且開發團隊秉持著開放原始碼的精神，除了伺服器使用的是專有軟體外，其他幾乎都是 open source 的！而且，如果你會寫程式，開發聊天機器人真的就跟喝水一樣簡單！
如果你有什麼問題，在 https://telegram.org/faq 上搜尋幾乎都找得到解答及說明！
如果你是開發人員，而你想知道 Telegram 的詳細技術資料，請參閱 https://core.telegram.org/techfaq 。

##### 搭配服用
* [Telegram 中文化教學](https://blog.birkhoff.me/telegram-to-chinese/)
* [從 Line 換到 Telegram：一個更好的通訊軟體！](https://yami.io/line-to-telegram/)
