---
layout: post
status: publish
published: true
title: Using Linqpad to Find Work Items with External ID&rsquo;s
author:
  display_name: Dave Shaw
  login: DaveShaw
  email: dave@taeguk.co.uk
  url: http://taeguk.co.uk
author_login: DaveShaw
author_email: dave@taeguk.co.uk
author_url: http://taeguk.co.uk
wordpress_id: 692
wordpress_url: http://taeguk.co.uk/?p=692
date: '2014-02-24 21:59:03 +0000'
date_gmt: '2014-02-24 21:59:03 +0000'
categories:
- TFS
- Linqpad
tags: []
comments: []
---
<p>When you work on projects of a certain size, you will find that you begin to add custom fields to your TFS Work Items that you later want to search on. In my case it was an External Requirement ID field that we use to store the ID of requirements that our customers use to track requirements. I often use these when communicating with our customers, or even members of my team.<&#47;p>
<p>For example:<&#47;p><br />
<blockquote>
<p>&nbsp; &ldquo;Have you checked in A1 yet?&rdquo; is easier to ask and understand than &ldquo;Have you checked in 177484?&rdquo;.<&#47;p><&#47;blockquote>
<p>The problem that arises with this approach, is been able to find a work item by its External Requirement ID.<&#47;p>
<p>To solve this issue, I once again turned to Linqpad and came up with a script that lets you search by a comma separated list entries against your work items. After a bit of digging I managed to find the correct API to be able to produce reliable TFS Web Access URL&rsquo;s in the results:<&#47;p>
<p><a href="http:&#47;&#47;taeguk.co.uk&#47;wp-content&#47;uploads&#47;2014&#47;02&#47;Results.png"><img title="Results" style="border-left-width: 0px; border-right-width: 0px; background-image: none; border-bottom-width: 0px; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-top-width: 0px" border="0" alt="Results" src="http:&#47;&#47;taeguk.co.uk&#47;wp-content&#47;uploads&#47;2014&#47;02&#47;Results_thumb.png" width="244" height="79"><&#47;a><&#47;p>
<p>To use the script, just place you collection address and custom field name at the top. You can also add any other filtering into WIQL, for example, you might only want to search a certain Area Path. <&#47;p>
<p>When you run the script you will be asked to &ldquo;Enter External Requirement ID&rdquo;, just enter the ID i.e. <strong>A1<&#47;strong> or a list of ID&rsquo;s i.e. <strong>A1, A2<&#47;strong> and press <strong>Enter<&#47;strong>.<&#47;p>
<p>I keep mine &ldquo;Pinned&rdquo; to the Jump List of Linqpad on my taskbar for ease of access.<&#47;p>
<p>You can download the script from here:<&#47;p>
<ul>
<li><a href="https:&#47;&#47;onedrive.live.com&#47;redir?resid=A1F5F7FF7D7E95C4!7142&amp;authkey=!ANvTu-IAmHCvAQk&amp;ithint=file%2c.linq">VS 2013<&#47;a><&#47;li><&#47;ul>
<p>The script is based on <a href="http:&#47;&#47;taeguk.co.uk&#47;blog&#47;my-linqpad-tfs-template&#47;">my Linqpad TFS Template<&#47;a>, if you need it for any other version of Visual Studio, download the correct template and copy and paste the body of the script between them.<&#47;p></p>
