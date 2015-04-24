---
layout: post
status: publish
published: true
title: My Linqpad TFS Template
date: '2013-01-23 21:49:00 +0000'
date_gmt: '2013-01-23 21:49:00 +0000'
categories:
- TFS
- Linqpad
---
I am a massive fan of [Linqpad](http://linqpad.net), especially as a code scratch pad, but it is also very useful for performing queries against the [Team Foundation Server SDK](http://msdn.microsoft.com/en-us/library/bb130146(v=vs.110).aspx).

I regularly find myself wanting to get information out of our TFS Collection via the API, whether it be Build Information, Work Item Queries, Version Information, etc. Occasionally, I also need to update Build Definitions' Process XML en-mass.

To make my life easier and to enable me to spin up these queries as quick as possible I came up with a "Template" Linqpad script that I can always use as a baseline.

The important code is as follows and the "linq" file has all the references and namespaces I could ever need:
{% highlight c# %}
const String CollectionAddress = "http://tfsserver:8080/tfs/MyCollection";
using (var tfs = TfsTeamProjectCollectionFactory.GetTeamProjectCollection(new Uri(CollectionAddress)))
{
  tfs.EnsureAuthenticated();
  var server = tfs.GetService<>();
}
{% endhighlight %}

### Using
I have this in "My Linqpad Queries" and as soon as I open the file I press Ctrl+Shift+C to clone it to a new query so I don't save change to the "template". Linqpad doesn't yet support "Templates", there is a UserVoice [request](http://linqpad.uservoice.com/forums/18302-linqpad-feature-suggestions/suggestions/1567811-define-query-templates) for it however.

Once I have the cloned copy I insert the name of the service I plan to call into `GetService<>`, and then go to work. The API is quite easy to use, and the MSDN documentation is pretty comprehensive. The common services I use are:

 - `IBuildServer` for Builds
 - `VersionControlServer` for Source Control
 - `WorkItemStore` for Work Items

In the downloaded file there are also some `XNamespace` declarations at the top, which are used when I have to update `IBuildDetail.BuildDefinition.ProcessParameters` using Linq to Xml. These are the common three I found myself having to declare each time, so I just made them part of the template.

### Download

You can download the "linq" file for Linqpad from my OneDrive:

 - TFS2010: [Download](http://sdrv.ms/14azPrs)
 - TFS2012: [Download](http://sdrv.ms/ZvvXgZ)
 - TFS2013: [Download](http://sdrv.ms/149bA0S)
