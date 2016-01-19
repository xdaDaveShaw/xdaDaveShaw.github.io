---
layout: post
status: publish
published: true
title: Dealing with NewsBlur and Large Feeds
date: '2014-05-28 00:54:02 +0100'
date_gmt: '2014-05-27 23:54:02 +0100'
categories:
- newsblur
---

**Update 19-Jan-2016**

As of 30-Sep-2015, Yahoo Pipes is dead, so this will no longer work, I'm just leaving this here for archive purposes now.

You can read about alternatives [here](http://readwrite.com/2015/06/08/yahoo-shuts-down-pipes).

Also, I submitted a [pull request](https://github.com/xdaDaveShaw/ploeh.github.com/commit/445f0f3a7780583e3207183baf7e788fee3c6d6a) to the ploeh blog in May 2015 that was merged and changed the RSS to limit to 10 posts.

----


I'm a premium [NewsBlur](http://newsblur.com) member, and have been ever Google decided to shutdown Google Reader. Mostly my experiences have been very good, with great support from Samuel when I needed it. 

However, there has been one issue nagging at me for quite a while and this is, I cannot get a feed to [Mark Seemann's blog](http://blog.ploeh.dk). I posted the problem on Get Satisfaction, [but Samuel was unable to help](https://getsatisfaction.com/newsblur/topics/cannot_add_feed_from_http_blog_ploeh_dk) due to the size of the feed. A few weeks ago a co-worker of mine mentioned [Yahoo Pipes](http://pipes.yahoo.com/) should be able to sort this, so I finally gave it a try. For those (like me until recently) who don't know what Yahoo Pipes is it's "a powerful composition tool to aggregate, manipulate, and mashup content from around the web".

After a few minutes tinkering, I had finally built a "pipe" that took the blog feed, performed a "truncate" operation to 10 posts and output the feed again. I then took the RSS feed to the pipe and handed it to NewsBlur and this time it coped perfectly with the feed.

![Piping hot]({{ site.contenturl }}Newsblur-Pipes.png)

I'm sure there's more I can do with it, but for now that's all I need.

So, if anyone else needs a "Last 10 Feeds from Ploeh.dk blog" you can get the [here](http://pipes.yahoo.com/pipes/pipe.run?_id=986288def53d9d4e838844061ad54d77&_render=rss).
