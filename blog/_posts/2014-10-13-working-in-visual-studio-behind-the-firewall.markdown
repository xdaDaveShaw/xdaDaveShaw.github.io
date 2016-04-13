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
**Updated 22-Mar-2016** *Added VS Code*

Working in an "Enterprise" type environment means lots of *fun* obstacles getting in the way of your day to day work &ndash; the corporate proxy is one of my challenges.

Since giving up on CNTLM Proxy due to instability and account lockouts, I haven't been able to connect to nuget.org from the package manager, view the Visual Studio Extension Gallery or even get any extension/product updates from Visual Studio.

This is a quick post with the changes I needed to get Visual Studio 2013 Update 4 (works on 2015 too), VS Code 0.10.11, NuGet 2.8 and Web Platform (Web PI) 5 to see past the corporate [Squid proxy](http://www.squid-cache.org).

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

# Visual Studio Code
Visual Studio Code is a tricky one to setup because it isn't .NET, it's all JavaScript based. Most of my information came from the GitHub [issue](https://github.com/microsoft/vscode/issues/69).

- Determine your proxy server and port. When you have a complicated proxy, this is a pain and it took me a while as I use an automatic configuration script. If it is a standard server/port combo, you're on an easier path.
- I usually configure IE with a script from a URL like this one: `http://proxy-server/script.dat`. This is a plain JS script which, after a bit of looking at, I discovered pointed to `proxy-cluster.fqdn.local:8881`.
- Now I have a server and port I need my authentication details. The format for these is `DOMAIN\User Name:P@ssword!` but has to be URL encoded. A simple online [URL encoded](http://meyerweb.com/eric/tools/dencoder/) translated that into: `DOMAIN%5CUser%20Name%3AP%40ssword!`
- Piece all this info into a single string like so: `http://DOMAIN%5CUser%20Name%3AP%40ssword!@proxy-cluster.fqdn.local:8881`
- Then add this into your User Settings in File, Preferences against the `"http.proxy"` value:

```JSON
// Place your settings in this file to overwrite the default settings
{
    "http.proxy": "http://DOMAIN%5CUser%20Name%3AP%40ssword!@proxy-cluster.fqdn.local:8881"
}
```
There are a lot of ways to mess this up, I almost gave up on VS Code after weeks of messing about, the removal of C# from base product made it "make or break time". If you are struggling I suggest you re-read the GitHub issue. The main tip I found useful was to pop-open the Developer Tools in VS Code (under Help) and in the JavaScript Console run: `require('url').parse('YOUR PROXY URL')` and check the output. 

Big thanks to [João Moreno](https://github.com/joaomoreno) for all his comments on the GitHub issue.

# Visual Studio

Setting up Visual Studio based on [this blog post](http://en.code-bude.net/2013/07/15/how-to-setup-a-proxy-server-in-visual-studio-2012/) by Raffael Herrmann.

 - Open the `devenv.exe.config` file. I find it by right clicking the Visual Studio shortcut, selecting Properties and then "Open File Location". If you have UAC enabled you will need to open it in a program running as Administrator.
 - Scroll to the end of the file and find the `system.net` section:

```xml
<!-- More -->
</system.data>
<system.net>
    <settings>
        <ipv6 enabled="true"/>
    </settings>
</system.net>
<appSettings>
<!-- More -->
```

- Add the following below `</settings>`:

```xml
<defaultProxy useDefaultCredentials="true" enabled="true">
    <proxy bypassonlocal="true" proxyaddress="http://proxy-server:3128" />
</defaultProxy>
```

- The final version will look something like this:

```xml
<system.net>
    <settings>
        <ipv6 enabled="true"/>
    </settings>
    <defaultProxy useDefaultCredentials="true" enabled="true">
        <proxy bypassonlocal="true" proxyaddress="http://proxy-server:3128" />
    </defaultProxy>
</system.net>
```
 
# Web Platform Installer

This was the same set of changes needed for Visual Studio, except with the `WebPlatformInstaller.exe.config` file, which I again obtained from the shortcut properties using "Open File Location".

# Thanks
 
Big thanks to [Eric Cain](https://twitter.com/arcain) and [Raffael Herrmann](https://twitter.com/pinguinmann) for enabling me to connect to the internet again :).