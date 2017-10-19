---
layout: post
status: publish
published: true
title: Drag and Drop Batch Files
date: '2017-10-19 21:46:00 +0100'
date_gmt: '2017-10-19 21:46:00 +0100'
categories:
- Development
---

This is a little trick that can make dealing with batch files a real breeze.

You can make a batch file support drag and drop.

![Drag and drop][1]

Here I've create a simple batch file that takes in a single argument tells you that it is listing the file
then prints the contents using the [`TYPE`][2] command and then `PAUSE`'s.

```cmd
@echo off
echo Listing the contents of %1
echo.
type %1
echo.
echo.
pause
```

This works because when you drop a file on a executable in Windows the first argument passed to that program is
the name of the file you dropped on it. So in the above script `%1` is the full path to whatever file you drop on
the batch file.

I've used this in a few different ways:

1. [SDelete][3]: I have a batch file to call SDelete with 64 passes . I created a shortcut to the batch file with an icon (so it looks nice), that I use for deleting sensitive files at work.
1. Restoring development databases: I have another a batch file to restore development database backups, first it unzips the archive and then runs restore via SQLCMD.

I'm sure there are a lot more uses for this. If you want to process multiple files you can [iterate through all the arguments][4].

Thanks to [bepe][5] from XDA Developers who was the person who first showed me this technique in his ROM Kitchen videos many years ago.

[1]:{{ site.contenturl }}drag-drop.gif
[2]:https://technet.microsoft.com/en-us/library/bb491026.aspx
[3]:https://docs.microsoft.com/en-us/sysinternals/downloads/sdelete
[4]:https://stackoverflow.com/a/19837690/383710
[5]:https://forum.xda-developers.com/member.php?u=270777