---
layout: post
status: draft
published: false
title: LINQ to Xml Basics (part 2)
date: '2015-05-18 20:25:00 +0000'
date_gmt: '2015-05-18 20:25:00 +0000'
categories:
- LINQpad
- Series
---

This is the second part of my mini-series on getting started with LINQ to XML, you can find [Part 1 here].({% post_url blog/####-##-##-LINQ-xml-basics-part1 %})

In this post I’ll go through a few tricks to make querying easier and dealing with namespaces.

All the samples will be available as [LINQpad](http://LINQpad.net) scripts so you can download them and experiment.

# Namespaces

Many XML documents will contain namespaces (you can google if you want to know why) and that makes querying a little tricky if you have never had to deal with them before.

Here is a sample Document that we will be querying:

``` xml
<?xml version="1.0" encoding="UTF-8"?>
<Library xmlns="http://taeguk.co.uk/People/" xmlns:b="http://taeguk.co.uk/Books/">
  <Person id="1">
    <Name>Alice</Name>
    <b:Books>
      <b:Name id="1" rating="5">Philosopher's Stone</b:Name>
      <b:Name id="2" rating="5">Chamber of Secrets</b:Name>
    </b:Books>
  </Person>
  <Person id="2">
    <Name>Bob</Name>
    <b:Books>
      <b:Name id="3" rating="5">Prisoner of Azkaban</b:Name>
      <b:Name id="4">Goblet of Fire</b:Name>
    </b:Books>
  </Person>
</Library>
```

It represents an XML response from some imaginary library system, and is probably not the best way to represent data, but it will serve the needs of this post, and you can find allsorts of weird XML schemas the wild.

Continuing from Part 1, you could be forgiven for thinking that the following query would list all the "Name" elements in the document:

``` c#
document
.Descendants("Name")
.Select(name => name.Value)
.Dump();
```

This doesn’t return anything however.

This is probably a good thing, the document has two elements called "Name". One that represents a Person and one that represents a Book. You might expect it to return the Person Name elements though. The reason is doesn’t is because all elements in the document have a namespace. The obvious ones are prefixed with `b:` any are pretty easy to spot. The less obvious is, all the other elements. Those are in the "default namespace" of the document which is declared in the root element: `<Library xmlns="http://taeguk.co.uk/People/" ... />`. This `xmlns` (pronounced zoon-lens by a colleague of mine) is what prevents the previous example from returning any results.

We can remedy this by declaring an `XNamespace` variable and using it as part of the name we pass to the `Elements()` method:

``` c#
//Cannot use 'var' because it would be a string.
//You need to use XNamespace, then string gets implicitly
//converted to the correct type
XNamespace ns = "http://taeguk.co.uk/People/";  //Matches the xmlns from the root element.
document
.Descendants(ns + "Name")        //Addition of XNamespace and string produces an XName.
.Select(name => name.Value)
.Dump();
```

This will now return:

```plain
Alice
Bob
```

As you can see from the comments, you cannot use `var` for type inference for an `XNamespace`.

When you need to traverse down the document you have to use the namespace on all the element declarations. To get the element that contains the books rented by Bob:

``` c#
document
.Root
.Elements(ns + "Person")
.Where(xe => xe.Element(ns + "Name").Value == "Bob")
.Dump();
```

Returns the following `XElement`:

``` xml
<Person id="2" xmlns="http://taeguk.co.uk/People/">
  <Name>Bob</Name>
  <b:Books xmlns:b="http://taeguk.co.uk/Books/">
    <b:Name id="3" rating="5">Prisoner of Azkaban</b:Name>
    <b:Name id="4">Goblet of Fire</b:Name>
  </b:Books>
</Person>
```

To get information about the books you just use the namespace of `b:` which is `http://taeguk.co.uk/Books/`. This example gets the value of the `name` attribute of all the books in the document:

``` c#
XNamespace bookNs = "http://taeguk.co.uk/Books/";
document
.Descendants(bookNs + "Name")
.Select(name => name.Value)
.Dump();
```

This will return:

``` plain
Philosopher's Stone
Chamber of Secrets
Prisoner of Azkaban
Goblet of Fire
```

# Getting Values

This section will show you how to write less code to get values out of elements and attributes.

To get all the values from the `id` attribute you can use the following code which should seem familiar to the previous examples:

``` c#
document
.Root
.Descendants(bookNs + "Name")
.Select(book => Convert.ToInt32(book.Attribute("id").Value))
.Dump();
```

This will return an `IEnumerable<Int32>`:

``` plain
1
2
3
4
```

But what about getting the values from the `rating` attribute, where we there is a book without a rating, for example: `<b:Name id=""4"">Goblet of Fire</b:Name>`. Trying to use the `.Value` property of the `XAttribute` will throw a `NullReferenceException` if the attribute is not specified.
One attempt might be to check the attribute is not null and only call `Convert.ToInt32` on the value of those, and default the others to `null`:

``` c#
var avgRating =
  document
  .Root
  .Descendants(bookNs + "Name")
  .Select(book => book.Attribute("rating") != null ? (Int32?)Convert.ToInt32(book.Attribute("rating").Value) : null)
  .Average();

avgRating.Dump();

//prints 5
```

This is a little verbose and isn't very readable, but it does do the job.
Those of you who like to keep their code "DRY" might try to avoid reading the `book.Attribute("rating")` by creating an anonymous method instead:

``` c#
avgRating =
  document
  .Root
  .Descendants(bookNs + "Name")
  .Select(
    book =>
    {
      var att = book.Attribute("rating");
      return
        att != null ? (Int32?)Convert.ToInt32(att.Value) : null;
    })
  .Average();

avgRating.Dump();

//prints 5
```

OK, this has reduced the duplicate call to get the value from the `book.Attribute`, but has made the code even more verbose,
surely there must be a better way.
One solution to avoid a `NullReferenceException` would be to use the [null-conditional operator](https://msdn.microsoft.com/en-us/library/dn986595.aspx),
but that would be incorrect here because the default for `Int32` is `0`, not `null` so the average would be `3.75` instead of `5`.

``` c#
avgRating =
  document
  .Root
  .Descendants(bookNs + "Name")
  .Select(book => Convert.ToInt32(book.Attribute("rating")?.Value))
  .Average();
avgRating.Dump();

//prints 3.75
```

So, that didn't work, but there is a solution that is both succint and correct.
Just cast the `XAttribute` to the type you want. If it's a value type like in our example,
you can make it nullable to handle missing attributes:

``` c#
avgRating =
  document
  .Root
  .Descendants(bookNs + "Name")
  .Select(book => (Int32?)book.Attribute("rating"))
  .Average();

avgRating.Dump();

//prints 5
```

That's lot better. The same technique can be applied to other types such as `DateTime`.

# Conclusion

In this post we have looked at how to deal with namespaces in documents and how to get data out of attributes without having to write loads of code that we don't need to.

In the 3rd and final part, I'll cover writing and updating XML documents using LINQ to XML.

# Download

The LINQpad script for these examples can be found [here on GitHub](https://github.com/xdaDaveShaw/LINQ-Xml-Basics/blob/master/Part2.LINQ).
