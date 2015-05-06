---
layout: post
status: publish
published: true
title: Using Linqpad to Find Work Items with External IDs
date: '2014-02-24 21:59:03 +0000'
date_gmt: '2014-02-24 21:59:03 +0000'
categories:
- TFS
- Linqpad
---
When you work on projects of a certain size, you will find that you begin to add custom fields to your TFS Work Items that you later want to search on. In my case it was an External Requirement ID field that we use to store the ID of requirements that our customers use to track requirements. I often use these when communicating with our customers, or even members of my team.

For example:

> "Have you checked in A1 yet?"

is easier to ask and understand than 
> "Have you checked in 177484?"

The problem that arises with this approach, is been able to find a work item by its External Requirement ID.

To solve this issue, I once again turned to Linqpad and came up with a script that lets you search by a comma separated list entries against your work items. After a bit of digging I managed to find the correct API to be able to produce reliable TFS Web Access URL's in the results:

![Results]({{ site.contenturl }}ExternalWI-Results.png)

To use the script, just place you collection address and custom field name at the top. You can also add any other filtering into WIQL, for example, you might only want to search a certain Area Path. 

When you run the script you will be asked to "Enter External Requirement ID", just enter the ID i.e. **A1** or a list of ID's i.e. **A1, A2** and press **Enter**.

I keep mine "Pinned" to the Jump List of Linqpad on my taskbar for ease of access.

You can download the script from here:

- [VS 2013](https://onedrive.live.com/redir?resid=A1F5F7FF7D7E95C4!7142&authkey=!ANvTu-IAmHCvAQk&ithint=file%2c.linq)

The script is based on [my Linqpad TFS Template]({% post_url 2013-01-23-my-linqpad-tfs-template %}), if you need it for any other version of Visual Studio, download the correct template and copy and paste the body of the script between them.