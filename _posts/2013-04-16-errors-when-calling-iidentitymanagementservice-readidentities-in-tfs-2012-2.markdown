---
layout: post
status: publish
published: true
title: Errors when calling IIdentityManagementService ReadIdentities() in TFS 2012.2
author:
  display_name: Dave Shaw
  login: DaveShaw
  email: dave@taeguk.co.uk
  url: http://taeguk.co.uk
author_login: DaveShaw
author_email: dave@taeguk.co.uk
author_url: http://taeguk.co.uk
wordpress_id: 122
wordpress_url: http://taeguk.azurewebsites.net/?p=122
date: '2013-04-16 20:58:00 +0100'
date_gmt: '2013-04-16 20:58:00 +0100'
categories:
- TFS
tags: []
comments: []
---
<p>Since upgrading to TFS 2012.2 (from Update 1) I have been seeing the following error in a couple of places:<&#47;p>
<pre class="brush: plain;">Server was unable to process request. ---><br />
There was an error generating the XML document. ---><br />
TF20507: The string argument contains a character that is not valid:'u8203'.<br />
Correct the argument, and then try the operation again.<br />
<&#47;pre></p>
<p>It first appeared when loading VS2012.2 with TFS Sidekicks 4.5 installed. It also appeared when I called <font face="Consolas">IIdentityManagementService.ReadIdentities()<&#47;font> via the TFS 2012 Object Model. I guess this is what TFS Sidekicks is calling under the covers.<&#47;p></p>
<p>It turned out that this was caused by the <a href="http:&#47;&#47;www.fileformat.info&#47;info&#47;unicode&#47;char&#47;200b&#47;index.htm" target="_blank">Zero Width Space Unicode character<&#47;a> (\u200b) been present in a Team's Description field. Some of our users had copied and pasted into there and brought it along from somewhere, where it came from I'll probably never know.<&#47;p></p>
<p>To track down which Team had this problem was quite a trek. Firstly, this doesn't happen using the V10 (TFS 2010) Object Model, only the V11 Team Foundation client assembly references. <&#47;p></p>
<p>Using the following code in my <a href="http:&#47;&#47;taeguk.co.uk&#47;2013&#47;01&#47;23&#47;MyLinqpadTFSTemplate.aspx">TFS Template<&#47;a> (2012 Version) as a base:<&#47;p>
<pre class="brush: csharp;">var managementService =<br />
    tfs.GetService<IIdentityManagementService>();<br />
var members =<br />
    managementService<br />
    .ReadIdentity(<br />
        GroupWellKnownDescriptors.EveryoneGroup,<br />
        MembershipQuery.Expanded,<br />
        ReadIdentityOptions.None);<br />
    .Members;<br />
<&#47;pre></p>
<p>I then call this method to get the crash:<&#47;p>
<pre class="brush: csharp;">var nodeMembers =<br />
    managementService<br />
    .ReadIdentities(<br />
        members,<br />
        MembershipQuery.Expanded,<br />
        ReadIdentityOptions.ExtendedProperties);<br />
<&#47;pre></p>
<p>The problem is, in my TFS Instance, there are 634 "members" and I had no idea which one might be causing the problem:<&#47;p></p>
<p>Replacing the above line with a simple loop and try&hellip;catch block reduced that for me:<&#47;p>
<pre class="brush: csharp;">foreach (var member in members)<br />
{<br />
    try<br />
    {<br />
        var nodeMembers =<br />
            managementService<br />
            .ReadIdentities(<br />
                new [] { member, },<br />
                MembershipQuery.Expanded,<br />
                ReadIdentityOptions.ExtendedProperties);<br />
    }<br />
    catch (Exception e)<br />
    {<br />
        e.Dump(a.Identifier);<br />
    }<br />
}<br />
<&#47;pre></p>
<p>I now had the Identity of the member with an issue, the problem I now faced was getting the name of the member.<&#47;p></p>
<p>A typical Identity looks like this:<&#47;p></p>
<p><font face="Consolas">S-1-9-<strong>1441374244<&#47;strong>-17626364-2447400142-3087036873-88942238-1-3433204373-3394714127-2914434643-4144131896<&#47;font><&#47;p></p>
<p>In the end I fired up SQL Profiler, pointed it at TFS and re-ran my code snippet. I then stopped the trace and searched for the first part my Identity: 1441374244. This led me to the following SQL statement:<&#47;p>
<pre class="brush: sql;">declare @p3 dbo.typ_KeyValuePairInt32StringVarcharTable;<br />
insert into @p3 values(0,'S-1-9-1441374244-2649122007-3436464326-2922169763-974421344-0-0-0-0-3');</p>
<p>exec prc_ReadGroups<br />
    @partitionId=1,<br />
    @scopeId='5c5c4fe4-eba6-4899-87f1-f2f8a1802a6e',<br />
    @groupSids=@p3,<br />
    @groupIds=default;<&#47;pre></p>
<p>By copying this into SQL Management Studio and running it against the Tfs_Configuration database (in a begin tran&hellip;rollback tran block, of course) I was able to get details of the Identity, in my case it was a Team.<&#47;p></p>
<p>I viewed the results of this Query as "Text" from SQL Management Studio and pasted them into a blank UTF-8 document in Notepad++. Flicking to the trusty Hex Editor plugin I could soon see some characters that did not belong in the Description text. These were the u200b Zero Width Spaces.<&#47;p></p>
<p>To fix this I just opened up my Team Web Access, navigated to the Team's page and deleted the Description, re-typed it and saved. Re-running my Linqpad sample proved the issue was solved.<&#47;p></p>
<p>I've logged this as a <a href="https:&#47;&#47;connect.microsoft.com&#47;VisualStudio&#47;feedback&#47;details&#47;783846&#47;using-some-unicode-characters-in-team-description-causes-the-identity-management-service-to-error#" target="_blank">Connect Bug<&#47;a> as I am sure it is not intentional and it only started happening since installing in Update 2.<&#47;p></p>
