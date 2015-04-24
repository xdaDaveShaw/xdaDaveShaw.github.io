---
layout: post
status: publish
published: true
title: Combining Loc Files from Groundspeak Geocaching.com
date: '2013-04-01 20:00:00 +0100'
date_gmt: '2013-04-01 20:00:00 +0100'
categories:
- Linqpad
- Geocaching
---
This post covers a combination of two the things I love, [Linqpad](http://linqpad.net) and [Geocaching](www.geocaching.com). 

If you're not familiar with Geocaching, but have any love for the outdoors, then I heartily recommend you try it. It's pretty much treasure hunting for grown-ups and using grown-up toys. It's also great for the family, I never go without my son.

If you're not familiar with Linqpad, go get acquainted, I use it for so many different roles, in this case, scripting C#.

As I am only an amateur Geocacher, my GPS device of choice is my Windows Phone (currently a Lumia 920 &ndash; which I also love) and [GPS Tuner's Outdoor Navigation](http://www.windowsphone.com/en-gb/store/app/outdoor-navigation/83f78cdd-fb29-e011-854c-00237de2db9e). Outdoor Navigation is ace, it has many features making a great companion when out and about. However, it does not have full integration with Geocaching.com, so you have to use OneDrive to synchronise a "loc" file downloaded from Geocaching.com.

This brings us to the problem, each loc file is one Point of Interest in Outdoor Navigation, meaning that if I plan to stock up on (say five) caches before heading out I need to download five files, copy five files to OneDrive, fire up Outdoor Navigation and import each file, one after another from list. Downloading the files is easy enough, my browser only requires one click. Uploading to OneDrive is equally easy, just multi-select and copy. But the import into Outdoor Navigation is not multi-select or fluid when working through the a long list. The import process was starting to get tedious after a while so I decided to dig into the loc files to see if there was a way to speed things up.

Here's a loc file for just one Cache (from today's outing):

{% highlight xml %}
<?xml version="1.0" encoding="UTF-8"?>
<loc version="1.0" src="Groundspeak">
  <waypoint>
    <name id="GC37092">
      <![CDATA[A Longer Dog Walk #1 by The Briar Rose]]>
    </name>
    <coord lat="53.602717" lon="-1.79085"/>
    <type>Geocache</type>
    <link text="Cache Details">http://www.geocaching.com/seek/cache_details.aspx?wp=GC37092</link>
    <difficulty>1.5</difficulty>
    <terrain>1</terrain>
    <container>2</container>
  </waypoint>
</loc>
{% endhighlight %}

It's an XML document with a `loc` root element and a `waypoint` for the Point of Interest. After a bit of experimentation I found I could put any number of `waypoint` elements into the document and that Outdoor Navigation would only have to import one file that contained any number of Points of Interest. Bingo!

Now I had a way to import just one file if, but to do that I needed to combine all the individual loc files from Geocaching.com. The next issue was how to combine them, enter Linqpad, as always.

Using a bit of Linq-Xml I was able to load each file, grab the "waypoint" element(s) and then combine them into a new XML document that I could save to disk and even auto upload to OneDrive &ndash; providing I used the OneDrive Application for Windows.

**First. Load all the loc files I have downloaded.**
{% highlight c# %}
var locationElements =
  Directory
  .EnumerateFiles(folderPath, "*.loc")
  .SelectMany(path => new LocFile(path).GetElements());
{% endhighlight %} 
 
There's a bit going on here. We start by grabbing any file with the "loc" extension in the folder stored in the `folderPath` variable &ndash; `Downloads\GC` in my case &ndash; Creating a new instance of the `LocFile` class calling `GetElements()` and combining all the results together. I'm using `SelectMany` instead of `Select` because I am assuming there could be more than one "waypoint" element in a loc file. What we are left with is an `IEnumerable<XElement>` containing all the "waypoint" elements from all the files.

**Second. Creating the new XDocument:**
{% highlight c# %}
var combinedLocFiles =
  new XDocument(
  new XElement("loc",
    new XAttribute("version", "1.0"),
    new XAttribute("src", "Groundspeak"),
    locationElements))
  .Dump();
{% endhighlight %} 
  
Here we are creating a new `XDocument` with a root element of "loc" with the attributes "version" and "src" with the values of "1.0" and "Groundspeak", respectively (the first, second and last lines in the above XML). And then filling the root element with the contents of the `locationElements` &ndash; the "waypoint" elements from the First snippet.

**Finally. The LocFile class.**
{% highlight c# %}
class LocFile
{
  readonly String _filePath;
  public LocFile(String filePath)
  {
    _filePath = filePath;
  }

  public ReadOnlyCollection<XElement> GetElements()
  {
    return
      XDocument
      .Load(_filePath)
      .Root
      .Elements()
      .ToList()
      .AsReadOnly();
  }
}
{% endhighlight %} 

This is the class that represents a loc file and knows how to get the relevant Elements from it.

These three snippets are the meat of the script, everything else is just fluff to get the correct paths and save the output and copy it to OneDrive.

It's pretty easy to use, just fire up Linqpad, load the Script and then run it. Before I start I ensure that there are only the loc files I want to combine in my `folderPath`, but other than that, you're away.

If you need to change the paths, that's at the top of the script and is pretty straight forward too.

**Download**
Here's the [link to download](http://sdrv.ms/Z4gYcB) the "linq" file from my OneDrive.
