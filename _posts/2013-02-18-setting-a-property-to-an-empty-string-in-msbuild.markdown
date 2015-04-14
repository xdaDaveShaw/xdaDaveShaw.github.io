---
layout: post
status: publish
published: true
title: Setting a property to an empty string in MSBuild
author:
  display_name: Dave Shaw
  login: DaveShaw
  email: dave@taeguk.co.uk
  url: http://taeguk.co.uk
author_login: DaveShaw
author_email: dave@taeguk.co.uk
author_url: http://taeguk.co.uk
wordpress_id: 82
wordpress_url: http://taeguk.azurewebsites.net/?p=82
date: '2013-02-18 20:21:00 +0000'
date_gmt: '2013-02-18 20:21:00 +0000'
categories:
- MSBuild
tags: []
comments: []
---
<p>Today I found my self in a situation where I needed to initialise a property in MSBuild via the <font face="Consolas">&#47;property:<n>=<v> <&#47;font>(short form <font face="Consolas">&#47;p<&#47;font>) command line switch to an empty string. The reason I had to do this was to so that I could remove some property from my <font face="Consolas">OutputPath<&#47;font> when building on Team Foundation Server.<&#47;p>
<p><strong>For Example, <&#47;strong>in my C Sharp project file I had the following line.<&#47;p>
<pre class="brush: xml;"><OutputPath>$(MyProperty)\bin\<&#47;OutputPath><&#47;pre>In some scenarios I wanted <font face="Consolas">$(MyProperty)<&#47;font> to be "Build" and in other cases I wanted it to be removed. </p>
<p>So the scenarios went a little like this:<&#47;p>
<pre class="brush: xml;"><!-- Scenario 1 --><br />
<OutputPath>Build\bin\<&#47;OutputPath><&#47;pre>
<pre class="brush: xml;"><!-- Scenario 2 --><br />
<OutputPath>\bin\<&#47;OutputPath><&#47;pre></p>
<p>After a quick visit to Google and thumbing through <a href="http:&#47;&#47;www.amazon.co.uk&#47;gp&#47;product&#47;0735645248&#47;ref=as_li_tf_tl?ie=UTF8&amp;camp=1634&amp;creative=6738&amp;creativeASIN=0735645248&amp;linkCode=as2&amp;tag=taeguk-21">Inside the Microsoft Build Engine 2nd Edition<&#47;a><img style="border-top-style: none !important; border-bottom-style: none !important; border-right-style: none !important; margin: 0px; border-left-style: none !important" border="0" alt="" src="http:&#47;&#47;www.assoc-amazon.co.uk&#47;e&#47;ir?t=taeguk-21&amp;l=as2&amp;o=2&amp;a=0735645248" width="1" height="1"> by Sayed Ibrahim Hashimi, I still could not find a canonical to answer my question. I read something that said an empty string should be two single quotes, but those substituted those into my build causing it to error (it turns out, that was for checking if a variable is empty). In the end I went to the command line and started experimenting. I thought I'd just pop my findings on here in case anyone else has a need for it.<&#47;p></p>
<p><strong>The Answer <&#47;strong>is to just use <font face="Consolas">PropertyName=<&#47;font> and no more.<&#47;p></p>
<p>For Example:<&#47;p>
<pre class="brush: plain;">MSBuild &#47;property:MyProperty= MySolution.sln<br />
<&#47;pre></p>
<p>This syntax works at the start, middle or end of your property command line switch. So these are all valid too:<&#47;p>
<pre class="brush: plain;">MSBuild &#47;property:Foo=One;MyProperty= MySolution.sln<br />
MSBuild &#47;property:Foo=One;MyProperty=;Bar=Two MySolution.sln<br />
MSBuild &#47;property:MyProperty=;Bar=Two MySolution.sln<br />
<&#47;pre></p>
<p>You can check the MSBuild diagnostic (using the <font face="Consolas">&#47;verbosity:diagnostic <&#47;font>switch) log to confirm that it worked:<&#47;p>
<pre class="brush: plain;">MSBuildUserExtensionsPath = C:\Users\Dave\AppData\Local\Microsoft\MSBuild<br />
MyProperty =<br />
NUMBER_OF_PROCESSORS = 4<&#47;pre></p>
