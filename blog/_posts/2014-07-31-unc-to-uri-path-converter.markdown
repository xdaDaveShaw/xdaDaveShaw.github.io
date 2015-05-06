---
layout: post
status: publish
published: true
title: UNC to URI Path Converter
date: '2014-07-31 22:47:38 +0100'
date_gmt: '2014-07-31 21:47:38 +0100'
categories:
- Windows Azure
- Development
---
Yesterday, at work, I was trying to help someone enter a UNC path (`\\server\share\file.txt`) into a hyperlink control on our application, but it was rejecting it because it wasn't a valid hyperlink. I discovered that you could enter a URI path (`file://server/share/file.txt`) and it worked fine. Problem solved? Not exactly, otherwise I wouldn't have anything to write about.<&#47;p>

The issue was that the users are non-technical folk and they can't just fire up Linqpad and run the following code like I did to test if it worked:

    new Uri(@"\\server\share\file.txt").AbsoluteUri

The rules around converting UNC paths to URI's gets a little tricky when you have paths with spaces and special characters in them, so I thought I would Google/Bing for an online UNC to URI Path Converter... turns out I couldn't find one, so I did what every software developer does, [writes one](http://pathconverter.azurewebsites.net/).

![Path Converter]({{ site.contenturl }}PathConverter.png)

This took a little over an evening, mostly due to me been unfamiliar with CSS, JQuery (I know, but it's quicker than Vanilla JS) and TypeScript (first time I've ever used it).

The entire website was setup in my VS Online account and linked to my Azure site as part of the new "one ASP.NET" setup template, and I even got to add Application Insights as part of the setup template. A few clicks on the Azure Portal and I had a Continuous Delivery Build Definition setup in VS Online. All I had to do then was push changes from my local git repository to VS Online and TFS would build the code and if it succeeded the site was updated within a few minutes.

The site works by making a quick AJAX HTTP GET when you click the Convert button to a ASP.NET MVC site to use the [`URI`](http://msdn.microsoft.com/en-us/library/system.uri(v=vs.110).aspx) class in .NET. That's about it.
    
Here's the link to anyone who want's to use it: [http://pathconverter.azurewebsites.net/](http://pathconverter.azurewebsites.net/)
