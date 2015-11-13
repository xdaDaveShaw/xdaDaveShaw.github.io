---
layout: post
status: publish
published: true
title: Shut the Box is Live
date: '2015-11-13 16:18:00 +0000'
date_gmt: '2015-11-13 16:18:00 +0100'
categories:
- Development
---

Today I've just published my first App into the Windows and Windows Phone Store.

![Screenshot][3] 

Download link below, if you want to check it out. It's 100% free and no ads.

[![Windows Store Download][2]][4] 

It is a simple version of the pub game Shut the Box, I have page [here][1] with more information about game.

This was my first attempt at a Windows Application and I've really enjoyed the experience of building it. 
I tried to use as many new things to me as possible to learn as much as I can through the process. A quick list
of new things I've explorer whilst working on this are:

 - Git
 - Visual Studio Online Kanban for planning and tracking work (up until now I've only used TFS 2012.4).
 - TFS Build vNext.
 - Application Insights.
 - Custom MSBuild Project to encapsulate all restore/build/test workflows.
 - xUnit.net for Universal Apps (lots of beta's to test).

Working with the Windows Store was a bit of "hit and miss", for a while I could not see get to the "Dashboard" 
part of the site "because of my Azure account", or so I was told. This seemed to resolve itself eventually, but
was very annoying at the time. I was not offered any explanation, only that I should create a new Microsoft Account
to publish apps through, which I was not prepared to do.

It took 3 attempts to get the application through certification. Firstly it failed because I had not run the Application Certification Kit and had a transparent Windows tile that is not allowed.
The second failure was because Russia, Brazil, Korea and China require certification of anything that is a Game 
in the store. I decided not to publish it to those markets at the moment because I wanted it out there, and figuring
out how to complete the certification seemed like too much work. I may look into it again later, but for now I am happy.  

This application has been a long time coming, mostly down to my lack of free time and/or willingness to work on
it, but I'm glad it's finally published, now to try and release some updates and add some more nice features.

If you enjoy the game, please feel free to leave me a rood rating / comment in the Store.


 [1]:\shutthebox
 [2]:\shutthebox\store-icon.png
 [3]:\shutthebox\screenshot.png
 [4]:https://www.microsoft.com/en-us/store/apps/shut-the-box/9nblggh690qb