---
layout: post
status: publish
published: true
title: Controlling VS2017 Developer Console Start Directory
date: '2017-03-28 10:20:00 +0100'
date_gmt: '2017-03-28 10:20:00 +0100'
categories:
- Visual Studio
---

At work I use [ConEmu][1] for my console, it's a great console to work on Windows with.
To keep things tidy I have all my code on my `X:\` partition.
In ConEmu I have different "Tasks" setup for different configurations of Visual Studio and
pass `/Dir X:\` as one of the task parameters so that a new Console's current Dir is `X:\`.

![ConEnum Settings][2]

When running "Developer Command Prompt for VS 2017" on my work computer I noticed that the directory
it was opening in wasn't the current directory that ConEmu was setting, but `C:\Dave\Source`.

``` plain
**********************************************************************
** Visual Studio 2017 Developer Command Prompt v15.0.26228.9
** Copyright (c) 2017 Microsoft Corporation
**********************************************************************

C:\Dave\Source\>
```

After a bit of digging through the batch files I found the reason for this is because of this bit code in:

`C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\Tools\vsdevcmd\core\vsdevcmd_end.bat`

``` batch
...
@REM Set the current directory that users will be set after the script completes
@REM in the following order:
@REM 1. [VSCMD_START_DIR] will be used if specified in the user environment
@REM 2. [USERPROFILE]\source if it exists
@REM 3. current directory
if "%VSCMD_START_DIR%" NEQ "" (
    cd /d "%VSCMD_START_DIR%"
) else (
    if EXIST "%USERPROFILE%\Source" (
        cd /d "%USERPROFILE%\Source"
    )
)
...
```

As you can see, it has two chances to pick a different directory before using your current one.

In my case, I had a folder at `%USERPROFILE%\Source`, which was empty, so I deleted it.

The other alternative is to set the `VSCMD_START_DIR` environment variable for your user account to your preferred directory.

[1]:https://conemu.github.io/
[2]:{{ site.contenturl }}vs2017-cmd-conemu.png