---
layout: post
status: publish
published: true
title: Dealing with NewsBlur and Large Feeds
author:
  display_name: Dave Shaw
  login: DaveShaw
  email: dave@taeguk.co.uk
  url: http://taeguk.co.uk
author_login: DaveShaw
author_email: dave@taeguk.co.uk
author_url: http://taeguk.co.uk
wordpress_id: 762
wordpress_url: http://taeguk.co.uk/?p=762
date: '2014-05-28 00:54:02 +0100'
date_gmt: '2014-05-27 23:54:02 +0100'
categories:
- newsblur
tags: []
comments: []
---
<p align="left">I&rsquo;m a premium <a href="http:&#47;&#47;newsblur.com&#47;" target="_blank">NewsBlur<&#47;a> member, and have been ever Google decided to shutdown Google Reader. Mostly my experiences have been very good, with great support from Samuel when I needed it. <&#47;p>
<p align="left">However, there has been one issue nagging at me for quite a while and this is, I cannot get a feed to <a href="http:&#47;&#47;blog.ploeh.dk" target="_blank">Mark Seemann&rsquo;s blog<&#47;a>. I posted the problem on Get Satisfaction, <a href="https:&#47;&#47;getsatisfaction.com&#47;newsblur&#47;topics&#47;cannot_add_feed_from_http_blog_ploeh_dk" target="_blank">but Samuel was unable to help<&#47;a> due to the size of the feed. A few weeks ago a co-worker of mine mentioned <a href="http:&#47;&#47;pipes.yahoo.com&#47;" target="_blank">Yahoo Pipes<&#47;a> should be able to sort this, so I finally gave it a try. For those (like me until recently) who don&rsquo;t know what Yahoo Pipes is it&rsquo;s &ldquo;a powerful composition tool to aggregate, manipulate, and mashup content from around the web&rdquo;.<&#47;p>
<p align="left">After a few minutes tinkering, I had finally built a &ldquo;pipe&rdquo; that took the blog feed, performed a &ldquo;truncate&rdquo; operation to 10 posts and output the feed again. I then took the RSS feed to the pipe and handed it to NewsBlur and this time it coped perfectly with the feed.<&#47;p>
<p align="left"><a href="http:&#47;&#47;taeguk.co.uk&#47;wp-content&#47;uploads&#47;2014&#47;05&#47;Pipes.png"><img title="Pipes" style="border-left-width: 0px; border-right-width: 0px; background-image: none; border-bottom-width: 0px; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-top-width: 0px" border="0" alt="Pipes" src="http:&#47;&#47;taeguk.co.uk&#47;wp-content&#47;uploads&#47;2014&#47;05&#47;Pipes_thumb.png" width="354" height="301"><&#47;a><&#47;p>
<p>I&rsquo;m sure there&rsquo;s more I can do with it, but for now that&rsquo;s all I need.<&#47;p>
<p>So, if anyone else needs a &ldquo;Last 10 Feeds from Ploeh.dk blog&rdquo; you can get the <a href="http:&#47;&#47;pipes.yahoo.com&#47;pipes&#47;pipe.run?_id=986288def53d9d4e838844061ad54d77&amp;_render=rss" target="_blank">link here<&#47;a>.<&#47;p></p>
