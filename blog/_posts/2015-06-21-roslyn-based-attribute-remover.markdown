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

**Major Update 1-Aug-2015**: Changed `VisitAttributeList` to `VisitMethodDeclaration` to fix some bugs with the help of [Josh Varty][7].

I'm a big fan of [XUnit][1] as a replacement for MSTest and use it extensively in my home projects, but I'm still struggling to find a way to integrate it into my work projects.

This post looks at one of the obstacles I had to overcome, namely the use of `[TestCategory("Atomic")]` on all tests that are run on TFS as part of the build. The use of this attribute came about because the MSTest test runner did not support a concept of "run all tests without a category", so we came up with an explicit category called "Atomic" - probably not the best decision in hindsight. The XUnit test runner does not support test categories, so I needed to find a way to remove the `TestCategory` attribute with the value of `Atomic` from any method. I'm sure I could have used regex to solve this, and I'm sure that would have caused [more problems][2]:

![To generate #1 albums, 'jay --help' recommends the -z flag.][3]

*via [xkcd][4]*

Instead I created a Linqpad script and used the syntactic analyser from the [Microsoft.CodeAnalysis][5] package.

    PM> Install-Package Microsoft.CodeAnalysis

I found that the syntactic analyser allowed me to input some C# source code, and by writing my own `CSharpSyntaxRewriter`, remove any attributes I didn't want.

I started by creating some C# that had the `TestCategory` attribute applied in as many different ways as possible:

{% highlight c# %}
namespace P
{
    class Program
    {
        public void NoAttributes() { }

        [TestMethod, TestCategory("Atomic")]
        public void OnOneLine() { }

        [TestMethod]
        [TestCategory("Atomic")]
        public void SeparateAttribute() { }
        
        //snip...
        //And so on down to, right down to...
                
        [TestMethod, TestCategory("Atomic"), TestCategory("Atomic")]
        public void TwoAttributesOneLineAndOneThatDoesntMatch() { }
    }
}
{% endhighlight %}

You can see all the examples I tested against in the [Gist][6].

The `CSharpSyntaxRewriter` took a lot of messing around with to get right, but I eventually figured that by overriding the `VisitMethodDeclaration` method I could remove attributes from the syntax tree as they were visited.

To get some C# code into a syntax tree, there is the obviously named `CSharpSyntaxTree.ParseText(String)` method. You can then get a `CSharpSyntaxRewriter` (in my case my own `AttributeRemoverRewriter` class) to visit everything by calling `Visit()`. Because this is all immutable, you need to grab the result, which can now be converted into a string and dumped out. 

{% highlight c# %}
var tree = CSharpSyntaxTree.ParseText(code);
var rewriter = new AttributeRemoverRewriter(
    attributeName: "TestCategory", 
    attributeValue: "Atomic");

var rewrittenRoot = rewriter.Visit(tree.GetRoot());

rewrittenRoot.GetText().ToString().Dump();
{% endhighlight %}

The interesting part of the `AttributeRemoverRewriter` class is the `VisitMethodDeclaration` method which finds and removes attribute nodes that are not needed:

{% highlight c# %}
public override SyntaxNode VisitMethodDeclaration(MethodDeclarationSyntax node)
{
    var newAttributes = new SyntaxList<AttributeListSyntax>();

    foreach (var attributeList in node.AttributeLists)
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

        //If the lists are the same length, we are removing all attributes and can just avoid populating newAttributes.
        if (nodesToRemove.Length != attributeList.Attributes.Count)
        {
            var newAttribute =
                (AttributeListSyntax)VisitAttributeList(
                    attributeList.RemoveNodes(nodesToRemove, SyntaxRemoveOptions.KeepNoTrivia));

            newAttributes = newAttributes.Add(newAttribute);
        }
    }

    //Get the leading trivia (the newlines and comments)
    var leadTriv = node.GetLeadingTrivia();
    node = node.WithAttributeLists(newAttributes);

    //Append the leading trivia to the method
    node = node.WithLeadingTrivia(leadTriv);
    return node;
}
{% endhighlight %}

The `AttributeNameMatches` method is implemented to find an attribute that *starts with* `TestCategory`, this is because attributes in .NET have `Attribute` at the end of their name e.g. `TestCategoryAttribute`, but most people never type it. I figured in this case it was more likley to exist than to have another attribute starting with `TestCategory`. I don't think there is an elegant way to avoid using `StartsWith` in the syntactic analyser, I would have had to switch to the sematic analyser and that would have made this a much more complicated solution. 

The `HasMatchingAttributeValue` pretty much does what it says, it looks for the value of the attribute been just `Atomic` and nothing else.

Once the nodes that match are found, it checks if the number of attributes on a method is equal to the number it wants to remove, if so the `newAttributes` list is not populated and the method is updated to keep its trivia, but without any attributes. This shouldn't be the case for this specific scenario because just a `TestCategory` on its own  doesn't make sense.

**Remove just the matching attributes**

If there are some attributes that do not need removing, then just the matching one should be removed. For example:

{% highlight c# %}
[TestMethod, TestCategory("Atomic")]
public void OnOneLine() { }
{% endhighlight %}

When the visitor reaches the attributes on this method, it will populate the `newAttributes` list with just the attributes we want to keep and then update the method so that it has just the remaining attributes its trivia.

# Conclusion
Using Roslyn was a bit of a steep learning curve to start with, but once I found out what I was doing, I knew I could rely on the Roslyn team to have dealt with all the different ways of implementing attributes in C#. That didn't stop me from finding what appears to be a bug causing me to re-write bits of the script and this post, and some more edge cases when I ran it across a > 500 test classes.

However, if I were to try and use regex to find and remove some of the more complicated ones, and deal with the other edge cases, I'd have gone mad by now.

 - You can get the full Gist [here][6]. 

 If you paste this into a Linqpad "program" and then just install the NuGet Package you should be able to try it out. 
 **Note** this was built against the 1.0.0 version of the package.
 
   [1]: http://xunit.github.io
   [2]: http://blog.codinghorror.com/regular-expressions-now-you-have-two-problems/
   [3]: {{ site.contenturl }}attributes-perl-problems.png
   [4]: https://xkcd.com/1171/
   [5]: https://www.nuget.org/packages/Microsoft.CodeAnalysis
   [6]: https://gist.github.com/xdaDaveShaw/87643170e5fa97b7da3b
   [7]: http://stackoverflow.com/questions/31749997/how-to-remove-all-member-attribute-but-leave-an-empty-line/31756034#31756034