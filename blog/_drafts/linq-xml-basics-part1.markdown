---
layout: post
status: draft
published: false
title: LINQ to Xml Basics (part 1)
date: '2015-05-18 20:25:00 +0000'
date_gmt: '2015-05-18 20:25:00 +0000'
categories:
- LINQpad
- Series
---

I’ve answered a number of [stack overflow](http://stackoverflow.com/) questions on basic topics of LINQ to XML, so I thought I would summarise the topics I find most people struggle on into a short series of posts.

The first part of this guide will be on querying simple XML documents to get some values from them into come C# types.

All the samples will be available as [LINQpad](http://LINQpad.net) scripts so you can download them and experiment.

# Getting Started

If you have never done any LINQ-XML before, you need to know that it is only supported in .NET Framework version 3.5 and greater.

You will need a reference to **System.Xml.LINQ.dll** from the GAC and a using directive of `using System.Xml.LINQ;` at the top of your source file. LINQpad automatically takes care of this for you, but you will need it when you’re writing your own.

# Examples

Here is a sample Document that we will be querying:

``` xml
<?xml version="1.0" encoding="UTF-8"?>
<Files>
    <File id="1234" type="document">
        <Name>Document.txt</Name>
        <Size>44</Size>
    </File>
    <File id="5678" type="image">
        <Name>Picture.bmp</Name>
        <Size>100</Size>
    </File>
</Files>
```

It has elements and attributes as well as a few nested elements, so it provides a good range of problems to tackle.

The first thing we will look at, is getting an XML string into an
[`XDocument`](http://msdn.microsoft.com/en-us/library/system.xml.LINQ.xdocument(v=vs.110).aspx) document.
The easiest way to do this is by calling the [`Parse`](https://msdn.microsoft.com/en-us/library/system.xml.LINQ.xdocument.parse(v=vs.110).aspx) method on `XDocument`.
You could also call [`Load`](https://msdn.microsoft.com/en-us/library/system.xml.LINQ.xdocument.load(v=vs.110).aspx) to read the input from file on disc or a stream.

``` c#
//Assuming, "xml" is a String containing our XML.
//It's just this simple.
var document = XDocument.Parse(xml);
```

To traverse the `XDocument` we are going start at the `Root` property and then use the `Elements` method to filter
some elements.

``` c#
document
.Root                //Get the root element - "Files" in our case.
.Elements("File")    //Get the elements called "File" in "Files".
.Dump();
```

This will return:

``` xml
<File id="1234" type="document">
  <Name>Document.txt</Name>
  <Size>44</Size>
</File>

<File id="5678" type="image">
  <Name>Picture.bmp</Name>
  <Size>100</Size>
</File>
```

You don’t have to use `Root`, instead you could use `Elements("Files")`, and it would have worked just the same.
`Root` can be handy if you don’t know what type of XML document you are dealing with and you just want the root
element to get its name (for example, allowing users to upload a variety of documents and selecting the correct
service to process it).

Multiple `Elements` calls can be chained together to traverse deeper into document, for example,
to get all the elements called "Name", you could do this:

``` c#
document
.Root
.Elements("File")                 //Get the elements called "File" in "Files".
.SelectMany(                      //We have multiple File elements, with Elements,
    element =>                    //so we flatten the collection with SelectMany().
        element.Elements("Name")) //Get all the elements in each File element, called "Name".
.Dump();
```

This will return

``` xml
<Name>Document.txt</Name>
<Name>Picture.bmp</Name>
```

This works, but is getting a little complicated, using `SelectMany` already, if we are just after all elements
called name, wouldn’t it be nicer if we could just ask for them from all elements, this is where
[`Descendants`](https://msdn.microsoft.com/en-us/library/system.xml.LINQ.xdocument.load(v=vs.110).aspx) comes in:

``` c#
document
.Root
.Descendants("Name")    //Get the elements called "Name" in "Files" (the Root).
.Dump();
```

This will also return:

``` xml
<Name>Document.txt</Name>
<Name>Picture.bmp</Name>
```

The slight problem with this approach is that if you have lots of "Name" elements and you are only interested in a certain subset you may need to use some additional filtering.
This brings us nicely onto the topic of filtering, we’ve already see that you can filter by element name, you could also filter by attribute, using familiar LINQ syntax.

The following example, finds a "File" element by given a file "id", and then creates an anonymous type with the name, size and type as a result.

``` c#
Int32 fileId = 1234;
document
.Root
.Elements("File")                              //Get the elements called "File" in "Files". Where the "id"
.Where(e => Convert.ToInt32(e.Attribute("id").Value) == fileId)  // attribute has a value that matches fileId.
.Select(
    e =>                                       //e is now any element called "File" with a matching ID.
        new
        {
            Name = e.Element("Name").Value,    //Get the element called Name's value.
            Size = e.Element("Size").Value,    //Get the element called Sizes's value.
            Type = e.Attribute("type").Value,  //Get the value from the attribute from File called Type.
        })
.Single()                                      //Ensure there is only one.
.Dump();
```

This will return:

``` plain
Name  |  Document.txt
Size  |  44
Type  |  document
```

There’s quite a bit going on in the above sample, so you might have to re-read it, and run it a few times to see,
but it is a typical example of how to get date from an XML document into a C# type – albeit an anonymous
one in this case, but it could be any type you have in your application.

# Conclusion

This hopefully shows how you can quickly query XML Documents using the power of LINQ to XML to filter and project elements and attributes.

In part 2, I will be going through some ways to make querying simpler, and dealing with namespaces.

# Download

The LINQpad script for these examples can be found [here on GitHub](https://github.com/xdaDaveShaw/Linq-Xml-Basics/blob/master/Part1.linq).
