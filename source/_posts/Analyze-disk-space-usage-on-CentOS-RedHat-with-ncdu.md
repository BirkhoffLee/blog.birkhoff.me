---
title: Analyze disk space usage on CentOS / RedHat with ncdu
tags:
permalink: analyze-disk-space-usage-on-centos-redhat-with-ncdu
id: 5b6406df68ef6f00014c2d0c
updated: '2018-09-06 00:14:03'
date: 2018-08-03 15:40:15
---

[ncdu](https://dev.yorhel.nl/ncdu) is an interactive disk space analyzer software on Linux, which I found itself pretty convinent.

## Installation

It's pretty straightforward, install dependancies, configure, make and make install. Done.

```
$ yum install ncurses-devel ncurses wget -y
$ wget https://dev.yorhel.nl/download/ncdu-1.13.tar.gz
$ tar -zxvf ncdu-1.13.tar.gz
$ rm ncdu-1.13.tar.gz
$ cd ncdu-1.13
$ ./configure --prefix=/usr
$ make && sudo make install
```

## Usage

It's interactive. Use `?` to view help.

```
$ ncdu
```

## References
* https://unix.stackexchange.com/questions/3979/how-can-i-install-ncdu-on-red-hat
* https://www.cyberciti.biz/faq/linux-error-cursesh-no-such-file-directory/
* https://unix.stackexchange.com/questions/73818/how-to-find-free-disk-space-and-analyze-disk-usage
