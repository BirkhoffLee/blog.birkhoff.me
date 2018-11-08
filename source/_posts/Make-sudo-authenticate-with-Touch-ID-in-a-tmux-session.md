---
title: Make sudo authenticate with Touch ID in a tmux session
tags:
permalink: make-sudo-authenticate-with-touch-id-in-a-tmux
id: 5b8ad03e0e36bb0001c2daef
updated: '2018-10-10 21:55:07'
date: 2018-09-02 01:45:34
---

After the recent switch to https://github.com/samoshkin/tmux-config, I have been fully working under tmux sessions. Recently I found that the Touch ID authentication for sudo haven't been working. I searched over the Internet and found out `pam_tid.so` itself is kinda incompatible with *tmux*.

To solve this, I had to use a simple hack (someone made the solution for us, thanks!). I use [fabianishere/pam_reattach](https://github.com/fabianishere/pam_reattach), a PAM module for reattaching to the authenticating user's per-session bootstrap namespace on macOS, and it's updated just 18 days ago as the time of writing!

To install `pam_reattach`, you will need to run the following commands to download sources, build and finally, install.

```
$ cd
$ git clone https://github.com/fabianishere/pam_reattach
$ cd pam_reattach
$ cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr $(pwd)
$ make
$ sudo make install
```

Ultimately, make sure `/etc/pam.d/sudo` looks like this in the beginning of file:

```
auth     optional     pam_reattach.so
auth     sufficient   pam_tid.so
...
```

(Note that on major macOS updates you need to re-do the whole process once again.)

# References
* https://github.com/fabianishere/pam_reattach
* https://apple.stackexchange.com/questions/259093/can-touch-id-for-the-mac-touch-bar-authenticate-sudo-users-and-admin-privileges/306324#306324
* https://superuser.com/questions/1342926/sudo-with-auth-sufficient-pam-tid-so-does-not-work-with-tmux/1348180
