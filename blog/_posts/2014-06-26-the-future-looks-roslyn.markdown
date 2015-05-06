---
layout: post
status: publish
published: true
title: The Future Looks Roslyn
date: '2014-06-26 20:57:44 +0100'
date_gmt: '2014-06-26 19:57:44 +0100'
categories:
- Development
- Visual Studio
---
I've been keeping an eye on the development of [Roslyn](https://github.com/dotnet/roslyn) ever since Anders Hejlsberg announced Microsoft were open sourcing it at Build 2014. For those of you who don't know what Roslyn is, it is Microsoft's new C# and VB.NET compiler platform. There are many aspects to it, and if you want a nice overview Schabse Laks has a couple of [blog](http://blog.slaks.net/2014-04-07/exploring-roslyn-part-1-introduction/) [posts](http://blog.slaks.net/2014-05-21/exploring-roslyn-part-2-inside-end-user-preview/) on the subject.

Most developers seem to be excited by the new C# 6.0 language and the future of the language going forward &ndash; I can see why, C# hasn't really changed that much recently. Whilst I am interested in the language, another thing that has got me really excited as a C# developer is the Language Service. 

# Language Service
The language service is what Visual Studio uses to talk to the compiler to understand your code. Previously this was implemented as a series of "hacks" between Visual Studio and the compilers. This made it hard for the Visual Studio team to implement many decent refactoring experiences. The last time anything new really appeared for the "coders" was in [VS2010](http://blogs.wrox.com/article/7-refactoring-methods-in-visual-studio-2010/) when the existing refactoring tools were released. Two full versions of VS later, and we still have the same refactoring features. Whilst the C# team have been busy working on Roslyn, products like Jet Brains ReSharper have come along with loads of features of their own, adding refactoring tools and code analysis. But I think times are changing...

For those of you who have installed "Visual Studio 14" or the Roslyn End User Preview, you are seeing the beginning, of what I think, will be a revolution to Visual Studio's coding experience for C# (as well as VB.NET).

# New Features
Here's a quick overview of some of the features added already:

Visualising using directives that are not needed.
-- 

![Usings]({{ site.contenturl }}Roslyn-RemoveUsings.png)

Here you can see that I don't need three of my five using directives so they are coloured grey.<&#47;span>

Ctrl + . to Resolve
---

Taking the previous "issue" with my code I can just place the caret on any of the lines with an issue and press Ctrl + . (full stop) to fix it.

![Remove Usings]({{ site.contenturl }}Roslyn-RemoveUsingsAction.png)

You even get a preview of what your class will look like when "fixed".

Ctrl + . has been used to Resolve issues with your code before (e.g. add using directives), but now it has previews and can suggest fixes to new problems. For example, it could suggest not to use Hungarian Notation and remove the prefix, this would be a lot better experience than the existing Code Analysis [CA1704](http://msdn.microsoft.com/en-us/library/bb264492.aspx) rule.

Alt + . and Refactoring
---

Since VS2010, the basic refactoring was done via a series of keyboard combination shortcuts. Ctrl + R, M to Extract Method is the only one I remember, the others I know are there but I can't remember the keyboard shortcuts. Now everything is under Alt + . and is context sensitive.

So if I select a few statements in a block of code and do Alt + . get the option to Extract Method, select a field and do Alt + . I get Encapsulate Field, select the class name, Extract Interface, you get the idea.

The interface for renaming has changed too to include live preview and errors.

![Remove Usings]({{ site.contenturl }}Roslyn-NewMethod.png)

Above you can see a New Method I've extracted and the Live Preview of renaming. If I decided to call "NewMethod" "Foo" I'd get this error because I already have method called Foo.

![Remove Usings]({{ site.contenturl }}Roslyn-NewMethodError.png)

Code Lens
---

Code Lens is a heads up display that is already available in VS2013 Ultimate and is powered by Roslyn to provide code and source control information inline in the editor. I've only played with this during the CTP of VS2013, but it seemed really promising &ndash; I'm now waiting on Microsoft to move it from the Ultimate SKU to Premium.

![CodeLens](https://x2jsrq.blu.livefilestore.com/y2pHvnYw8ZovzeKdsT9oEAT-NasfcccvLTyqpUAZWrmBdGTwNgO85YBV3QkWXgmi_I7BUC4pMIDUbEiLgeVImTwFsQxjfOZ9Y-7MrZR10256Ew/codelens2.png?psid=2)

# Visual Studio 14
	
All the aforementioned features are in VS2013 + End User Preview, Roslyn will actually ship enabled in the next Visual Studio code named "[Visual Studio 14](http://blogs.msdn.com/b/visualstudio/archive/2014/06/03/visual-studio-14-ctp-now-available.aspx)". This has an early preview available and already more refactoring features have appeared. For example, Soma mentions a new Introduce Local refactoring in his [blog post](http://blogs.msdn.com/b/somasegar/archive/2014/06/03/first-preview-of-visual-studio-quot-14-quot-available-now.aspx).

This sort of stuff isn't really ground breaking from a developer experience point of view and it's nothing new for people who use Visual Studio add-ins like ReSharper. But, it is proof that Visual Studio's Editor is back in the game.

My opinion is that from now until VS 14 RTM ships, the C# and VS team will be focusing their efforts on stabilising the Compiler aspect of Roslyn and making sure everything "just works", we may see a few more refactoring tools appear in the next update, but I'm not expecting much.

# After the RTM

I'm looking forward to when Visual Studio 14 has hit RTM has shipped, what happens next...? The Visual Studio Editor team have time to take a good hard look at what they want to build, the C# compiler team can go back to working on language features. I expect the VS Editor team will be working on some awesome editor experiences, some we might have seen before in other products, others brand new. I cannot see them resting on their laurels once they have the Language Services as a platform to build on, they can do anything they want.

Community
---

The other thing that really excites me is the community aspect, building your own VS Editor extensions that leverage the Language Services from the compiler is now easy. What ideas will the community build, what would you build? I'm hoping that individual extensions will appear first, and then grow into suites of common functionality, and maybe even be implemented by the VS Editor team in the future.

It doesn't just have to be extensions, it is also really easy to write your own diagnostics tools. Already there is a [String.Format Diagnostic](http://visualstudiogallery.msdn.microsoft.com/adbded26-4bc1-4d24-be86-61eef8768eee) package on the VS Gallery. So, where does this leave products like ReSharper? In my opinion, Microsoft always implement the features most people want, there will still be room for people to create their own extensions suites and JetBrains can charge for a professional package. However, now it will be a lot easier for people to build their own, no longer do you need to write a C# Code Analyser, so there could be some awesome free open source extension suites appearing too.

Summary
---

I think the next few updates for Visual Studio will brings lots of exciting and powerful enhancements to the Visual Studio Editor for both the C# and VB.NET developers. It's been a long time coming, but I think Visual Studio is back on the front font and ready to innovate some more.
