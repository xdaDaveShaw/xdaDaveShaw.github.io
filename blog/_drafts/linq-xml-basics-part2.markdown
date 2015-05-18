---
layout: post
status: draft
published: false
title: Linq to Xml Basics (part 2)
date: '2015-05-18 20:25:00 +0000'
date_gmt: '2015-05-18 20:25:00 +0000'
categories:
- Linqpad
- Series
---

This is the second part of my mini-series on getting started with Linq to XML, you can find **Part 1 here**.

In this part I’ll go through a few tricks to make querying easier and dealing with namespaces.

All the samples will be available as [Linqpad](http://linqpad.net) scripts so you can download them and experiment.

# Namespaces

Many XML documents will contain namespaces (you can google if you want to know why) and that makes querying a little tricky if you have never had to deal with them before.

Here is a sample Document that we will be querying:

{% highlight xml %}
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
{% endhighlight %}

It represents an XML response from some imaginary library system, and is probably not the best way to represent data, but it will serve the needs of this post, and also you find allsorts of weird XML schemas in the wild.

Continuing from Part 1, you could be forgiven for thinking that the following query would list all the "Name" elements in the document:

{% highlight c# %}
document
.Descendants("Name")
.Select(name => name.Value)
.Dump();
{% endhighlight %}

This doesn’t return anything however.

This is probably a good thing, the document has two elements called Name. One that represents a Person and one that represents a Book. You might expect it to return the Person Name elements though. The reason is doesn’t is because all elements in the document have a namespace. The obvious ones are prefixed with `b:` any are pretty easy to spot. The less obvious is, all the other elements. Those are in the "default namespace" of the document which is declared in the root element: `<Library xmlns="http://taeguk.co.uk/People/" ... />`. This `xmlns` (pronounced zoon-lens by a colleague of mine) is what prevents the previous example from returning any results.

We can remedy this by declaring an `XNamespace` variable and using it as part of the name we pass to the `Elements()` method:

{% highlight c# %}
//Cannot use 'var' because it would be a string.
//You need to use XNamespace, then string gets implicitly 
//converted to the correct type
XNamespace ns = "http://taeguk.co.uk/People/";  //Matches the xmlns from the root element.  
document
.Descendants(ns + "Name")        //Addition of XNamespace and string produces an XName.
.Select(name => name.Value)
.Dump();
{% endhighlight %}

This will now return:

    IEnumerable<String> (2 items) 
    Alice 
    Bob 

  

As you can see from the comments, you cannot use `var` for type inference for an `XNamespace`.





asd









asd







asd
