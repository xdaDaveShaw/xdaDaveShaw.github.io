---
layout: post
status: publish
published: true
title: Fixing a broken Kanban Board
date: '2015-02-11 21:19:41 +0000'
date_gmt: '2015-02-11 21:19:41 +0000'
categories:
- TFS
---
Today I came across a team who had completely broken their TFS Kanban Board (Backlog Board). All they could see was a generic "there has been a problem" pink popup instead of their cards.

When presented with this, the usual fix is to ensure background agent job is running, which it was. So I took a look in the Windows event logs for more detail and found this error (most of the details are removed for brevity, this is from the middle):

*...Details removed...*
 
    Detailed Message: TF30065: An unhandled exception occurred.
     
    Exception Message: The given key was not present in the dictionary. (type KeyNotFoundException)
    Exception Stack Trace:    at System.Collections.Generic.Dictionary`2.get_Item(TKey key)
       at Microsoft.TeamFoundation.Server.WebAccess.Agile.Models.WorkItemSource.<>c__DisplayClass18.<GetProposedInProgressWorkItemData>b__13(IDataRecord dataRecord)
       at Microsoft.TeamFoundation.Server.WebAccess.Agile.Utility.WorkItemServiceUtils.<GetWorkItems>d__c.MoveNext()
       at Microsoft.TeamFoundation.Server.WebAccess.Agile.Models.WorkItemSource.GetProposedInProgressWorkItemData(ICollection`1 rowData, ICollection`1 hierarchy, ISet`1 parentIds)
*...More stack trace removed...*

With this little information, all I could assume was that, somehow the configuration had become corrupted. My solution was to find the board settings for that team and delete them from the TFS Collection database.

> **NOTE: Neither I nor Microsoft support you making changes directly to your TFS database. You do so at you own risk, and probably best with a backup. 
> This SQL worked against our TFS 2012.3 Database, I cannot guarantee other versions have the same schema.**

First step is to find your `TeamId` from the Collection Database. Team Ids can be found in the `ADObjects` table.

{% highlight sql %}
select * from ADObjects
where SamAccountName like '%MyTeamName%';
{% endhighlight %}

The `TeamFoundationId` GUID in this table is the value we are interest in.

You can find the Board and Columns in the `tbl_Board` and `tbl_BoardColumn` tables using the following SQL:

{% highlight sql %}
select * from tbl_Board b
join tbl_BoardColumn bc on b.Id = bc.BoardId
where TeamId = 'YouTeamId';
{% endhighlight %}
    
Once you are happy that you have the found the rows for the team, you can then delete them from those two tables. You should probably copy the results into Excel just in case things go wrong.

To delete you can use the following SQL Queries:

{% highlight sql %}
delete bc
from tbl_Board b
join tbl_BoardColumn bc on b.Id = bc.BoardId
where TeamId = 'YouTeamId';

delete tbl_Board
where TeamId = 'YouTeamId';
{% endhighlight %}
    
Now if you refresh the board it should report that there is no configuration and needs to be setup again from scratch.

I've no idea what caused this problem, or if it is fixed in a future update, but this got things working again for me.