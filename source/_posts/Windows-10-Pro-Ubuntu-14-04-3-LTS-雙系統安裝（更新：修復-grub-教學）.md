---
title: Windows 10 Pro + Ubuntu 14.04.3 LTS 雙系統安裝（更新：修復 grub 教學）
tags:
permalink: windows-10-and-ubuntu-14_04_3-lts-dual-boot
id: 5acda53481f41f000158dbe0
updated: '2016-03-01 13:01:09'
date: 2015-10-21 17:57:00
---

相信大家都聽過 Ubuntu 吧，Based on Linux
 但是可能大家的工作是離不開 Windows 的，或是娛樂方面的需求。像我一樣，我有時候也會玩一會遊戲當打發時間用，而且我現在的學校的英語作業有時候要在 IE 上面做，所以就必須裝雙系統囉。
 但是這可不是一件輕鬆的事情（對我來說 XD），在過程中遇到各種困難，下面就分享一下這雙系統的安裝過程吧！


## Requirement

> Windows 10 Pro 官方 ISO 檔下載教學：http://188.166.181.226/get-windows-10-iso/
  Ubuntu 14.04.3 LTS 下載連結：http://www.ubuntu.com/download/desktop

請將這兩個 ISO 檔案變成**可供開機的** CD 或者 USB 隨身碟（此處不再贅述，網上均有教學）


## Installation

這裡就不丟 Screenshot 了，最近真的沒時間再重新弄一次再拍。等下次我重灌的時候再補上吧 QAQ
 首先，**你要備份好你的資料**，不然後悔可是來不及啊（像我之前把一個還沒丟到 git 上的專案不小心整個資料夾刪除惹 超痛苦 QAQ），並且請備份到外部裝置（建議隨身硬碟）

### Step 1

關機（幹 廢話嗎

### Step 2

進入 BIOS 設定 **Boot Mode** （通常有 **Leagcy** 跟 **UEFI** 兩個選項），此處請設定為 **UEFI**，並且請關閉 **Secure Boot**。

### Step 3

插入 **Windows 10** 安裝媒體，以其開機，執行安裝程式，此處沒有什麼需要特別注意的。把整個硬碟格式化重新分區就好，也不用特別為 Ubuntu 留空間（我這裡使用的是約 C: 250 GB, D: 750 GB），我們等一下會使用 D 槽的空間來執行 Ubuntu Installation.

### Step 4 — the most important

進入 Windows 10，右擊右下角的電源圖示，進入 **電源選項**。

![](/content/images/2015/10/Windows-10-and-ubuntu-14_04_3-LTS-dual-boot-ScreenShot001.jpg)

點擊右側的 **喚醒時需要密碼**

![](/content/images/2015/10/Windows-10-and-ubuntu-14_04_3-LTS-dual-boot-ScreenShot002.jpg)

點擊 **變更目前無法使用的設定**

![](/content/images/2015/10/Windows-10-and-ubuntu-14_04_3-LTS-dual-boot-ScreenShot003.jpg)

取消選取 **開啟快速啟動（建議選項）**
 關閉快速啟動的原因是，快速啟動所使用的技術會影響 Grub 開機引導程式而無法進入 Ubuntu.
 點擊最下方的**儲存變更**。

### Step 5

好了，我們已經設定好該死的 Windows 10 了，接下來就安裝 **Ubuntu 14.04.3 LTS** 吧/
 此時，插入 Ubuntu 安裝媒體，選擇 Try Ubuntu without installing。
**如果 WiFi 可用，請連結 WiFi。否則請插上網絡線。**
**（這裡我是沒有 WiFi Driver 可用，對應我網卡的型號，我插上了網絡線並執行了 `sudo apt-get install bcmwl-kernel-source`）**
 打開**桌面上的安裝程式**。
 你可以接下來就照著他做，不過在選擇安裝類型的時候，請選擇 **與 Windows Boot Manager 共存** 的選項。**記住：每一步都要小心 (ゝ∀･)**
 安裝完成後，他會問你要重新啟動電腦或繼續 Try Ubuntu，**選擇重新開機**，會直接進入安裝好的 Ubuntu。
**建議現在就安裝好必要的 Driver。**

### Step 6

此時，點擊右上角的圖示，點擊**關機**。 打開電腦，你會發現：電腦居然直接無視 Ubuntu 而直接啟動了 Windows 10！（如果這次 GRUB 的選單有出現，下一次開機可能就沒這麼幸運惹）

### Step 7

來搞定這霸道的 Windows 10 吧。 進入 Windows，按下 **Win + X** ，點擊命令提示字元（系統管理員）。 接下來，請執行下面這行指令： `bcdedit /set {bootmgr} path EFIubuntugrubx64.efi` 此時 Windows 會將開機程式換成 GRUB。 重開機，就發現 GRUB 回來了，可以啟動 Ubuntu 了！


## Fix GRUB

*(22 December 2015 更新)*
 有時候可能 Windows 更新，或是不小心動到了什麼，grub 可能不會在開機的時候出現而直接啓動 Windows。例如不久前 Microsoft 推送的 Windows 10 Threshold 2 更新包，我更新完後就出現了上述的情況。 此時，請嘗試重複操作上方的 **Step 7**，一般就可以修復 GRUB 消失的情形囉！

> References:
>  http://askubuntu.com/questions/666631/how-can-i-dual-boot-windows-10-and-ubuntu-on-a-uefi-hp-notebook
>  http://askubuntu.com/questions/529510/windows-boot-manager-option-on-grub
>  http://askubuntu.com/questions/235567/windows-8-removes-grub-as-default-boot-manager
