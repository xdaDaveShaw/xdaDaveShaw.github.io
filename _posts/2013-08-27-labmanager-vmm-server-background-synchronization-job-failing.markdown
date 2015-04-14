---
layout: post
status: publish
published: true
title: LabManager VMM Server Background Synchronization Job Failing
author:
  display_name: Dave Shaw
  login: DaveShaw
  email: dave@taeguk.co.uk
  url: http://taeguk.co.uk
author_login: DaveShaw
author_email: dave@taeguk.co.uk
author_url: http://taeguk.co.uk
wordpress_id: 262
wordpress_url: http://taeguk.azurewebsites.net/?p=262
date: '2013-08-27 23:24:28 +0100'
date_gmt: '2013-08-27 22:24:28 +0100'
categories:
- TFS
- Lab Management
tags: []
comments: []
---
<p>Today&rsquo;s topic is another TFS 2012 post-upgrade &ldquo;fix&rdquo;.</p>
<p>I upgraded our TFS 2010 instance to TFS 2012 four month ago and, slowly, I have been fixing up all the things that broke. I&rsquo;ve been using the TFS Web Administration page as a guide for what jobs are still having problems. For those of you who don&rsquo;t know what that is and have on-premise TFS 2012 (or greater), I heartily recommend you check out Grant Holliday&rsquo;s <a href="http:&#47;&#47;blogs.msdn.com&#47;b&#47;granth&#47;archive&#47;2013&#47;02&#47;13&#47;tfs2012-new-tools-for-tfs-administrators.aspx">blog post<&#47;a> on it.</p>
<p>The problem we were seeing was that the Job Monitoring graph was reporting about 50% of all jobs as failures. And nearly all the failures were for one job type, the &ldquo;LabManager VMM Server Background Synchronization&rdquo; job. This runs every few minutes and tries to keep the LabManager server up to date. The problem is that we setup LabManager on our TFS 2010 instance, and then tore down the VMM Lab Management Server without allowing TFS to de-register it. The TFS Administrator console did not offer any options to remove the server.</p>
<p>I posted on the MSDN Forums but sadly, the <a href="http:&#47;&#47;social.msdn.microsoft.com&#47;Forums&#47;vstudio&#47;en-US&#47;f32faf76-c9ca-4ec0-a1f2-2cb09c965ced&#47;labmanager-vmm-server-background-synchronization-job-failing">suggestions<&#47;a> from Microsoft didn&rsquo;t help.</p>
<p>In the end I turned to <a href="http:&#47;&#47;ilspy.net&#47;">ILSpy<&#47;a> and started disassembling the TFS Server Side Assemblies and found references to a &ldquo;Registry&rdquo; that contained the settings for Lab Management. This Registry turned out to be stored in the TFS database.</p>
<p align="center"><strong>Before we go any further, I just want to be 100% clear that, messing around in the TFS database&nbsp;is not supported by myself or Microsoft, you do this of your own free will, and I will not support you if this goes wrong.<&#47;strong><&#47;p><br />
Within the <span style="font-family: Consolas;">Tfs_Configuration<&#47;span> database there is a table called <span style="font-family: Consolas;">tbl_RegistryItems<&#47;span>. This contains the configuration for Lab Management. Because we do not use Lab Management in any shape of form at the moment, I was happy to delete all our settings relating to it. If you do use Lab Management, then I don&rsquo;t suggest you try this.</p>
<p>After backing up all the data that I was about to delete, I ran the following SQL Script to delete all our Lab Management configuration:</p>
<pre class="brush: sql;">use Tfs_Configuration;</p>
<p>delete tbl_RegistryItems<br />
where ParentPath = '#\Configuration\Application\LabManagementSettings\';<&#47;pre><br />
The data in this table was cached, so I needed to restart my TFS Services to get it to pick it up, but once that was done. My Lab Manager job no longer reports an error and my Job Monitoring pie chart is nearly 100% green now.</p>
