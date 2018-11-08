---
title: Serve Traefik's internal dashboard behind Traefik itself
tags: |-

  - server
  - installation
  - introduce
  - docker
  - devops
  - tutorial
  - web
  - proxy
  - network
permalink: serve-traefiks-internal-dashboard-behind-traefik
id: 5b550655e5538500019459a9
updated: '2018-07-23 06:47:46'
date: 2018-07-23 06:33:57
---

I have recently switched from [jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy) + [JrCs/docker-letsencrypt-nginx-proxy-companion](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion) to a more powerful reverse proxy called [Traefik](https://traefik.io/). Traefik has built-in ACME support, can be used as a load-balancer and (most importantly) has official Docker support!

When I was configuring Traefik's internal dashboard (the good-looking web UI), I was thinking of serving it behind the proxy itself. But the documantation didn't say how to do it. It only mentioned to serve the dashboard on a port other than 80 or 443, so you can only access with, for example, 111.222.333.444:7777. I wanted to use something like [traefik.birkhoff.me](https://traefik.birkhoff.me).

Well, it needs a tricky hack.

You simply define a new entrypoint, I call it "traefik" here. Set the port number to anything you like. Finally give the Traefik container some traefik labels as you would to normal web containers.

Traefik.toml:
```yaml
[entryPoints]
  [entryPoints.http]
    address = ":80"

    [entryPoints.http.redirect]
      entryPoint = "https"
      permanent = true

  [entryPoints.https]
    address = ":443"
    compress = true
    [entryPoints.https.tls]

  [entryPoints.traefik]
    address = ":9987"
    compress = true

    [entryPoints.traefik.auth.basic]
      users = ["123:456"]

[api]
  entryPoint = "traefik"
  dashboard = true
```

docker-compose.yml:
```yaml
version: '3'

services:
  traefik:
    ......
    expose:
      - 9987
    labels:
      - "traefik.docker.network=traefik"
      - "traefik.enable=true"
      - "traefik.basic.frontend.rule=Host:traefik.birkhoff.me"
      - "traefik.basic.port=9987"
      - "traefik.basic.protocol=http"
    ......
```

It's somehow stupid tho.
