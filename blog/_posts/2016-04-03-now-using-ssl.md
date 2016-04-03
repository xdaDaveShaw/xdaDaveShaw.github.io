---
layout: post
status: publish
published: true
title: Now using SSL
date: '2016-04-03 15:49:00 +0000'
date_gmt: '2016-04-03 16:49:00 +0100'
categories:
- Meta
---

Today I've changed over to using SSL by default.

![SSL in Chrome][3]

The main reason for moving is that SSL [gives better SEO][4] - and that my old blog was SSL so I'm sure there will be some SSL links scattered about the web. It also prevents and silly public networks injecting anything into any of my pages.

I'm using CloudFlare to secure to the communications from your browser to them. Thanks to Sheharyar Naseer for his [excellent guide][1] that got me up and running in no time, and to [DNSimple][2] for their excellent DNS Service that made it a piece of cake changing my Nameservers.

 [1]:https://sheharyar.me/blog/free-ssl-for-github-pages-with-custom-domains/
 [2]:https://dnsimple.com
 [3]:{{ site.contenturl }}ssl.png
 [4]:http://www.troyhunt.com/2015/08/were-struggling-to-get-traction-with.html