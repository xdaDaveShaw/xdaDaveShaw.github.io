---
layout: post
status: publish
published: true
title: Problems assigning a work item to a Group
date: '2013-01-08 20:25:00 +0000'
date_gmt: '2013-01-08 20:25:00 +0000'
categories:
- TFS
---
I was trying to enable assigning work items to a group on TFS 2010, and after following Ivan Fioravanti's excellent [Blog Post](https://ivanfioravanti.wordpress.com/2011/04/04/assigning-a-work-item-to-a-group-in-tfs/) 
on the subject, I still found that my Team Project groups were not appearing in the "Assigned To" dropdown list. After triple checking everything, I noticed the most important point on his blog: *"remove VALIDUSER rule, because this is responsible for not showing groups in the dropdown list"*. I checked again, and yep, the System.AssignedTo field did not have that rule. After a little thinking I eventually searched my Work Item Template Definition XML for the term "VALIDUSER" and bingo, there was another one!

It turned out I also had a "VALIDUSER" rule applied to the initial state transition (i.e. from "" to "New") for the System.AssignedTo field.

This was ensuring that all newly logged bugs must be assigned to a User, and not a Group. If I were testing my change on an existing work item, I would not have noticed the problem.

I removed the extra VALIDUSER &ndash; probably added in a moment of over eagerness &ndash; and hey presto, everything worked as Ivan said it would!
