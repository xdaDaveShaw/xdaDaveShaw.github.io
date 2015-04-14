---
layout: post
status: publish
published: true
title: Combining Loc Files from Groundspeak Geocaching.com
author:
  display_name: Dave Shaw
  login: DaveShaw
  email: dave@taeguk.co.uk
  url: http://taeguk.co.uk
author_login: DaveShaw
author_email: dave@taeguk.co.uk
author_url: http://taeguk.co.uk
wordpress_id: 102
wordpress_url: http://taeguk.azurewebsites.net/?p=102
date: '2013-04-01 20:00:00 +0100'
date_gmt: '2013-04-01 20:00:00 +0100'
categories:
- Linqpad
- Geocaching
tags: []
comments: []
---
<p><strong>Updated 03-Jun-2013: <&#47;strong>Changed Dropbox to SkyDrive after Outdoor Navigation changed.<&#47;p>
<p>This post is going to cover a combination of two the things I love, <a href="http:&#47;&#47;www.linqpad.net&#47;" target="_blank">Linqpad<&#47;a> and <a href="http:&#47;&#47;www.geocaching.com&#47;" target="_blank">Geocaching<&#47;a>.<&#47;p>
<p>If you're not familiar with Geocaching, but have any love for the outdoors, then I heartily recommend you try it. It's pretty much treasure hunting for grown-ups and using grown-up toys. It's also great for the family, I never go without my son with me.<&#47;p>
<p>If you're not familiar with Linqpad, go get acquainted, I use it for so many different roles, in this case, scripting C#.<&#47;p>
<p>As I am only an amateur Geocacher, my GPS device of choice is my Windows Phone (currently a Lumia 920 &ndash; which I also love) and <a href="http:&#47;&#47;www.windowsphone.com&#47;en-gb&#47;store&#47;app&#47;outdoor-navigation&#47;83f78cdd-fb29-e011-854c-00237de2db9e" target="_blank">GPS Tuner's Outdoor Navigation<&#47;a>. Outdoor Navigation is ace, it has many features making a great companion when out and about. However, it does not have full integration with Geocaching.com, so you have to use SkyDrive to synchronise a "loc" file downloaded from Geocaching.com. <&#47;p>
<p>This brings us to the problem, each loc file is one Point of Interest in Outdoor Navigation, meaning that if I plan to stock up on (say five) caches before heading out I need to download five files, copy five files to SkyDrive, fire up Outdoor Navigation and import each file, one after another from list. Downloading the files is easy enough, my browser only requires one click. Uploading to SkyDrive is equally easy, just multi-select and copy. But the import into Outdoor Navigation is not multi-select or fluid to work through the a long list. The import process was starting to get tedious after a while so I decided to dig into the loc files to see if there was a way to speed things up.<&#47;p>
<p>Here's a loc file for just one Cache (from today's outing):<&#47;p>
<pre class="brush: xml;"><?xml version="1.0" encoding="UTF-8"?><br />
<loc version="1.0" src="Groundspeak"><br />
    <waypoint><br />
        <name id="GC37092"><br />
            <![CDATA[A Longer Dog Walk #1 by The Briar Rose]]><br />
        <&#47;name><br />
        <coord lat="53.602717" lon="-1.79085"&#47;><br />
        <type>Geocache<&#47;type></p>
<link text="Cache Details">http:&#47;&#47;www.geocaching.com&#47;seek&#47;cache_details.aspx?wp=GC37092<&#47;link><br />
        <difficulty>1.5<&#47;difficulty><br />
        <terrain>1<&#47;terrain><br />
        <container>2<&#47;container><br />
    <&#47;waypoint><br />
<&#47;loc><br />
<&#47;pre></p>
<p>It's an XML document with a "loc" root element and a "waypoint" for the Point of Interest. After a bit of experimentation I found I could put any number of "waypoint" elements into the document and that Outdoor Navigation would only have to import one file that contained any number of Points of Interest. Bingo!<&#47;p></p>
<p>Now I had a way to import just one file if, but to do that I needed to combine all the individual loc files from Geocaching.com. The next issue was how to combine them, enter Linqpad, as always.<&#47;p></p>
<p>Using a bit of Linq-Xml I was able to load each file, grab the "waypoint" element(s) and then combine them into a new XML document that I could save to disk and even auto upload to SkyDrive &ndash; providing I used the SkyDrive Application for Windows.<&#47;p></p>
<p><strong>First. Load all the loc files I have downloaded.<&#47;strong><&#47;p>
<pre class="brush: csharp;">var locationElements =<br />
  Directory<br />
  .EnumerateFiles(folderPath, "*.loc")<br />
  .SelectMany(path => new LocFile(path).GetElements());<br />
<&#47;pre></p>
<p>There's a bit going on here. We start by grabbing any file with the "loc" extension in the folder stored in the <font face="Consolas">folderPath<&#47;font><font face="Calibri"> variable &ndash; "Downloads\GC"&nbsp; in my case &ndash; Creating a new instance of the <font face="Consolas">LocFile<&#47;font> class calling <font face="Consolas">GetElements()<&#47;font> and combining all the results together. I'm using <font face="Consolas">SelectMany<&#47;font> instead of <font face="Consolas">Select<&#47;font> because I am assuming there could be more than one "waypoint" element in a loc file. What we are left with is an <font face="Consolas">IEnumerable<XElement><&#47;font> containing all the "waypoint" elements from all the files.<&#47;font><&#47;p></p>
<p><strong>Second. Creating the new XDocument:<&#47;strong><&#47;p>
<pre class="brush: csharp;">var combinedLocFiles =<br />
  new XDocument(<br />
    new XElement("loc",<br />
        new XAttribute("version", "1.0"),<br />
        new XAttribute("src", "Groundspeak"),<br />
        locationElements))<br />
  .Dump();<br />
<&#47;pre></p>
<p>Here we are creating a new <font face="Consolas">XDocument<&#47;font> with a root element of "loc" with the attributes "version" and "src" with the values of "1.0" and "Groundspeak", respectively (the first, second and last lines in the above XML). And then filling the root element with the contents of the <font face="Consolas">locationElements<&#47;font> &ndash; the "waypoint" elements from the First snippet.<&#47;p></p>
<p><strong>Finally. The LocFile class.<&#47;strong><&#47;p>
<pre class="brush: csharp;">class LocFile<br />
{<br />
    readonly String _filePath;<br />
    public LocFile(String filePath)<br />
    {<br />
        _filePath = filePath;<br />
    }</p>
<p>    public ReadOnlyCollection<XElement> GetElements()<br />
    {<br />
        return<br />
            XDocument<br />
            .Load(_filePath)<br />
            .Root<br />
            .Elements()<br />
            .ToList()<br />
            .AsReadOnly();<br />
    }<br />
}<br />
<&#47;pre></p>
<p>This is the class that represents a loc file and knows how to get the relevant Elements from it.<&#47;p></p>
<p>These three snippets are the meat of the script, everything else is just fluff to get the correct paths and save the output and copy it to SkyDrive.<&#47;p></p>
<p>It's pretty easy to use, just fire up Linqpad, load the Script and then run it. Before I start I ensure that there are only the loc files I want to combine in my "folderPath", but other than that, you're away. <&#47;p></p>
<p>If you need to change the paths, that's at the top of the script and is pretty straight forward too.<&#47;p></p>
<p><strong>Download<&#47;strong><&#47;p></p>
<p>Here's the <a href="http:&#47;&#47;sdrv.ms&#47;Z4gYcB" target="_blank">link to download<&#47;a> the "linq" file from my SkyDrive.<&#47;p></p>
