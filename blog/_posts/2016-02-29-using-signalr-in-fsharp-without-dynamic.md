---
layout: post
status: publish
published: true
title: Using SignalR in FSharp without Dynamic
date: '2016-02-29 21:13:00 +0000'
date_gmt: '2016-02-29 21:13:00 +0000'
categories:
- FSharp
---

I've been building an FSharp Dashboard by following along [this post][1] from [Louie Bacaj's][2] which was part of last years FSharp Advent calendar. I have to say it's a great post and has got me up and running in no time.

 > If you want to skip the story and get to the FSharp and SignalR part scroll down to **Changing the Hub**.

One small problem I noticed was that I could not use any of the features of FSharp Core v4. For example, the new `tryXXX` functions such as `Array.tryLast` were not available.

After a bit of digging I happened across the Project Properties which were stuck on `3.1.2.1`.

![Project Properties][3]

Turns out that the `FSharp.Interop.Dynamic` package is dependant on `FSharp.Core v3.1.2.1`.

So this turned into a challenge of how do I use SignalR without Dynamic. After a bit of googling I landed on
[this page][4] that showed Strongly Typed Hubs. So I knew it was possible...

#Removing Dependencies

The first step to fixing this was to remove the `FSharp.Core` dependencies I no longer needed, these were:

{% highlight powershell %}
Uninstall-Package FSharp.Interop.Dynamic 
Uninstall-Package Dynamitey
Uninstall-Package FSharp.Core
{% endhighlight %}
   
I then just browsed through the source and removed all the `open` declarations.

#Re-adding FSharp Core

Slight problem now, I no longer had any FSharp Core references, so I needed to add one in. 
I'm not sure if this is the best way to solve this, but I just copied and pasted these lines 
from a empty FSharp project I just created:

{% highlight xml %}
<Reference Include="mscorlib" />
<!--Add this bit-->
<Reference Include="FSharp.Core, Version=$(TargetFSharpCoreVersion), Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a">
    <Private>True</Private>
</Reference>
<!--End-->
<Reference Include="Newtonsoft.Json">
{% endhighlight %}
   
#Changing the Hub

Now all I had to do was update the code to use the statically typed hub.

First step was to create an interface for the `metricsHub`:

{% highlight fsharp %}
type IMetricsHub = 
    abstract member AddMessage: string -> unit
    abstract member BroadcastPerformance: PerfModel seq -> unit
    
Then change our `Hub` to inherit from the generic `Hub<T>`:
    
[<HubName("metricsHub")>]
type metricsHub() = 
    inherit Hub<IMetricsHub>() // < Generic version of our interface.
 {% endhighlight %}
 
And changed all the calls from:
 
     Clients.All?message(message)

to

     Clients.All.Message message
     
#Getting the Context

With SignalR you cannot just `new` up an instance of a `Hub`, you have to use `GlobalHost.ConnectionManager.GetHubContext<THub>`. The problem is that this gives you
and `IHubContext` which only exposes the dynamic interface again. A bit more googling and I found that
you need to pass our interface as a second generic parameter and you will get an `IHubContext<IMetricsHub>`.

So this:

     let context = GlobalHost.ConnectionManager.GetHubContext<metricsHub>()
     
Becomes:

     let context = GlobalHost.ConnectionManager.GetHubContext<metricsHub, IMetricsHub>()
     
Now you can call `Context.Clients.All.BroadcastPerformance` and not worry about that pesky dynamic any more.

#Conclusion

The documentation on SignalR isn't very good, it was easy enough to find out about the statically typed version, but finding out how to get one out of the context was a right pain.

 I've published a fork of Louies GitHub repo with four commits that show the steps needed to move from dynamic to 
 statically typed SignalR [here][5] so you can see the changes I needed to make.


 [1]:http://coding.fitness/f-powered-realtime-dashboard/
 [2]:https://github.com/lbacaj
 [3]:{{ site.contenturl }}fsharp-signalr-project-props.png
 [4]:http://www.asp.net/signalr/overview/guide-to-the-api/hubs-api-guide-server#stronglytypedhubs
 [5]:https://github.com/xdaDaveShaw/LouiesGuiAdventDash