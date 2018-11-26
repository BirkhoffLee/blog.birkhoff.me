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
sudo yum remove dotnet-host.x86_64
rm -rf ~/.dotnet
curl -O https://dot.net/v1/dotnet-install.sh
chmod +x ./dotnet-install.sh
./dotnet-install.sh -c Current
rm dotnet-install.sh
export PATH="$PATH:$HOME/.dotnet"
dotnet --info
```

記得進你的 shell startup script 把 `$HOME/.dotnet` 加到 `PATH` 裡。這邊提醒一下，建議用 tmux 或 screen 之類的套件讓 ASF 跑在後台，這樣就可以真正無人值守掛卡啦！
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
