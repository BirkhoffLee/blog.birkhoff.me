---
title: 解決 apt-get dist-upgrade 並 reboot 之後 Docker daemon 無法啟動的問題
tags:
permalink: docker-aufs-solution
id: 5acda53481f41f000158dc05
updated: '2017-04-21 23:33:18'
date: 2017-04-21 23:17:28
---

## 發現問題
剛剛在更新自己的 Ubuntu Server 的時候遇到的問題。跑了 `sudo apt-get dist-upgrade -y; reboot` 之後，再跑 `sudo service docker start` 就失敗了。

看了一下 `sudo journalctl -u docker.service`，跑出下面的 log：

```
Apr 21 15:10:47 docker-node-01 systemd[1]: Starting Docker Application Container Engine...
Apr 21 15:10:47 docker-node-01 dockerd[1975]: time="2017-04-21T15:10:47.121785550Z" level=info msg="libcontainerd: new containerd process, pid: 1995"
Apr 21 15:10:47 docker-node-01 dockerd[1975]: Error starting daemon: error initializing graphdriver: driver not supported
Apr 21 15:10:47 docker-node-01 systemd[1]: docker.service: Main process exited, code=exited, status=1/FAILURE
Apr 21 15:10:47 docker-node-01 systemd[1]: Failed to start Docker Application Container Engine.
Apr 21 15:10:47 docker-node-01 systemd[1]: docker.service: Unit entered failed state.
Apr 21 15:10:47 docker-node-01 systemd[1]: docker.service: Failed with result 'exit-code'.
Apr 21 15:10:47 docker-node-01 systemd[1]: docker.service: Service hold-off time over, scheduling restart.
```

其中最重要的資訊就是 `Error starting daemon: error initializing graphdriver: driver not supported`，原來是 kernel 更新之後 aufs driver 消失了。由於第一次遇到這種狀況，google 了老半天、問了朋友才知道解法。

## 解決問題

```
sudo apt-get update
sudo apt-get install linux-image-extra-$(uname -r) linux-image-extra-virtual aufs-tools
sudo reboot
```

接下來會重開機，開完之後再試試看應該就可以了

```
sudo service docker start
```

假如又碰到 `Error starting daemon: error initializing graphdriver: /var/lib/docker contains several valid graphdrivers: overlay2, aufs; Please cleanup or explicitly choose storage driver (-s <DRIVER>)`，若**你確定**你 container 的資料都在 `/var/lib/docker/aufs` 內，可以移除 `/var/lib/docker/overlay2` 資料夾，再 launch daemon 一次應該就可以了！

## References
1. https://github.com/moby/moby/issues/15651
2. https://askubuntu.com/questions/870889/cant-start-docker-on-ubuntu-16-04-with-driver-not-supported-error
3. https://askubuntu.com/questions/870889/cant-start-docker-on-ubuntu-16-04-with-driver-not-supported-error/870890#870890
4. https://github.com/moby/moby/issues/14026
5. https://docs.docker.com/engine/installation/linux/ubuntu/#recommended-extra-packages-for-trusty-1404
6. https://meta.discourse.org/t/ubuntu-updates-intefere-with-docker-and-aufs/25039/12
7. http://stackoverflow.com/questions/37110291/how-to-enable-aufs-on-debian
