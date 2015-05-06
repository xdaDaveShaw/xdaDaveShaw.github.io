---
layout: post
status: publish
published: true
title: Dealing with Code Analysis CA1822 and xUnit.net
author:
  display_name: Dave Shaw
  login: DaveShaw
  email: dave@taeguk.co.uk
  url: http://taeguk.co.uk
author_login: DaveShaw
author_email: dave@taeguk.co.uk
author_url: http://taeguk.co.uk
wordpress_id: 522
wordpress_url: http://taeguk.co.uk/?p=522
date: '2013-11-01 22:40:49 +0000'
date_gmt: '2013-11-01 22:40:49 +0000'
categories:
- Development
- xunit
tags: []
comments: []
---
<p>I recently started working on a new project and decided to use <a href="http:&#47;&#47;xunit.codeplex.com">xUnit.net<&#47;a> as my unit testing framework. I made a simple test class with a test method, but when I build it, Visual Studio Code Analysis complained with a &ldquo;CA1822: Mark members as static&rdquo; warning against my test method.<&#47;p>
<p>Let&rsquo;s assume I have a test for <font face="Consolas">MyClass<&#47;font> that looks like this:<&#47;p>
<pre class="brush: csharp;">public class MyClassTest<br />
{<br />
    [Fact]<br />
    public void TestMyProperty()<br />
    {<br />
        var myClass = new MyClass(1);<br />
        Assert.Equal(1, myClass.MyProperty);<br />
    }<br />
}<br />
<&#47;pre></p>
<p>&nbsp;<&#47;p></p>
<p>In this version, Code Analysis is complaining because <font face="Consolas">TestMyProperty<&#47;font> does not uses any instance members from <font face="Consolas">MyClassTest<&#47;font>. This is all well and good in production code, but I assumed (incorrectly) that you must have instance test methods for the test framework to pick them up. As it turns out, xUnit.net is better than that and works on static methods as well as instance methods. <&#47;p></p>
<p>If these were all the tests I needed, I should mark the method as <font face="Consolas">static<&#47;font>. If all your test methods are <font face="Consolas">static<&#47;font>, you should mark the class as <font face="Consolas">static<&#47;font> too &ndash; otherwise you will get a &ldquo;CA1812: Avoid uninstantiated internal classes&rdquo; warning from Code Analysis.<&#47;p></p>
<p>So the fixed version will look like:<&#47;p>
<pre class="brush: csharp;">public static class MyClassTest<br />
{<br />
    [Fact]<br />
    public static void TestMyProperty()<br />
    {<br />
        var myClass = new MyClass(1);<br />
        Assert.Equal(1, myClass.MyProperty);<br />
    }<br />
}<br />
<&#47;pre></p>
<p>&nbsp;<&#47;p></p>
<p>Now, those of you who have used MSTest and Code Analysis might notice two things here:<&#47;p></p>
<ol>
<li>xUnit.net is not bound by the same restrictions as MSTest. Anything <font face="Consolas">public<&#47;font> with a <font face="Consolas">[Fact]<&#47;font> attribute will be tested.
<li>Why does CA1822 not occur when using the <font face="Consolas">[TestMethod]<&#47;font> attribute from MSTest?<&#47;li><&#47;ol>
<p>To answer #2, I turned to <a href="http:&#47;&#47;ilspy.net&#47;">ILSpy<&#47;a>, and pulled apart the Code Analysis rule assembly to find the following &ldquo;hack&rdquo; by Microsoft. If you want to take a look, the DLL is located in: %ProgramFiles(x86)%\Microsoft Visual Studio 12.0\Team Tools\Static Analysis Tools\FxCop\Rules\PerformanceRules.dll<&#47;p></p>
<p>There is a class for each rule, the one I was interested in was called <font face="Consolas">MarkMembersAsStatic <&#47;font>with the hack located in this method:<&#47;p>
<pre class="brush: csharp;">private static bool IsVSUnitTestMethod(Method method)<br />
{<br />
    if (method.get_IsStatic() ||<br />
        method.get_Parameters().get_Count() > 0 ||<br />
        method.get_ReturnType() != FrameworkTypes.get_Void())<br />
    {<br />
        return false;<br />
    }<br />
    for (int i = 0; i < method.get_Attributes().get_Count(); i++)<br />
    {<br />
        AttributeNode attributeNode = method.get_Attributes().get_Item(i);<br />
        if (attributeNode.get_Type().get_Name().get_Name() ==<br />
            "TestInitializeAttribute" ||<br />
            attributeNode.get_Type().get_Name().get_Name() ==<br />
            "TestMethodAttribute" ||<br />
            attributeNode.get_Type().get_Name().get_Name() ==<br />
            "TestCleanupAttribute")<br />
        {<br />
            return true;<br />
        }<br />
    }<br />
    return false;<br />
}<br />
<&#47;pre></p>
<p><em>Remember, this is disassembled code and has been re-formatted by me<&#47;em>.<&#47;p></p>
<p>That&rsquo;s right, there is an explicit suppression of the CA1822 rule against any method with an attribute called [<font face="Consolas">TestInitialize<&#47;font>], [<font face="Consolas">TestMethod<&#47;font>] or [<font face="Consolas">TestCleanup<&#47;font>]. Well, that explains that little mystery.<&#47;p></p>
<p>&nbsp;<&#47;p></p>
<p>So far, I&rsquo;ve not had any problems with xUnit.net, now I figured this out, and at some point in the future I may post more about my journey through TDD with it.<&#47;p></p>
