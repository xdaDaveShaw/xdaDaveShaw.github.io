---
layout: post
status: publish
published: true
title: TFS 2015 does not support 2012 build agents
date: '2016-11-10 20:49:00 +0000'
date_gmt: '2016-11-10 20:49:00 +0000'
categories:
- TFS
---

This post is part PSA, part debugging story.

The important bit:

# Team Foundation Server 2012 XAML Build Agents do not work with TFS 2015

I discover this fact the weekend just gone whilst performing an upgrade to TFS 2015.3 from TFS 2012.4.

The plan was to only upgrade the TFS Server and leave the build infrastructure running on TFS 2012.
This seemed like a sound idea as I know Microsoft care about compatibility, and the upgrade was more complicated
than your usual one. I figured it would just keep working and that I'd upgrade the build agents later, boy was I wrong.

I may have even checked the [documentation][1], which does not show a compatibility, but it isn't explicitly called out,
so I could have glanced over it.

![TFS build compatibility][2]
*Look - No 2012*

The problems with TFS 2012 build agents against TFS 2015 manifested as two different errors when I queued a build without a Drop Location.
Queuing a build with a drop location worked just fine.

## Error 1 - Build agents not using the FQDN

The build infrastructure runs on a different domain to the Team Foundation Server.

We have `tfs-server.corp.com` for TFS and `build-server.corp-development.com` for builds.

The error manifested as:

![FQDN error message][3]

The error that appeared twice was not very helpful.

 > An error occurred while copying diagnostic activity logs to the drop location. Details: An error occurred while sending the request.

I eventually debugged this (details later) and found out that the last task on the build agent
was trying to access `tfs-server` with no DNS suffix of `.corp.com` to publish some logs.
As a temporary workaround I bobbed an entry in the [hosts][4] file entry to make `tfs-server` point to the actual IP of the TFS server.

## Error 2 - the bad request

With the all the steps of the build resolving the server name, I came across the second error.

![Bad request error message][5]

The error message was still no more use than the last one:

 > An error occurred while copying diagnostic activity logs to the drop location. Details: TF270002: An error occurred copying files from 'C:\Users\tfsbuild\AppData\Local\Temp\BuildAgent\172\Logs\151436\LogsToCopy\ActivityLog.AgentScope.172.xml' to 'ActivityLog.AgentScope.172.xml'. Details: BadRequest: Bad Request
 >
 > An error occurred while copying diagnostic activity logs to the drop location. Details: An error occurred while sending the request.

My debugging would lead me to see that this was caused by TFS returning an HTTP 400 (Bad Request) for the exact same step as the first error.

It was at this point I figured something was really wrong and started searching for compatibility problems. In my effort to find a KB
or update I re-checked the documentation and noticed the lack of support as well as finding [an MSDN forum post][6] from RicRak where they
solved the problem by upgrading their agents off of TFS 2012.

## Solution

My solution was to upgrade our entire build infrastructure (some 9/10 servers) to TFS 2015, and discovering you **must** install VS2015 on
the servers too to get the Test Runner to work.

One day of diagnosis and testing to get to the point of knowing TFS 2015 build agents would solve the problem **and** still build our codebase.
Another half-day was spend upgrading all the servers.

# Diagnostics

How do you figure out when something like this goes wrong? TFS diagnostic logging did not provide any more information than minimum logging did.
The error only appeared at the very end of a build, it wasn't related to a step in the XAML workflow, nor any variables in the build process.

The solution (as always) came from [Charlie Kilian][7] on Stack Overflow.

I stopped the Build Service and opened up `TFSBuildServiceHost.exe.config` and added the following section:

```xml
<system.diagnostics>
    <sources>
        <source name="System.Net" tracemode="includehex" maxdatasize="1024">
            <listeners>
                <add name="System.Net"/>
            </listeners>
        </source>
    </sources>
    <switches>
        <add name="System.Net" value="Verbose"/>
    </switches>
    <sharedListeners>
        <add name="System.Net"
            type="System.Diagnostics.TextWriterTraceListener"
            initializeData="C:\Logs\network.log" />
    </sharedListeners>
    <trace autoflush="true"/>
</system.diagnostics>
```

Then restarted the build service and ran the smallest build I could to produce minimal logs.

The log folder looked something like this:

![Log files on disk][8]

The `network.log` file had a few errors, but nothing fatal looking, so I looked in the other files for errors and finally found this line:

```plain
System.Net Error: 0 : [4916] Exception in HttpWebRequest#13319471:: - The remote name could not be resolved: 'tfs-server'.
```

That was proceeded by:

```plain
System.Net Verbose: 0 : [4928] HttpWebRequest#13319471::HttpWebRequest(http://tfs-server:8080/tfs/DefaultCollection/_apis/resources/containers/122598?itemPath=logs%2FActivityLog.AgentScope.172.xml#752534963)
```

Here you can see the server name without the necessary DNS suffix during some HTTP POST to `_apis/resources/containers`.

This was the point I added the hosts file entry and then got the next error.

For the second error I repeated the diagnostic logging steps and this time found the following errors (searching for Bad Request):

```plain
System.Net Information: 0 : [16628] Connection#50276392 - Received status line: Version=1.1, StatusCode=400, StatusDescription=Bad Request.
```

By tracing the ID (in this case `16628`) back up the file I found it was a call to the same endpoint, but this time a PUT:

```plain
System.Net Information: 0 : [16628] HttpWebRequest#9100089 - Request: PUT /tfs/DefaultCollection/_apis/resources/containers/122603?itemPath=logs%2FActivityLog.AgentScope.59.xml HTTP/1.1
```

This was the point I gave up thinking this could be fixed by a configuration change.

# Conclusion

I wish I had read something like this before I planned the weekend. I did do testing, but because testing TFS in live is risky I had most of the
test instance network isolated and that required a lot of configurations; I just thought this error was just configuration based, lesson well and 
truly learned.

It would have been nice to see this called out more explicitly on MSDN. In my opinion these are two bugs that Microsoft decided not to fix
in the TFS 2012 product life-cycle.

On the plus side, I learned some really neat debugging skills I didn't know before.

Remember, if you're upgrading from TFS 2012, plan to upgrade your build agents at the same time!

 [1]:https://www.visualstudio.com/en-us/docs/setup-admin/requirements
 [2]:{{ site.contenturl }}tfs2015-build-compat-table.png
 [3]:{{ site.contenturl }}tfs2015-build-fqdn-error.png
 [4]:https://en.wikipedia.org/wiki/Hosts_(file)
 [5]:{{ site.contenturl }}tfs2015-build-bad-request.png
 [6]:https://social.msdn.microsoft.com/Forums/office/en-US/68d84ffc-3bcc-41cc-80f0-8fc778894ee4/tfs-online-build-fails-on-local-build-server-with-tf270016-tf270002?forum=tfsbuild
 [7]:http://stackoverflow.com/questions/15143107/httpclient-httprequestexception
 [8]:{{ site.contenturl }}tfs2015-build-log-files.png