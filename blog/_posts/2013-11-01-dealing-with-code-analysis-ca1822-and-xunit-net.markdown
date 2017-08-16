---
layout: post
status: publish
published: true
title: Dealing with Code Analysis CA1822 and xUnit.net
date: '2013-11-01 22:40:49 +0000'
date_gmt: '2013-11-01 22:40:49 +0000'
categories:
- Development
- xunit
---
I recently started working on a new project and decided to use xUnit.net as my unit testing framework. I made a simple test class with a test method, but when I build it, Visual Studio Code Analysis complained with a "CA1822: Mark members as static" warning against my test method.

Lets assume I have a test for `MyClass` that looks like this:

```c#
public class MyClassTest
{
    [Fact]
    public void TestMyProperty()
    {
        var myClass = new MyClass(1);
        Assert.Equal(1, myClass.MyProperty);
    }
}
```

In this version, Code Analysis is complaining because `TestMyProperty` does not uses any instance members from `MyClassTest`. This is all well and good in production code, but I assumed (incorrectly) that you must have instance test methods for the test framework to pick them up. As it turns out, xUnit.net is better than that and works on static methods as well as instance methods.

If these were all the tests I needed, I should mark the method as `static`. If all your test methods are `static`, you should mark the class as `static` too &ndash; otherwise you will get a"CA1812: Avoid uninstantiated internal classes" warning from Code Analysis.

So the fixed version will look like:

```c#
public static class MyClassTest
{
    [Fact]
    public static void TestMyProperty()
    {
        var myClass = new MyClass(1);
        Assert.Equal(1, myClass.MyProperty);
    }
}
```

Now, those of you who have used MSTest and Code Analysis might notice two things here:

 - xUnit.net is not bound by the same restrictions as MSTest. Anything `public` with a `[Fact]` attribute will be tested.
 - Why does CA1822 not occur when using the `[TestMethod]` attribute from MSTest?
 
To answer #2, I turned to ILSpy, and pulled apart the Code Analysis rule assembly to find the following "hack" by Microsoft. If you want to take a look, the DLL is located in: `%ProgramFiles(x86)%\Microsoft Visual Studio 12.0\Team Tools\Static Analysis Tools\FxCop\Rules\PerformanceRules.dll`

There is a class for each rule, the one I was interested in was called `MarkMembersAsStatic` with the hack located in this method:

```c#
private static bool IsVSUnitTestMethod(Method method)
{
    if (method.get_IsStatic() ||
        method.get_Parameters().get_Count() > 0 ||
        method.get_ReturnType() != FrameworkTypes.get_Void())
    {
        return false;
    }
    for (int i = 0; i < method.get_Attributes().get_Count(); i++)
    {
        AttributeNode attributeNode = method.get_Attributes().get_Item(i);
        if (attributeNode.get_Type().get_Name().get_Name() ==
            "TestInitializeAttribute" ||
            attributeNode.get_Type().get_Name().get_Name() ==
            "TestMethodAttribute" ||
            attributeNode.get_Type().get_Name().get_Name() ==
            "TestCleanupAttribute")
        {
            return true;
        }
    }
    return false;
}
```

*Remember, this is disassembled code and has been re-formatted by me*

That’s right, there is an explicit suppression of the CA1822 rule against any method with an attribute called `[TestInitialize]`, `[TestMethod]` or `[TestCleanup]`. Well, that explains that little mystery.


So far, I’ve not had any problems with xUnit.net, now I figured this out, and at some point in the future I may post more about my journey through TDD with it.