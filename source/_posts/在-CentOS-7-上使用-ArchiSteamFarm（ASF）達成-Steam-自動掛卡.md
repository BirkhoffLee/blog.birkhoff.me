---
title: 在 CentOS 7 上使用 ArchiSteamFarm（ASF）達成 Steam 自動掛卡
permalink: install-archisteamfarm-on-centos-7
id: 5acda53481f41f000158dc08
updated: '2018-02-06 05:22:13'
date: 2018-02-06 05:07:18
tags:
---

# 第一步：安裝 .NET 環境、tmux
以下指令來自 https://docs.microsoft.com/en-us/dotnet/core/linux-prerequisites?tabs=netcore2x
```
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[packages-microsoft-com-prod]\nname=packages-microsoft-com-prod \nbaseurl=https://packages.microsoft.com/yumrepos/microsoft-rhel7.3-prod\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/dotnetdev.repo'
sudo yum update
sudo yum install libunwind libicu
sudo yum install dotnet-sdk-2.0.0
export PATH=$PATH:$HOME/dotnet
dotnet --version
```
如果成功了會輸出類似這種東西
```
[birkhoff@docker-asia-1 ~]$ dotnet --version
Did you mean to run dotnet SDK commands? Please install dotnet SDK from:
  http://go.microsoft.com/fwlink/?LinkID=798306&clcid=0x409
```
雖然看起來很奇怪但是它就是會跑出這個。
這邊提醒一下，建議用 tmux 或 screen 之類的套件讓 ASF 跑在後台，這樣就可以真正無人值守掛卡啦！
```
sudo yum install -y tmux
```

# 第二步：下載、解壓縮 ASF
這一步很重要，我卡了很久。試了半天才發現要用 `ASF-generic.zip`。
```
mkdir ~/ASF
cd ~/ASF
chmod +x
```

接下來去 https://github.com/JustArchi/ArchiSteamFarm/releases/latest 複製 `ASF-generic.zip` 的下載網址，
現在最新版的是 `https://github.com/JustArchi/ArchiSteamFarm/releases/download/3.1.0.0/ASF-generic.zip`，找到之後就下載、解壓縮到機器上啦：

```
wget https://github.com/JustArchi/ArchiSteamFarm/releases/download/3.1.0.0/ASF-generic.zip
unzip ASF-generic.zip
rm ASF-generic.zip
chmod +x ArchiSteamFarm.sh
```

# 第三步：設定
這邊我就不再贅述，每個平台都一樣，請參考官方 wiki 或網上教學，有網頁版的設定檔產生器很方便

# 第四步：啟動 ASF
```
tmux
cd ~/ASF
./ArchiSteamFarm.sh
```
這邊提醒一下，建議用 tmux 或 screen 之類的套件讓 ASF 跑在後台，這樣就可以真正無人值守掛卡啦！
