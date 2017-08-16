---
layout: post
status: publish
published: true
title: LabManager VMM Server Background Synchronization Job Failing

date: '2013-08-27 23:24:28 +0100'
date_gmt: '2013-08-27 22:24:28 +0100'
categories:
- TFS
- Lab Management
---
Today's topic is another TFS 2012 post-upgrade "fix".

I upgraded our TFS 2010 instance to TFS 2012 four month ago and, slowly, I have been fixing up all the things that broke. I've been using the TFS Web Administration page as a guide for what jobs are still having problems. For those of you who don't know what that is and have on-premise TFS 2012 (or greater), I heartily recommend you check out Grant Holliday's [blog post](http://blogs.msdn.com/b/granth/archive/2013/02/13/tfs2012-new-tools-for-tfs-administrators.aspx) on it.

The problem we were seeing was that the Job Monitoring graph was reporting about 50% of all jobs as failures. And nearly all the failures were for one job type, the "LabManager VMM Server Background Synchronization" job. This runs every few minutes and tries to keep the LabManager server up to date. The problem is that we setup LabManager on our TFS 2010 instance, and then tore down the VMM Lab Management Server without allowing TFS to de-register it. The TFS Administrator console did not offer any options to remove the server.

I posted on the MSDN Forums but sadly, the [suggestions](http://social.msdn.microsoft.com/Forums/vstudio/en-US/f32faf76-c9ca-4ec0-a1f2-2cb09c965ced/labmanager-vmm-server-background-synchronization-job-failing) from Microsoft didn't help.

In the end I turned to ILSpy and started disassembling the TFS Server Side Assemblies and found references to a "Registry" that contained the settings for Lab Management. This Registry turned out to be stored in the TFS database.

> Before we go any further, I just want to be 100% clear that, messing
> around in the TFS database is not supported by myself or Microsoft,
> you do this of your own free will, and I will not support you if this
> goes wrong.

Within the `Tfs_Configuration` database there is a table called `tbl_RegistryItems`. This contains the configuration for Lab Management. Because we do not use Lab Management in any shape of form at the moment, I was happy to delete all our settings relating to it. If you do use Lab Management, then I don't suggest you try this.

After backing up all the data that I was about to delete, I ran the following SQL Script to delete all our Lab Management configuration:

```sql
use Tfs_Configuration;
 
delete tbl_RegistryItems
where ParentPath = '#\Configuration\Application\LabManagementSettings\';
```

The data in this table was cached, so I needed to restart my TFS Services to get it to pick it up, but once that was done. My Lab Manager job no longer reports an error and my Job Monitoring pie chart is nearly 100% green now.
