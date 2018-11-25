---
title: Redirect domains to specific URLs with Traefik
tags:
permalink: redirect-domains-to-specific-urls-with-traefik
id: 5bcb685095c91c00010ae1cc
updated: '2018-10-21 02:03:05'
date: 2018-10-21 01:39:28
---

I recently again needed to redirect a specific domain to a URL. For example redirecting `google.birkhoff.me` to `https://www.google.com`.

I used to run some Docker containers which runs some web servers that redirect HTTP requests to make this work. I knew from the beginning that it wasn't the most elegant or efficient way to do so, but I didn't have any other idea for that. A friend once told me Firebase will do the job, but it's limited to redirecting to a domain, not a URL, so no.

So today I was about to do the same thing (you can see me forked [MorbZ/docker-web-redirect][1] to [BirkhoffLee/docker-web-redirect today][2]), changed a bit in the repo and when I launched it up. All of a sudden when I was dealing with Traefik stuff I thought Traefik could've been doing the job for me, if I configured it correctly.

After searching around for a bit, some related GitHub issues came up, without the exact solutions. My workaround has some benefits:

* does not need any other program to handle requests, therefore it's efficient
* built-in regex redirection support
* centralized, easier to manage

This is the configuration block that you would want to put in your `traefik.toml`:

	[file]
	
	  [backends]
	
	    [backends.fake]
	      [backends.fake.servers.s1]
	        url="http://1.2.3.4"
	
	  [frontends]
	
	    [frontends.r1]
	      backend = "fake"
	      [frontends.r1.routes.host]
	        rule = "Host:test.birkhoff.me"
	      [frontends.r1.redirect]
	        regex = "^https?://test.birkhoff.me/(.*)"
	        replacement = "https://google.com"
	        permanent = true
	
	    [frontends.r2]
	      backend = "fake"
	      [frontends.r2.routes.host]
	        rule = "Host:another-test.birkhoff.me"
	      [frontends.r2.redirect]
	        regex = "^https?://another-test.birkhoff.me/(.*)"
	        replacement = "https://twitter.com/$1"
	        permanent = false
	
	    # so forth..

I hope I can get a centralized, web-based management panel that runs on a Docker container so I can manage these stuff more efficiently. If you have any other solutions to this topic, please comment down below to let me know!

[1]:	https://github.com/MorbZ/docker-web-redirect
[2]:	https://github.com/BirkhoffLee/docker-web-redirect