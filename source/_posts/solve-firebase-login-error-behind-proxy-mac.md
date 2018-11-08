---
title: Solve "The Firebase CLI login request was rejected or an error occurred" when behind a proxy on macOS
date: 2018-11-08 13:13:47
tags:
---

**TL;DR:** Use [Proxifier](https://www.proxifier.com/) if you're using HTTP/SOCKS proxy

Today when I tried to login to Firebase CLI I ran into an issue that stopped me from logging in. After approving the login request on Google's login page, the page kept loading something (a page served on `localhost`) and eventually it went to this page:

![Screen-Shot-2018-04-13-at-9.46.12-AM](/content/images/2018/04/Screen-Shot-2018-04-13-at-9.46.12-AM.png)

In CLI:

```
▶ firebase login --debug

[2018-04-13T01:44:43.513Z] ----------------------------------------------------------------------
[2018-04-13T01:44:43.518Z] Command:       /Users/birkhoff/.nvm/versions/node/v6.9.4/bin/node /usr/local/bin/firebase login --debug
[2018-04-13T01:44:43.519Z] CLI Version:   3.18.3
[2018-04-13T01:44:43.519Z] Platform:      darwin
[2018-04-13T01:44:43.519Z] Node Version:  v6.9.4
[2018-04-13T01:44:43.520Z] Time:          Fri Apr 13 2018 09:44:43 GMT+0800 (CST)
[2018-04-13T01:44:43.520Z] ----------------------------------------------------------------------

? Allow Firebase to collect anonymous CLI usage and error reporting information? No

Visit this URL on any device to log in:
https://accounts.google.com/o/oauth2/xxxxxxxxxxxxx

Waiting for authentication...
[2018-04-13T01:44:52.780Z] >>> HTTP REQUEST POST https://accounts.google.com/o/oauth2/token
 { code: 'xxxxxxx',
  client_id: 'xxxxxxxx',
  client_secret: 'xxxxxxxxx',
  redirect_uri: 'http://localhost:9005',
  grant_type: 'authorization_code' }
 Fri Apr 13 2018 09:44:52 GMT+0800 (CST)
```

I searched on Google, and I came across this [StackOverflow answer](https://stackoverflow.com/a/41040601/2465955). Looks like there's a known bug that Firebase CLI can't work properly behind a proxy. I quickly realized I have environment variable `ALL_PROXY`, `http_proxy` and `https_proxy` set because I'm using a proxy.

The ultimate solution is to use a system-wide proxy, which in this case [Proxifier](https://www.proxifier.com/) is a very good choice, should you're using macOS. This kind of software makes **all** traffic go through a SOCKS5 proxy, so you won't have to manually set the env variable and therefore the problem gets solved.

![Screen-Shot-2018-04-13-at-9.55.42-AM](/content/images/2018/04/Screen-Shot-2018-04-13-at-9.55.42-AM.png)
