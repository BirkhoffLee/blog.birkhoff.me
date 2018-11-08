---
title: Make cron send emails only on errors
tags:
permalink: make-cron-send-email-only-on-error
id: 5b5e624956639d0001318c9d
updated: '2018-07-30 09:05:10'
date: 2018-07-30 08:56:41
---

Stop using `>/dev/null 2>&1`.  Use https://habilis.net/cronic/.

Cronic (somehow aka `chronic`, do they refer to the same thing?) has been a perfect workaround of the design failure of cron.

According to the official website of Cronic:

> Cronic is a small shim shell script for wrapping cron jobs so that cron only sends email when an error has occurred. Cronic defines an error as any non-trace error output or a non-zero result code.

Clear enough. In other words, cronic only prints output when the script that it wraps encounters an issue, otherwise it runs silently.

On CentOS, install `chronic` with the following command:

```
$ yum install moreutils
```

and edit your crontab:

```
$ crontab -e
```

Remove `>/dev/null 2>&1`, add `chronic` at the beginning of the command, like so:

```
0 1 * * * cronic backup
```
