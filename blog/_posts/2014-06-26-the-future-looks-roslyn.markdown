---
layout: post
status: publish
published: true
title: The Future Looks Roslyn
author:
  display_name: Dave Shaw
  login: DaveShaw
  email: dave@taeguk.co.uk
  url: http://taeguk.co.uk
author_login: DaveShaw
author_email: dave@taeguk.co.uk
author_url: http://taeguk.co.uk
wordpress_id: 882
wordpress_url: http://taeguk.co.uk/?p=882
date: '2014-06-26 20:57:44 +0100'
date_gmt: '2014-06-26 19:57:44 +0100'
categories:
- Development
- Visual Studio
tags: []
comments:
- id: 32
  author: Roslyn, the C# (and VB) .Net compiler platform | Wimpies C# Blog
  author_email: ''
  author_url: http://wimpiescsharpblog.mytinyjumplist.nl/2014/08/12/roslyn-the-c-and-vb-net-compiler-platform/
  date: '2014-08-12 17:33:00 +0100'
  date_gmt: '2014-08-12 16:33:00 +0100'
  content: "[&#8230;] Studio itself will use Rosalyn for better Intellisense, Refactoring
    and CodeLense. See for example Dave Shaw&#8217;s Development Blog. All refactoring
    will be accessible using &ldquo;Alt + .&rdquo;.&nbsp; An example of Inline [&#8230;]"
- id: 42
  author: Gregory Smith
  author_email: ''
  author_url: http://www.gregorysmithblog.com
  date: '2014-10-14 07:46:52 +0100'
  date_gmt: '2014-10-14 06:46:52 +0100'
  content: |-
    <strong>I love your blog<&#47;strong>

    I have read this article and enjoyed it
- id: 62
  author: Vanessa Smith
  author_email: ''
  author_url: http://www.vanessasmith.com
  date: '2015-03-06 07:29:22 +0000'
  date_gmt: '2015-03-06 07:29:22 +0000'
  content: |-
    <strong>I liked your blog very much.<&#47;strong>

    I want to thank you for the contribution.
---
<p>I&rsquo;ve been keeping an eye on the development of <a href="http:&#47;&#47;roslyn.codeplex.com&#47;" target="_blank">Roslyn<&#47;a> ever since <span>Anders Hejlsberg announced Microsoft were open sourcing it at Build 2014. For those of you who don&rsquo;t know what Roslyn is, it is Microsoft&rsquo;s new C# and VB.NET compiler platform. There are many aspects to it, and if you want a nice overview Schabse Laks has a couple of <a href="http:&#47;&#47;blog.slaks.net&#47;2014-04-07&#47;exploring-roslyn-part-1-introduction&#47;" target="_blank">blog<&#47;a> <a href="http:&#47;&#47;blog.slaks.net&#47;2014-05-21&#47;exploring-roslyn-part-2-inside-end-user-preview&#47;" target="_blank">posts<&#47;a> on the subject.<&#47;span><&#47;p>
<p><span>Most developers seem to be excited by the new C# 6.0 language and the future of the language going forward &ndash; I can see why, C# hasn&rsquo;t really changed that much recently. Whilst I am interested in the language, another thing that has got me really excited as a C# developer is the Language Service. <&#47;span><&#47;p><br />
<h2><span><&#47;span><&#47;h2><br />
<h2><span>Language Service<&#47;span><&#47;h2>
<p><span>The language service is what Visual Studio uses to talk to the compiler to understand your code. Previously this was implemented as a series of &ldquo;hacks&rdquo; between Visual Studio and the compilers. This made it hard for the Visual Studio team to implement many decent refactoring experiences. The last time anything new really appeared for the &ldquo;coders&rdquo; was in <a href="http:&#47;&#47;blogs.wrox.com&#47;article&#47;7-refactoring-methods-in-visual-studio-2010&#47;" target="_blank">VS2010<&#47;a> when the existing refactoring tools were released. Two full versions of VS later, and we still have the same refactoring features. Whilst the C# team have been busy working on Roslyn, products like Jet Brains ReSharper have come along with loads of features of their own, adding refactoring tools and code analysis. But I think times are changing&hellip;<&#47;span><&#47;p>
<p><span>For those of you who have installed &ldquo;Visual Studio 14&rdquo; or the Roslyn End User Preview, you are seeing the beginning, of what I think, will be a revolution to Visual Studio&rsquo;s coding experience for C# (as well as VB.NET).<&#47;span><&#47;p><br />
<h2><span><&#47;span><&#47;h2><br />
<h2><span>New Features<&#47;span><&#47;h2>
<p><span>Here&rsquo;s a quick overview of some of the features added already:<&#47;span><&#47;p><br />
<h3><span><&#47;span>Visualising <font face="Consolas">using<&#47;font> directives that are not needed.<&#47;h3>
<p><span><a href="http:&#47;&#47;taeguk.co.uk&#47;wp-content&#47;uploads&#47;2014&#47;06&#47;Remove-Usings.png"><img title="Remove Usings" style="border-left-width: 0px; border-right-width: 0px; background-image: none; border-bottom-width: 0px; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-top-width: 0px" border="0" alt="Remove Usings" src="http:&#47;&#47;taeguk.co.uk&#47;wp-content&#47;uploads&#47;2014&#47;06&#47;Remove-Usings_thumb.png" width="321" height="85"><&#47;a><&#47;span><&#47;p>
<p><span>Here you can see that I don&rsquo;t need three of my five using directives so they are coloured grey.<&#47;span><&#47;p><br />
<h3>Ctrl + . to Resolve<&#47;h3>
<p>Taking the previous &ldquo;issue&rdquo; with my code I can just place the caret on any of the lines with an issue and press Ctrl + . (full stop) to fix it.<&#47;p>
<p><a href="http:&#47;&#47;taeguk.co.uk&#47;wp-content&#47;uploads&#47;2014&#47;06&#47;Remove-Usings-Action.png"><img title="Remove Usings Action" style="border-left-width: 0px; border-right-width: 0px; background-image: none; border-bottom-width: 0px; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-top-width: 0px" border="0" alt="Remove Usings Action" src="http:&#47;&#47;taeguk.co.uk&#47;wp-content&#47;uploads&#47;2014&#47;06&#47;Remove-Usings-Action_thumb.png" width="500" height="180"><&#47;a><&#47;p>
<p>You even get a preview of what your class will look like when &ldquo;fixed&rdquo;.<&#47;p>
<p>Ctrl + . has been used to Resolve issues with your code before (e.g. add using directives), but now it has previews and can suggest fixes to new problems. For example, it could suggest not to use Hungarian Notation and remove the prefix, this would be a lot better experience than the existing Code Analysis <a href="http:&#47;&#47;msdn.microsoft.com&#47;en-us&#47;library&#47;bb264492.aspx" target="_blank">CA1704<&#47;a> rule.<&#47;p><br />
<h3>Alt + . and Refactoring<&#47;h3>
<p>Since VS2010, the basic refactoring was done via a series of keyboard combination shortcuts. Ctrl + R, M to Extract Method is the only one I remember, the others I know are there but I can&rsquo;t remember the keyboard shortcuts. Now everything is under Alt + . and is context sensitive.<&#47;p>
<p>So if I select a few statements in a block of code and do Alt + . get the option to Extract Method, select a field and do Alt + . I get Encapsulate Field, select the class name, Extract Interface, you get the idea.<&#47;p>
<p>The interface for renaming has changed too to include live preview and errors.<&#47;p>
<p><a href="http:&#47;&#47;taeguk.co.uk&#47;wp-content&#47;uploads&#47;2014&#47;06&#47;New-Method.png"><img title="New Method" style="border-left-width: 0px; border-right-width: 0px; background-image: none; border-bottom-width: 0px; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-top-width: 0px" border="0" alt="New Method" src="http:&#47;&#47;taeguk.co.uk&#47;wp-content&#47;uploads&#47;2014&#47;06&#47;New-Method_thumb.png" width="597" height="198"><&#47;a><&#47;p>
<p>Above you can see a New Method I&rsquo;ve extracted and the Live Preview of renaming. If I decided to call &ldquo;NewMethod&rdquo; &ldquo;Foo&rdquo; I&rsquo;d get this error because I already have method called Foo.<&#47;p>
<p><a href="http:&#47;&#47;taeguk.co.uk&#47;wp-content&#47;uploads&#47;2014&#47;06&#47;New-Method-Error.png"><img title="New Method Error" style="border-left-width: 0px; border-right-width: 0px; background-image: none; border-bottom-width: 0px; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-top-width: 0px" border="0" alt="New Method Error" src="http:&#47;&#47;taeguk.co.uk&#47;wp-content&#47;uploads&#47;2014&#47;06&#47;New-Method-Error_thumb.png" width="617" height="195"><&#47;a><&#47;p><br />
<h3>Code Lens<&#47;h3>
<p>Code Lens is a heads up display that is already available in VS2013 Ultimate and is powered by Roslyn to provide code and source control information inline in the editor. I&rsquo;ve only played with this during the CTP of VS2013, but it seemed really promising &ndash; I&rsquo;m now waiting on Microsoft to move it from the Ultimate SKU to Premium.<&#47;p>
<p><img src="https:&#47;&#47;x2jsrq.blu.livefilestore.com&#47;y2pHvnYw8ZovzeKdsT9oEAT-NasfcccvLTyqpUAZWrmBdGTwNgO85YBV3QkWXgmi_I7BUC4pMIDUbEiLgeVImTwFsQxjfOZ9Y-7MrZR10256Ew&#47;codelens2.png?psid=2"><&#47;p><br />
<h2>Visual Studio 14<&#47;h2>
<p>All the aforementioned features are in VS2013 + End User Preview, Roslyn will actually ship enabled in the next Visual Studio code named &ldquo;<a href="http:&#47;&#47;blogs.msdn.com&#47;b&#47;visualstudio&#47;archive&#47;2014&#47;06&#47;03&#47;visual-studio-14-ctp-now-available.aspx" target="_blank">Visual Studio 14<&#47;a>&rdquo;. This has an early preview available and already more refactoring features have appeared. For example, Soma mentions a new Introduce Local refactoring in his <a href="http:&#47;&#47;blogs.msdn.com&#47;b&#47;somasegar&#47;archive&#47;2014&#47;06&#47;03&#47;first-preview-of-visual-studio-quot-14-quot-available-now.aspx" target="_blank">blog post<&#47;a>.<&#47;p>
<p>This sort of stuff isn&rsquo;t really ground breaking from a developer experience point of view and it&rsquo;s nothing new for people who use Visual Studio add-ins like ReSharper. But, it is proof that Visual Studio&rsquo;s Editor is back in the game.<&#47;p>
<p>My opinion is that from now until VS 14 RTM ships, the C# and VS team will be focusing their efforts on stabilising the Compiler aspect of Roslyn and making sure everything &ldquo;just works&rdquo;, we may see a few more refactoring tools appear in the next update, but I&rsquo;m not expecting much.<&#47;p><br />
<h2>After the RTM<&#47;h2>
<p>I&rsquo;m looking forward to when Visual Studio 14 has hit RTM has shipped, what happens next&hellip;? The Visual Studio Editor team have time to take a good hard look at what they want to build, the C# compiler team can go back to working on language features. I expect the VS Editor team will be working on some awesome editor experiences, some we might have seen before in other products, others brand new. I cannot see them resting on their laurels once they have the Language Services as a platform to build on, they can do anything they want.<&#47;p><br />
<h3><&#47;h3><br />
<h3>Community<&#47;h3>
<p>The other thing that really excites me is the community aspect, building your own VS Editor extensions that leverage the Language Services from the compiler is now easy. What ideas will the community build, what would you build? I&rsquo;m hoping that individual extensions will appear first, and then grow into suites of common functionality, and maybe even be implemented by the VS Editor team in the future. <&#47;p>
<p>It doesn&rsquo;t just have to be extensions, it is also really easy to write your own diagnostics tools. Already there is a <a href="http:&#47;&#47;visualstudiogallery.msdn.microsoft.com&#47;adbded26-4bc1-4d24-be86-61eef8768eee" target="_blank">String.Format Diagnostic<&#47;a> package on the VS Gallery. So, where does this leave products like ReSharper? In my opinion, Microsoft always implement the features most people want, there will still be room for people to create their own extensions suites and JetBrains can charge for a professional package. However, now it will be a lot easier for people to build their own, no longer do you need to write a C# Code Analyser, so there could be some awesome free open source extension suites appearing too.<&#47;p><br />
<h3>Summary<&#47;h3>
<p>I think the next few updates for Visual Studio will brings lots of exciting and powerful enhancements to the Visual Studio Editor for both the C# and VB.NET developers. It&rsquo;s been a long time coming, but I think Visual Studio is back on the front font and ready to innovate some more.<&#47;p></p>
