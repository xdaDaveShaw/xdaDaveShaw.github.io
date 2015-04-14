---
layout: post
status: publish
published: true
title: Setting a property to an empty string in MSBuild
date: '2013-02-18 20:21:00 +0000'
date_gmt: '2013-02-18 20:21:00 +0000'
categories:
- MSBuild
---
Today I found my self in a situation where I needed to initialise a property in MSBuild via the `/property:<n>=<v>` (short form `/p`) command line switch to an empty string. The reason I had to do this was to so that I could remove some property from my OutputPath when building on Team Foundation Server.

For Example, in my C Sharp project file I had the following line.

    <OutputPath>$(MyProperty)\bin\</OutputPath>

In some scenarios I wanted `$(MyProperty)` to be "Build" and in other cases I wanted it to be removed.

So the scenarios went a little like this:

    <!-- Scenario 1 -->
    <OutputPath>Build\bin\</OutputPath>
    <!-- Scenario 2 -->
    <OutputPath>\bin\</OutputPath>

After a quick visit to Google and thumbing through [Inside the Microsoft Build Engine 2nd Edition](http://www.amazon.co.uk/gp/product/0735645248/ref=as_li_tf_tl?ie=UTF8&camp=1634&creative=6738&creativeASIN=0735645248&linkCode=as2&tag=taeguk-21) by Sayed Ibrahim Hashimi, I still could not find a canonical to answer my question. I read something that said an empty string should be two single quotes, but those substituted those into my build causing it to error (it turns out, that was for checking if a variable is empty). In the end I went to the command line and started experimenting. I thought I'd just pop my findings on here in case anyone else has a need for it.

The Answer is to just use `PropertyName=` and no more.

For Example:

    MSBuild /property:MyProperty= MySolution.sln

This syntax works at the start, middle or end of your property command line switch. So these are all valid too:

    MSBuild /property:Foo=One;MyProperty= MySolution.sln
    MSBuild /property:Foo=One;MyProperty=;Bar=Two MySolution.sln
    MSBuild /property:MyProperty=;Bar=Two MySolution.sln
    
You can check the MSBuild diagnostic (using the `/verbosity:diagnostic` switch) log to confirm that it worked:

    MSBuildUserExtensionsPath = C:\Users\Dave\AppData\Local\Microsoft\MSBuild
    MyProperty =
    NUMBER_OF_PROCESSORS = 4
