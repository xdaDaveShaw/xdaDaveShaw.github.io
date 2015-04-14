---
layout: post
status: publish
published: true
title: UNC to URI Path Converter
author:
  display_name: Dave Shaw
  login: DaveShaw
  email: dave@taeguk.co.uk
  url: http://taeguk.co.uk
author_login: DaveShaw
author_email: dave@taeguk.co.uk
author_url: http://taeguk.co.uk
wordpress_id: 972
wordpress_url: http://taeguk.co.uk/?p=972
date: '2014-07-31 22:47:38 +0100'
date_gmt: '2014-07-31 21:47:38 +0100'
categories:
- Windows Azure
- Development
tags: []
comments: []
---
<p>Yesterday, at work, I was trying to help someone enter a UNC path (<font color="#4f81bd">\\server\share\file.txt<&#47;font>) into a hyperlink control on our application, but it was rejecting it because it wasn&rsquo;t a valid hyperlink. I discovered that you could enter a URI path (<font color="#4f81bd">file:&#47;&#47;server&#47;share&#47;file.txt<&#47;font>) and it worked fine. Problem solved? Not exactly, otherwise I wouldn&rsquo;t have anything to write about.<&#47;p>
<p>The issue was that the users are non-technical folk and they can&rsquo;t just fire up Linqpad and run the following code like I did to test if it worked:<&#47;p>
<pre class="brush: csharp;">new Uri(@"\\server\share\file.txt").AbsoluteUri<br />
<&#47;pre></p>
<p>The rules around converting UNC paths to URI&rsquo;s gets a little tricky when you have paths with spaces and special characters in them, so I thought I would Google&#47;Bing for an online UNC to URI Path Converter&hellip; turns out I couldn&rsquo;t find one, so I did what every software developer does, <a href="http:&#47;&#47;pathconverter.azurewebsites.net&#47;">writes one<&#47;a>.<&#47;p></p>
<p>&nbsp;<&#47;p></p>
<p><a title="Online UNC to URI Path Converter" href="http:&#47;&#47;pathconverter.azurewebsites.net&#47;"><img title="Screenshot" style="border-left-width: 0px; border-right-width: 0px; background-image: none; border-bottom-width: 0px; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-top-width: 0px" border="0" alt="Screenshot" src="http:&#47;&#47;taeguk.co.uk&#47;wp-content&#47;uploads&#47;2014&#47;07&#47;Screenshot.png" width="644" height="309"><&#47;a><&#47;p></p>
<p>This took a little over an evening, mostly due to me been unfamiliar with CSS, JQuery (I know, but it&rsquo;s quicker than Vanilla JS) and TypeScript (first time I&rsquo;ve ever used it).<&#47;p></p>
<p>The entire website was setup in my <a href="http:&#47;&#47;visualstudio.com&#47;" target="_blank">VS Online<&#47;a> account and linked to my Azure site as part of the new &ldquo;one ASP.NET&rdquo; setup template, and I even got to add Application Insights as part of the setup template. A few clicks on the Azure Portal and I had a Continuous Delivery Build Definition setup in VS Online. All I had to do then was push changes from my local git repository to VS Online and TFS would build the code and if it succeeded the site was updated within a few minutes.<&#47;p></p>
<p align="left">The site works by making a quick AJAX HTTP GET when you click the Convert button to a ASP.NET MVC site to use the <font face="Consolas"><a href="http:&#47;&#47;msdn.microsoft.com&#47;en-us&#47;library&#47;system.uri(v=vs.110).aspx" target="_blank">Uri<&#47;a><&#47;font> class in .NET. That&rsquo;s about it.<&#47;p></p>
<p>Here&rsquo;s the link to anyone who want&rsquo;s to use it: <a href="http:&#47;&#47;pathconverter.azurewebsites.net&#47;">http:&#47;&#47;pathconverter.azurewebsites.net&#47;<&#47;a><&#47;p></p>
