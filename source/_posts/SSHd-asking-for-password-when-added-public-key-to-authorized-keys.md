---
title: SSHd asking for password when added public key to authorized_keys
tags:
permalink: sshd-asking-password-added-key
id: 5b57e3e7e5538500019459b8
updated: '2018-08-22 15:04:45'
date: 2018-07-25 10:43:51
---

It should be permission issues.

```
$ chmod 700 ~/.ssh
$ chmod 600 ~/.ssh/authorized_keys
```
