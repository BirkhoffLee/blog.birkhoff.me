---
title: Windows Subsystem for Linux (WSL) 安裝教學 & 初體驗
tags:
permalink: bash_on_windows_installation
id: 5acda53481f41f000158dc00
updated: '2016-08-11 07:43:15'
date: 2016-08-11 05:48:45
---

八月二日時微軟釋出了 Windows 10 年度更新版（組建 14393），其中已經添加了流傳已久的 Bash for Windows（其實組建 14316 就有了）。小弟早就迫不及待想嘗試一下了，在這裡寫個教學記錄一下。

首先你要知道：**這不是虛擬機器，也不是容器，也不是專門為 Windows 編譯的 Linux binary（像是 cygwin）。[^1]**

你可以想象它是 Wine 的相反——Ubuntu 的 binaries 在 Windows 上原生實作。Ubuntu 官方提到[^2]：

> A team of sharp developers at Microsoft has been hard at work adapting some Microsoft research technology to basically **perform real time translation of Linux syscalls into Windows OS syscalls**.

#### Requirements[^3]
* 電腦執行 Windows 10 Build 14316 以上版本
  在這裡升級：http://go.microsoft.com/fwlink/p/?LinkId=821403
* x64 的處理器以及 Windows
* 必須使用 AMD 或 Intel 的 x64 相容 CPU
* 已加入 [Windows 測試人員計劃](https://insider.windows.com/)

#### Prepare

###### 啓用開發人員模式
首先，請打開 Windows 的設定應用程式，你可以在開始選單的左下角第二個圖示找到它。

![](/content/images/2016/08/bash_on_windows_installation_01.png)

其次，請點選更新與安全性，然後點選左方選單的開發人員專用：

![](/content/images/2016/08/bash_on_windows_installation_02.png)

![](/content/images/2016/08/bash_on_windows_installation_03.png)

接著，點選開發人員模式，然後點選是：

![](/content/images/2016/08/bash_on_windows_installation_04.png)

#### 啟用 Windows subsystem for Linux (Beta) 方法一
1. 請按下 Win + X，然後選擇命令提示字元。接著鍵入 `OptionalFeatures` 並且按下 Enter。
2. 將列表拉到最底部，將適用於 Linux 的 Windows 子系統 (搶先版 (Beta)) 的核取方塊打勾，並且點選確定。

  ![](/content/images/2016/08/bash_on_windows_installation_06.png)
3. 待其處理完畢後，請儲存你的資料以及此網頁連結，然後重新開機。

  ![](/content/images/2016/08/bash_on_windows_installation_07.png)

#### 啟用 Windows subsystem for Linux (Beta) 方法二
請按下 Win + X，然後選擇命令提示字元**（系統管理員）**。接著逐行執行以下指令[^4]。
```
powershell
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
```

#### 安裝 Windows subsystem for Linux (Beta)

1. Windows 要求重新開機時，請重新開機，因為 Windows subsystem for Linux 的某些底層需求只有在 Windows 啟動時才能載入。[^5]
2. 重新開機完成之後，請按下 Win + X，然後打開命令提示字元。
3. 如果你要使用預設的設定，請執行 `lxrun /install /y`，這會同意使用者條款、安裝子系統並且設定使用者名稱為 `root`，密碼為空。然後請跳到下一個部分繼續閱讀**（推薦）**
如果你要手動設定，請執行 `bash`，閱讀條款之後輸入 `y` 以繼續。
  ![](/content/images/2016/08/bash_on_windows_installation_08.png)
4. 資料處理完成之後，請設定 UNIX 使用者名稱及密碼，要注意這裡的使用者名稱及密碼跟 Windows 的那對完全沒有關係。[^6]如果你選擇使用者名稱為 root，密碼就不需要設定。
  ![](/content/images/2016/08/bash_on_windows_installation_09.png)

#### 技巧、注意事項

1. 如果以後要打開 Ubuntu on Windows，執行 `bash`。
2. 可以我看到一開始進去的 path 是 `/mnt/c/Users/Birkhoff Lee`，也就是說 Windows 有把你的使用者目錄（`C:/Users/使用者名稱`）掛載進去。往上層目錄看，原來它是把**所有硬碟**的檔案系統直接以==可讀可寫==的權限掛載進去，所以請不要在裡面執行 `rm -rf /mnt/C/*` 之類的東西，不然會爆炸，以下誠招勇者嘗試
3. root 使用者的檔案目錄可以在 Windows Explorer 下面找到，path: `C:\Users\使用者名稱\AppData\Local\lxss\rootfs`
4. Docker 目前在上面跑不了，該 issue 討論串連結：https://github.com/Microsoft/BashOnWindows/issues/85
5. 本篇教學安裝到的 Ubuntu 版本是 14.04.4 LTS。
6. 這目前只是測試版，不是所有東西都能 work。
7. 解除安裝：執行 `lxrun /uninstall /full /y`
8. 請在 https://github.com/Microsoft/BashOnWindows/issues 回報問題
9. 每個使用者的 Ubuntu on Windows 都是獨一的
10. 在 Windows 下跑 `bash -c "指令"` 可以直接執行 bash 指令
11. FAQ 連結：https://msdn.microsoft.com/zh-tw/commandline/wsl/faq

#### References
[^1]: http://insights.ubuntu.com/2016/03/30/ubuntu-on-windows-the-ubuntu-userspace-for-windows-developers/
[^2]: http://insights.ubuntu.com/2016/03/30/ubuntu-on-windows-the-ubuntu-userspace-for-windows-developers/
[^3]: https://msdn.microsoft.com/zh-tw/commandline/wsl/install_guide
[^4]: https://msdn.microsoft.com/zh-tw/commandline/wsl/install_guide
[^5]: [https://msdn.microsoft.com/commandline/wsl/install_guide](https://msdn.microsoft.com/commandline/wsl/install_guide): *It is important that you DO reboot when prompted as some of the infrastructure which Bash on Windows requires can only be loaded during Windows' boot-up sequence.*
[^6]: https://aka.ms/wslusers

