---
layout: post
status: publish
published: true
title: Errors when calling IIdentityManagementService ReadIdentities() in TFS 2012.2

date: '2013-04-16 20:58:00 +0100'
date_gmt: '2013-04-16 20:58:00 +0100'
categories:
- TFS
---
Since upgrading to TFS 2012.2 (from Update 1) I have been seeing the following error in a couple of places:

    Server was unable to process request. ---> 
    There was an error generating the XML document. ---> 
    TF20507: The string argument contains a character that is not valid:'u8203'. 
    Correct the argument, and then try the operation again.

It first appeared when loading VS2012.2 with TFS Sidekicks 4.5 installed. It also appeared when I called `IIdentityManagementService.ReadIdentities()` via the TFS 2012 Object Model. I guess this is what TFS Sidekicks is calling under the covers.

It turned out that this was caused by the [Zero Width Space Unicode character](http://www.fileformat.info/info/unicode/char/200b/index.htm) (\u200b) been present in a Team's Description field. Some of our users had copied and pasted into there and brought it along from somewhere, where it came from I'll probably never know.

To track down which Team had this problem was quite a trek. Firstly, this doesn't happen using the V10 (TFS 2010) Object Model, only the V11 Team Foundation client assembly references.

Using the following code in my [TFS Template](http://taeguk.co.uk/blog/my-linqpad-tfs-template/) (2012 Version) as a base:

{% highlight c# %}
void Main()
{
  const String CollectionAddress = "http://tfsserver:8080/tfs/MyCollection";
  using (var tfs = TfsTeamProjectCollectionFactory.GetTeamProjectCollection(new Uri(CollectionAddress)))
  {
    tfs.EnsureAuthenticated();
    var server = tfs.GetService<>();
  }  
}
{% endhighlight %} 

I then call this method to get the crash:
{% highlight c# %}
var nodeMembers =
  managementService
  .ReadIdentities(
    members,
    MembershipQuery.Expanded,
    ReadIdentityOptions.ExtendedProperties);
{% endhighlight %} 

The problem is, in my TFS Instance, there are 634 "members" and I had no idea which one might be causing the problem:

Replacing the above line with a simple loop and try&hellip;catch block reduced that for me:
{% highlight c# %}
foreach (var member in members)
{
  try
  {
    var nodeMembers =
      managementService
      .ReadIdentities(
        new [] { member, },
        MembershipQuery.Expanded,
        ReadIdentityOptions.ExtendedProperties);
  }
  catch (Exception e)
  {
    e.Dump(a.Identifier);
  }
}
{% endhighlight %} 

I now had the Identity of the member with an issue, the problem I now faced was getting the name of the member.

A typical Identity looks like this:

> S-1-9-**1441374244**-17626364-2447400142-3087036873-88942238-1-3433204373-3394714127-2914434643-4144131896

In the end I fired up SQL Profiler, pointed it at TFS and re-ran my code snippet. I then stopped the trace and searched for the first part my Identity: **1441374244**. This led me to the following SQL statement:
{% highlight sql %}
declare @p3 dbo.typ_KeyValuePairInt32StringVarcharTable;
insert into @p3 values(0,'S-1-9-1441374244-2649122007-3436464326-2922169763-974421344-0-0-0-0-3');
 
exec prc_ReadGroups
  @partitionId=1,
  @scopeId='5c5c4fe4-eba6-4899-87f1-f2f8a1802a6e',
  @groupSids=@p3,
  @groupIds=default;
{% endhighlight %} 

By copying this into SQL Management Studio and running it against the `Tfs_Configuration` database (in a begin tran&hellip;rollback tran block, of course) I was able to get details of the Identity, in my case it was a Team.

I viewed the results of this Query as "Text" from SQL Management Studio and pasted them into a blank UTF-8 document in Notepad++. Flicking to the trusty Hex Editor plugin I could soon see some characters that did not belong in the Description text. These were the u200b Zero Width Spaces.

To fix this I just opened up my Team Web Access, navigated to the Team's page and deleted the Description, re-typed it and saved. Re-running my Linqpad sample proved the issue was solved.

I've logged this as a [Connect Bug](https://connect.microsoft.com/VisualStudio/feedback/details/783846/using-some-unicode-characters-in-team-description-causes-the-identity-management-service-to-error#) as I am sure it is not intentional and it only started happening since installing in Update 2.
