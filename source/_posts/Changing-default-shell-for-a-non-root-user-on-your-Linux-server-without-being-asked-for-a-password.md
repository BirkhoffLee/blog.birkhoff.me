---
title: >-
  Changing default shell for a non-root user on your Linux server without being
  asked for a password
tags:
permalink: >-
  changing-default-shell-for-a-non-root-user-on-your-linux-server-without-being-asked-for-a-password
id: 5b57f048e5538500019459be
updated: '2018-07-25 11:40:08'
date: 2018-07-25 11:36:40
---

When running `/usr/bin/chsh -s $(which zsh)`, chsh asked for a password, but there's no password for my current user. If running this using sudo, `root`'s default shell gets changed.

Simple & fast solution: add the following line to the top of `/etc/pam.d/chsh`
```
auth       sufficient   pam_shells.so
```

If there's `auth       required   pam_shells.so`, change `required` to `sufficient`.

(I personally suggest to revert the changes to `/etc/pam.d/chsh` after you finished changing the shell)
