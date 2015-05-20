---
layout: post
status: publish
published: true
title: Working in Visual Studio behind the Firewall
date: '2014-10-13 22:38:56 +0100'
date_gmt: '2014-10-13 21:38:56 +0100'
categories:
- Development
- Visual Studio
- nuget
---
Working in an "Enterprise" type environment means lots of *fun * obstacles getting in the way of your day to day work &ndash; the corporate proxy is one of my challenges.

Since giving up on CNTLM Proxy, I haven't been able to connect to nuget.org from the package manager, view the Visual Studio Extension Gallery or even get any extension&#47;product updates from Visual Studio.

This is a quick post with the changes I needed to get Visual Studio 2013 Update 4, NuGet 2.8 and Web Platform (Web PI) 5 to see past the corporate [Squid proxy](http://www.squid-cache.org).

# NuGet

Configuring NuGet based on [this Stack Overflow answer](http://stackoverflow.com/a/15463892/383710) by arcain.

Running `nuget.exe` with the following switches will allow NuGet to use and authenticate with the proxy:

    nuget.exe config -set http_proxy=http://proxy-server:3128
    nuget.exe config -set http_proxy.user=DOMAIN\Dave
    nuget.exe config -set http_proxy.password=MyPassword

It will put the values into your `nuget.config` file (with the password encrypted)

{% highlight xml %}
<configuration>
    <config>
        <add key="http_proxy" value="http://proxy-server:3128" />
        <add key="http_proxy.user" value="DOMAIN\Dave" />
        <add key="http_proxy.password" value="base64encodedHopefullyEncryptedPassword" />
    </config>
</configuration>
{% endhighlight %} 

Once Visual Studio is restarted, it should be able to see through the proxy.

As per the comments on the answer some people might have success without the password &ndash; sadly, not in my case. Also, remember if you have to change your password (as I have to every month or so) you will need to re-enter your password.

# Visual Studio

Setting up Visual Studio based on [this blog post](http://en.code-bude.net/2013/07/15/how-to-setup-a-proxy-server-in-visual-studio-2012/) by Raffael Herrmann.

 - Open the `devenv.exe.config` file. I find it by right clicking the Visual Studio shortcut, selecting Properties and then "Open File Location". If you have UAC enabled you will need to open it in a program running as Administrator.
 - Scroll to the end of the file and find the `system.net` section:

{% highlight xml %}
<!-- More -->
</system.data>
<system.net>
    <settings>
        <ipv6 enabled="true"/>
    </settings>
</system.net>
<appSettings>
<!-- More -->
{% endhighlight %} 

- Add the following below `</settings>`:

{% highlight xml %}
<defaultProxy useDefaultCredentials="true" enabled="true">
    <proxy bypassonlocal="true" proxyaddress="http://proxy-server:3128" />
</defaultProxy>
{% endhighlight %} 

- The final version will look something like this:

{% highlight xml %}
<system.net>
    <settings>
        <ipv6 enabled="true"/>
    </settings>
    <defaultProxy useDefaultCredentials="true" enabled="true">
        <proxy bypassonlocal="true" proxyaddress="http://proxy-server:3128" />
    </defaultProxy>
</system.net>
{% endhighlight %}
 
# Web Platform Installer

This was the same set of changes needed for Visual Studio, except with the `WebPlatformInstaller.exe.config` file, which I again obtained from the shortcut properties using "Open File Location".

# Thanks
 
Big thanks to [Eric Cain](https://twitter.com/arcain) and [Raffael Herrmann](https://twitter.com/pinguinmann) for enabling me to connect to the internet again :).