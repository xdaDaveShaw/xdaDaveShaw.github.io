---
layout: post
status: publish
published: true
title: Fixing a broken Kanban Board
author:
  display_name: Dave Shaw
  login: DaveShaw
  email: dave@taeguk.co.uk
  url: http://taeguk.co.uk
author_login: DaveShaw
author_email: dave@taeguk.co.uk
author_url: http://taeguk.co.uk
wordpress_id: 1202
wordpress_url: http://taeguk.co.uk/?p=1202
date: '2015-02-11 21:19:41 +0000'
date_gmt: '2015-02-11 21:19:41 +0000'
categories:
- TFS
tags: []
comments: []
---
<p>Today I came across a team who had completely broken their TFS Kanban Board (Backlog Board). All they could see was a generic &ldquo;there has been a problem&rdquo; pink popup instead of their cards.<&#47;p>
<p>When presented with this, the usual fix is to ensure background agent job is running, which it was. So I took a look in the Windows event logs for more detail and found this error (most of the details are removed for brevity, this is from the middle):<&#47;p>
<pre class="brush: plain; gutter: false;"><em>...Details removed...<&#47;em></p>
<p>Detailed Message: TF30065: An unhandled exception occurred.</p>
<p>Exception Message: The given key was not present in the dictionary. (type KeyNotFoundException)<br />
Exception Stack Trace:    at System.Collections.Generic.Dictionary`2.get_Item(TKey key)<br />
   at Microsoft.TeamFoundation.Server.WebAccess.Agile.Models.WorkItemSource.<>c__DisplayClass18.<GetProposedInProgressWorkItemData>b__13(IDataRecord dataRecord)<br />
   at Microsoft.TeamFoundation.Server.WebAccess.Agile.Utility.WorkItemServiceUtils.<GetWorkItems>d__c.MoveNext()<br />
   at Microsoft.TeamFoundation.Server.WebAccess.Agile.Models.WorkItemSource.GetProposedInProgressWorkItemData(ICollection`1 rowData, ICollection`1 hierarchy, ISet`1 parentIds)</p>
<p><em>...More stack trace removed...<&#47;em><br />
<&#47;pre></p>
<p>&nbsp;<&#47;p></p>
<p>With this little information, all I could assume was that, somehow the configuration had become corrupted. My solution was to find the board settings for that team and delete them from the TFS Collection database.<&#47;p></p>
<p>&nbsp;<&#47;p></p>
<blockquote>
<p><strong>NOTE: Neither I nor Microsoft support you making changes directly to your TFS database. You do so at you own risk, and probably best with a backup.<&#47;strong><&#47;p></p>
<p><strong>This SQL worked against our TFS 2012.3 Database, I cannot guarantee other versions have the same schema.<&#47;strong><&#47;p><&#47;blockquote></p>
<p>&nbsp;<&#47;p></p>
<p>First step is to find your <font face="Consolas">TeamId<&#47;font> from the Collection Database. Team Ids can be found in the <font face="Consolas">ADObjects<&#47;font> table.<&#47;p>
<pre class="brush: sql; gutter: false;">select * from ADObjects<br />
where SamAccountName like '%MyTeamName%'<br />
<&#47;pre></p>
<p>The <font face="Consolas">TeamFoundationId<&#47;font> GUID in this table is the value we are interest in.<&#47;p></p>
<p>You can find the Board and Columns in the <font face="Consolas">tbl_Board<&#47;font> and<font face="Consolas"> tbl_BoardColumn<&#47;font> tables using the following SQL:<&#47;p>
<pre class="brush: sql; gutter: false;">select * from tbl_Board b<br />
join tbl_BoardColumn bc on b.Id = bc.BoardId<br />
where TeamId = 'YouTeamId'<br />
<&#47;pre></p>
<p>Once you are happy that you have the found the rows for the team, you can then delete them from those two tables. You should probably copy the results into Excel just in case things go wrong.<&#47;p></p>
<p>To delete you can use the following SQL Queries:<&#47;p>
<pre class="brush: sql; gutter: false;">delete bc<br />
from tbl_Board b<br />
join tbl_BoardColumn bc on b.Id = bc.BoardId<br />
where TeamId = 'YouTeamId'<&#47;pre>
<pre class="brush: sql; gutter: false;">delete tbl_Board<br />
where TeamId = 'YouTeamId'<&#47;pre></p>
<p>Now if you refresh the board it should report that there is no configuration and needs to be setup again from scratch.<&#47;p></p>
<p>&nbsp;<&#47;p></p>
<p>I&rsquo;ve no idea what caused this problem, or if it is fixed in a future update, but this got things working again for me.<&#47;p></p>
