---
layout: post
status: publish
published: true
title: Working in Visual Studio behind the Firewall
author:
  display_name: Dave Shaw
  login: DaveShaw
  email: dave@taeguk.co.uk
  url: http://taeguk.co.uk
author_login: DaveShaw
author_email: dave@taeguk.co.uk
author_url: http://taeguk.co.uk
wordpress_id: 1012
wordpress_url: http://taeguk.co.uk/?p=1012
date: '2014-10-13 22:38:56 +0100'
date_gmt: '2014-10-13 21:38:56 +0100'
categories:
- Development
- Visual Studio
- nuget
tags: []
comments: []
---
<p>Working in an &ldquo;Enterprise&rdquo; type environment means lots of <em>fun <&#47;em>obstacles getting in the way of your day to day work &ndash; the corporate proxy is one of my challenges.</p>
<p>Since giving up on CNTLM Proxy, I haven't been able to connect to nuget.org from the package manager, view the Visual Studio Extension Gallery or even get any extension&#47;product updates from Visual Studio.</p>
<p align="left">This is a quick post with the changes I needed to get Visual Studio 2013 Update 3, NuGet 2.8 and Web Platform (Web PI) 5 to see past the corporate <a href="http:&#47;&#47;www.squid-cache.org&#47;">Squid proxy<&#47;a>.<&#47;p></p>
<h3>NuGet<&#47;h3><br />
Configuring NuGet based on <a href="http:&#47;&#47;stackoverflow.com&#47;a&#47;15463892&#47;383710">this Stack Overflow answer<&#47;a> by arcain.</p>
<p>Running <span style="font-family: Consolas;">nuget.exe<&#47;span> with the following switches will allow NuGet to use and authenticate with the proxy:</p>
<pre>nuget.exe config -set http_proxy=http:&#47;&#47;proxy-server:3128<br />
nuget.exe config -set http_proxy.user=DOMAIN\Dave<br />
nuget.exe config -set http_proxy.password=MyPassword<br />
<&#47;pre><br />
It will put the values into your <span style="font-family: Consolas;">nuget.config<&#47;span> file (with the password encrypted).</p>
<pre class="brush: xml; gutter: false;"><configuration><br />
    <config><br />
        <add key="http_proxy" value="http:&#47;&#47;proxy-server:3128" &#47;><br />
        <add key="http_proxy.user" value="DOMAIN\Dave" &#47;><br />
        <add key="http_proxy.password" value="base64encodedHopefullyEncryptedPassword" &#47;><br />
    <&#47;config><br />
<&#47;configuration><br />
<&#47;pre><br />
Once Visual Studio is restarted, it should be able to see through the proxy.</p>
<p>As per the comments on the answer some people might have success without the password &ndash; sadly, not in my case. Also, remember if you have to change your password (as I have to every month or so) you will need to re-enter your password.</p>
<h3>Visual Studio<&#47;h3><br />
Setting up Visual Studio based on <a href="http:&#47;&#47;en.code-bude.net&#47;2013&#47;07&#47;15&#47;how-to-setup-a-proxy-server-in-visual-studio-2012&#47;">this blog post<&#47;a> by Raffael Herrmann.</p>
<ol>
<li>Open the <span style="font-family: Consolas;">devenv.exe.config<&#47;span> file. I find it by right clicking the Visual Studio shortcut, selecting Properties and then &ldquo;Open File Location&rdquo;. If you have UAC enabled you will need to open it in a program running as Administrator.<&#47;li>
<li>Scroll to the end of the file and find the <span style="font-family: Consolas;">system.net<&#47;span> section:
<pre class="brush: xml; gutter: false;"><!-- More --><br />
<&#47;system.data><br />
<system.net><br />
    <settings><br />
        <ipv6 enabled="true"&#47;><br />
    <&#47;settings><br />
<&#47;system.net><br />
<appSettings><br />
<!-- More --><br />
<&#47;pre><br />
<&#47;li></p>
<li>Add the following below <span style="font-family: Consolas;"><&#47;settings><&#47;span>:
<pre class="brush: xml; gutter: false;"><defaultProxy useDefaultCredentials="true" enabled="true"></p>
<proxy bypassonlocal="true" proxyaddress="http:&#47;&#47;proxy-server:3128" &#47;>
<&#47;defaultProxy><br />
<&#47;pre><br />
<&#47;li></p>
<li>The final version will look something like this:
<pre class="brush: xml; gutter: false;"><system.net><br />
    <settings><br />
        <ipv6 enabled="true"&#47;><br />
    <&#47;settings><br />
    <defaultProxy useDefaultCredentials="true" enabled="true"></p>
<proxy bypassonlocal="true" proxyaddress="http:&#47;&#47;proxy-server:3128" &#47;>
    <&#47;defaultProxy><br />
<&#47;system.net><br />
<&#47;pre><br />
<&#47;li><br />
<&#47;ol></p>
<h3>Web Platform Installer<&#47;h3><br />
This was the same set of changes needed for Visual Studio, except with the <span style="font-family: Consolas;">WebPlatformInstaller.exe.config<&#47;span> file, which I again obtained from the shortcut properties using &ldquo;Open File Location&rdquo;.</p>
<h3>Thanks<&#47;h3></p>
<p align="left">Big thanks to <a href="https:&#47;&#47;twitter.com&#47;arcain">Eric Cain<&#47;a> and <a href="https:&#47;&#47;twitter.com&#47;pinguinmann">Raffael Herrmann<&#47;a> for enabling me to connect to the internet again <img class="wlEmoticon wlEmoticon-smile" style="border-style: none;" src="http:&#47;&#47;taeguk.co.uk&#47;wp-content&#47;uploads&#47;2014&#47;10&#47;wlEmoticon-smile.png" alt="Smile" &#47;>.<&#47;p></p>
