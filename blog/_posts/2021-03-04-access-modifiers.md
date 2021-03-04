---
layout: post
status: publish
published: true
title: Access modifiers
date: '2021-03-04 21:35:00 +0000'
date_gmt: '2021-03-04 21:35:00 +0000'
categories:
- C#
- .NET
- Development
---

This post is inspired by and in response to [Pendulum swing: internal by default][1] by [Mark Seemann][2].

---

Access modifiers in .NET can be used in a number of ways to achieve things, in this post I'll talk about how I used them
and why.

Firstly I should point out, I am NOT a library author, if I were, I may do things differently.

## Public and Internal classes

In .NET the `public` and `internal` access modifiers control the visibility of a class from another assembly. Classes that
are marked as public can be seen from another project/assembly, and those that are internal cannot.

I view public as saying, "here is some code for other people to use". When I choose to make something public, I'm making
a conscious decision that I want another component of the system to use this code. If they are dependant on me, then this
is something I want them to consume.

For anything that is internal, I'm saying, this code is part of my component that only I should be using.

When writing code within a project, I can use my public and internal types interchangeably, there is no difference
between them.

If in my project I had these 2 classes:

```csharp
public Formatter { public void Format(); }

internal NameFormatter { public void Format(); }
```

and I was writing code elsewhere in my project, then I can choose to use either of them - there's nothing stopping or
guiding me using one or the other. There's no encapsulation provided by the use of internal.

> _NOTE_: When I say _'I'_, I actually mean, a team working on something of significant complexity, and that not everyone
> working on the code may know it inside out. The objective is to make it so that future developers working on the code
> "fall into the pit of success".

If my intention was that `NameFormatter` must not be used directly, I may use a different approach to "hide" it. For
example a private nested class:

```csharp
public Formatter
{
    private class NameFormatter() { }
}
```

or by using namespaces:

```
Project.Feature.Formatter
Project.Feature.Formatters.NameFormatter
```

These might not be the best approach, just a few ideas on how to make them less "discoverable".
The point I'm hoping to make is that within your own project internal doesn't help, if you want to encapsulate logic, 
you need to use private (or protected).

In larger systems where people are dependant on my project, everything is internal by default, and only made public to
surface the specific features they need.

### Testing

So where does this leave me with unit testing? I am quite comfortable using [`InternalsVisibleTo`][3] to allow my tests
access to the types it needs to.

The system I work on can have a lot of functionality that is `internal` and only triggered by its own logic. Such as a
plugin that is loaded for a UI, or a message processor.

Testing *everything* through a "Receive Message" type function could be arduous. 
That said, I do like "outside-in" testing and I can test many things that way, 
but it is not reasonable to test everything that way.

In one of the systems I maintain, I do test a lot of it this way:

```
Arrange
Putting the system in a state

Act
Sending an input into the system

Assert
Observe the outputs are what is expected
```

By sending inputs and asserting the outputs tells me how the system works.

However, some subcomponents of this system are rather complex on their own, such as the 
[RFC4517 Postal Address][4] parser I had to implement.
When testing this behaviour it made much more sense to test this particular class in isolation with a more "traditional"
unit test approach, such as Xunit.net's Theory tests with a simple set of Inputs and Expected outputs.

I wouldn't have wanted to make my parser public, it wasn't part of my component my dependants should care about.

> I hope to write more about my testing approaches in the future.

## Another use case

For reasons I won't go into, in one of the systems I work on a single "module" is comprised of a number
of assemblies/projects, and the system is comprised of many modules.
For this we use "InternalsVisibleTo" only so that the projects in the same module can see each other - in addition to
unit testing as stated above.

This allows a single module to see everything it needs to, but dependant modules to only see what we choose to make visible. Keeping a small and focused API helps you know what others depend on and what the impact of your changes are.

## Static Analysis

When you use static analysis like [.NET Analysers][5] they make assumptions about what your code's purpose is based
on the access modifier. To .NET Analysers, public code is library code, to be called by external consumers.

A few examples of things only apply to public class:

 - Argument validation - you must check arguments are not null (also see below)
 - Correct (or _formal_) `IDisposable` implementation.
 - Spelling checks

The options you have are disable these rules, suppress them, or add the requisite code to support them.

- Disabling the rules, means you don't get the benefit of the analysis on any public code you may have that was
written for use by external callers.
- Suppressing them is messy, and you should justify them so you remember why you disabled it.
- Adding requisite code is arduous. e.g. Guards against nulls.

When you are using [Nullable Reference Types][6] from C# 8.0 the compiler protects you from accidentally dereferencing null. 
But `public` means that anyone can write code to call it, so it errs on the side of caution and still warns you
that arguments may be null and you should check them.

## Wrapping up

Given the limited value within a project of using `public`, I always default to `internal` and will test against internal
classes happily, only using `public` when I think something should be part of a public API to another person or part of
the system.

Internal types are only used by trusted and known callers. Nullable Reference type checking works well with them,
as it knows they can only instantiated from within known code, allowing a more complete analysis.

If you are writing code for that is to be maintained for years to come by people other than yourself, using public or
internal won't help, you need to find other approaches to ensure that code is encapsulated and consumed appropriately.

 [1]:https://blog.ploeh.dk/2021/03/01/pendulum-swing-internal-by-default/
 [2]:https://blog.ploeh.dk/
 [3]:https://docs.microsoft.com/en-us/dotnet/api/system.runtime.compilerservices.internalsvisibletoattribute?view=net-5.0
 [4]:https://tools.ietf.org/html/rfc4517#section-3.3.28
 [5]:https://docs.microsoft.com/en-us/visualstudio/code-quality/roslyn-analyzers-overview?view=vs-2019
 [6]:https://docs.microsoft.com/en-us/dotnet/csharp/nullable-references
