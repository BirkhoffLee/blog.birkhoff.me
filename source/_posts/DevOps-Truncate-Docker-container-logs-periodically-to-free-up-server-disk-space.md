---
title: >-
  DevOps: Truncate Docker container logs periodically to free up server disk
  space
tags:
permalink: >-
  devops-truncate-docker-container-logs-periodically-to-free-up-server-disk-space
id: 5b45d282b1a8f00001d720e0
updated: '2018-08-30 17:34:39'
date: 2018-07-11 17:48:50
---

I've been disturbed by having my services unavailable on my machine because of "no space left on device". Every time I was forced to do some `df -h /` and `du -h /` commands and dig down to what leads to the lack of disk space.

Today I again encountered this issue and I'm done with it. I decided to find out what has been swallowing my disk space.

```
$ history
...
55  du -sh /*
56  du -sh /var
57  du -sh /var/*
58  du -sh /var/lib/*
59  du -sh /var/lib/docker/*
...
```

(make sure to `sudo su` first if you want to use `du` utility)

I ran `du -ch /var/lib/docker/containers/*/*-json.log`,  and I got an interesting result:

```
$ sudo sh -c "du -ch /var/lib/docker/containers/*/*-json.log"
...
13G    /var/lib/docker/containers/../..-json.log
...
```

Holy crap. That's a log file of 13 gigabytes. I then moved to Google on how to clear Docker logs because there's no official implementation of so. The fastest and cleanest way is `sudo sh -c 'truncate -s 0 /var/lib/docker/containers/*/*-json.log'`, from [this StackOverflow post](https://stackoverflow.com/a/43570083/2465955).

Problem solved. The next thing is how do I prevent this from happening again in the future? And under the previous linked Stackoverflow answer, here's a quick answer to my next question: [Rotate the log periodically](https://stackoverflow.com/a/46400533/2465955).

Create `/etc/logrotate.d/docker-logs`, and add the following to the file:

```
/var/lib/docker/containers/*/*.log {
 rotate 7
 daily
 compress
 size=50M
 missingok
 delaycompress
 copytruncate
}
```

And if everything is fine, *logrotate.d* will do the jobs.
