---
title: Build tmux on CentOS 7
categories:
  - linux
tags:
  - tmux
comments: true
toc: false
date: 2018-11-25 14:24:40
---

So I have been recently annoyed with some super strange display issues that tmux 2.7 on my server produces. After some digging I decided to re-build version 2.8 (which is the latest release as of time of writing) of tmux.
<!-- more -->

We’ll be grabbing the official tmux repo from https://github.com/tmux/tmux, build version 2.8 and install it. Note that you’ll need root privileges to install tmux.

```bash
$ git clone https://github.com/tmux/tmux.git
$ cd tmux
$ git checkout 2.8
$ sh autogen.sh
$ ./configure && make
$ sudo make install
$ tmux # profit
```
