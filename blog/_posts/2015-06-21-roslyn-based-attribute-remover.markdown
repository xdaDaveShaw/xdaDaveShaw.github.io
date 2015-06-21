---
layout: post
status: publish
published: true
title: Roslyn Based Attribute Remover
date: '2015-06-21 21:30:00 +0000'
date_gmt: '2015-06-21 22:30:00 +0100'
categories:
- Development
- Linqpad
- Roslyn
---

I'm a big fan of [XUnit][1] as a replacement for MSTest and use it extensively in my home projects, but I'm still struggling to find a way to integrate it into my work projects.

This post looks at one of the obstacles I had to overcome, namely the use of `[TestCategory("Atomic")]` on all tests that are run on TFS as part of the build. The use of this attribute came about because the MSTest test runner did not support a concept of "run all tests without a category", so we came up with an explicit category called "Atomic" - probably not the best decision in hindsight. The XUnit test runner does not support test categories, so I needed to find a way to remove the `TestCategory` attribute with the value of `Atomic` from any method. I'm sure I could have used regex to solve this, and I'm sure that would have caused [more problems][2]:

[![To generate #1 albums, 'jay --help' recommends the -z flag.][3]][4]

Instead I created a Linqpad script and used the syntactic analyser from the [Microsoft.CodeAnalysis][5] package.

> Install-Package Microsoft.CodeAnalysis -Pre

I found that the syntactic analyser allowed me to input some C# source code, and by writing my own `CSharpSyntaxRewriter`, remove any attributes I didn't want.

I started by creating some C# that had the `TestCategory` attribute applied in as many different ways as possible:

{% highlight c# %}
namespace P
{
    class Program
    {
        public void NoAttributes() { }

        [TestMethod, TestCategory(""Atomic"")]
        public void OnOneLine() { }

        [TestMethod]
        [TestCategory(""Atomic"")]
        public void SeparateAttribute() { }
        
        //snip...
        //And so on down to, right down to...
                
        [TestMethod, TestCategory(""Atomic""), TestCategory(""Atomic"")]
        public void TwoAttributesOneLineAndOneThatDoesntMatch() { }
    }
}
{% endhighlight %}

You can see all the examples I tested against in the [Gist][6].

The `CSharpSyntaxRewriter` took a lot of messing around with to get right, but I eventually figured that by overriding the `VisitAttributeList` method I could remove attributes from the syntax tree as they were visited.

To get some C# code into a syntax tree, there is the obviously named `CSharpSyntaxTree.ParseText(String)` method. You can then get a `CSharpSyntaxRewriter` (in my case my own `AttributeRemoverRewriter` class) to visit everything by calling `Visit()`. Because this is all immutable, you need to grab the result, which can now be converted into a string and dumped out. 

{% highlight c# %}
var tree = CSharpSyntaxTree.ParseText(code);
var rewriter = new AttributeRemoverRewriter(
    attributeName: "TestCategory", 
    attributeValue: "Atomic");

var rewrittenRoot = rewriter.Visit(tree.GetRoot());

rewrittenRoot.GetText().ToString().Dump();
{% endhighlight %}

The interesting part of the `AttributeRemoverRewriter` class is the `VisitAttributeList` method which finds and removes attribute nodes that are not needed:

{% highlight c# %}
public override SyntaxNode VisitAttributeList(AttributeListSyntax attributeList)
{
    var nodesToRemove = 
        attributeList
        .Attributes
        .Where(
            attribute => 
                AttributeNameMatches(attribute)
                &&
                HasMatchingAttributeValue(attribute))
        .ToArray();

    if (nodesToRemove.Length == 1 && attributeList.Attributes.Count == 1)
    {
        //Remove the entire attribute
        return 
            attributeList.RemoveNode(attributeList, SyntaxRemoveOptions.KeepNoTrivia);
    }
    else
    {
        //Remove just the matching ones recursively
        foreach (var node in nodesToRemove)
            return
                VisitAttributeList(attributeList.RemoveNode(node, SyntaxRemoveOptions.KeepNoTrivia));
    }
    
    return 
        base.VisitAttributeList(attributeList);
}
{% endhighlight %}

The `AttributeNameMatches` method is implemented to find an attribute that *starts with* `TestCategory`, this is because attributes in .NET have `Attribute` at the end of their name e.g. `TestCategoryAttribute`, but most people never type it. I figured in this case it was more likley to exist than to have another attribute starting with `TestCategory`. I don't think there is an elegant way to avoid using `StartsWith` in the syntactic analyser, I would have had to switch to the sematic analyser and that would have made this a much more complicated solution. 

The `HasMatchingAttributeValue` pretty much does what it says, it looks for the value of the attribute been just `Atomic` and nothing else.

Once the nodes that match are found, there were 2 choices:

**Remove the whole attribute**

If all the attributes match, remove the entire attribute node. For example:

{% highlight c# %}
[TestMethod]
[TestCategory(""Atomic"")]
public void SeparateAttribute() { }
{% endhighlight %}

When the visitor reaches the `[TestCategory(""Atomic"")]` attribute, the entire attribute node should be removed, if not then the attribute is removed but the `[]` remains.

**Remove just the matching attributes**

If there are some attributes that do not need removing, then just the matching one should be removed. For example:

{% highlight c# %}
[TestMethod, TestCategory(""Atomic"")]
public void OnOneLine() { }
{% endhighlight %}

When the visitor reaches the attribute on this method, it should only remove the attribute that matches, the `TestMethod` should be left alone. It then recursively checks the attribute again incase there is more than one, and removes any others that match.

# Conclusion
Using Roslyn was a bit of a steep learning curve to start with, but once I found out what I was doing, I knew I could rely on the Roslyn team to have dealt with all the different ways of implementing attributes in C#. If I were to try and use regex to find and remove some of the more complicated ones, and deal with the other edge cases I'd have gone mad by now.

 - You can get the full Gist [here][6]. 

 If you paste this into a Linqpad "program" and then just install the NuGet Package you should be able to try it out. 
 **Note** this was built against the RC2 version of the package.
 
   [1]: http://xunit.github.io
   [2]: http://blog.codinghorror.com/regular-expressions-now-you-have-two-problems/
   [3]: {{ site.contenturl }}attributes-perl-problems.png (To generate #1 albums, 'jay --help' recommends the -z flag.)
   [4]: https://xkcd.com/1171/
   [5]: https://www.nuget.org/packages/Microsoft.CodeAnalysis
   [6]: https://gist.github.com/xdaDaveShaw/87643170e5fa97b7da3b