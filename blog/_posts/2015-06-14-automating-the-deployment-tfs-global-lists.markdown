---
layout: post
status: publish
published: true
title: Automating the Deployment of TFS Global Lists
date: '2015-06-14 22:35:00 +0000'
date_gmt: '2015-06-14 22:35:00 +0000'
categories:
- TFS
---
The TFS Global List is a Team Project Collection wide entity and, to the best of my knowledge, requires someone to be a member of the [Collection Administrators](http://msdn.microsoft.com/en-us/library/dd547204.aspx) group to be able to update it – there is no explicit group or permission for "Upload Global List". This can be quite a problem if there are a number of Lists within your Global List that are updated frequently by the users of your Collection. 

Your current options are either:

 1. Ask the Collection Administrators for every little change (and complain if they take too long, they have a holiday, etc.) 
 2. Keep adding people/groups to the Collection Administrators group (and hand out way too much power to people who don’t need it).
 
We went for option #1, then option #2, until neither became sustainable.

The solution I came up with is based on post [Deploying Process Template Changes Using TFS 2010 Build by Ed Blankenship](http://www.edsquared.com/2010/06/18/Deploying+Process+Template+Changes+Using+TFS+2010+Build.aspx), but instead of deploying the whole process template, we just deploy the Global List. *(N.B. our TFSBuild account is a Collection Administrator)*.

# Building the Template

To build the template I started by copying the DefaultTemplate.11.1.xaml file that ships with TFS 2012 and stripped out all of the activities and process parameters that were no longer required then added a new activity to invoke the [witadmin](https://msdn.microsoft.com/en-us/library/dd236914.aspx?f=255&MSPPError=-2147217396) command line tool to import the Global List.

I won’t go into detail of the process of how I changed the activities because there were quite a lot of steps. It is quite straight forward. However, a quick overview is: remove anything to do with compiling code, running tests or gated checkins, then add a new activity to invoke the `witadmin` command line. It will probably be easier understood by looking at the finished template - available to download at the end. I may write a follow up post with the exact details.

# Using the template

 - To use the tempalte you need to have the Global Lists file checked into Version Control, you can follow the advice in the **Wrox Professional Team Foundation Server 2013** book to create a Team Project for your all your Process artefacts, or if you just want to keep it simple:
   - Use witadmin to export the global list file:
   - `witadmin exportgloballist /collection:http://tfs:8080/tfs/DefaultCollection /f:GlobalList.xml`
   - Check that file into its own folder somewhere in souce control, in this example we will use `$/TFS/GlobalList/GlobalList.xml` (having it in its own folder helps).
 - Once you have the template downloaded, you need to check it into Version Control, usually `$/MyTeamProject/BuildProcessTemplates/`.
 - Create a new build definition.
 - Fill in the **General** tab however you like.
 - In the **Trigger** tab select `Continous Integration`.
 - In the **Source Settings** tab select the folder with your GlobalList.xml as **Active** (`$/TFS/GlobalList/`)
 - In the **Build Defaults** tab, select "This build does not copy output files to a drop folder".
 - In the **Process** tab we need to do a few steps:
   - To install the template, click **Show Details**:
   - ![Show details]({{ site.contenturl }}GlobalList-NewTemplate1.png)
   - Click **New...** and browse to the template we checked in (`$/MyTeamProject/BuildProcessTemplates`).
   - Fill in the sections as follows:
   - ![Process Parameters]({{ site.contenturl }}GlobalList-NewTemplate2.png)
   - I didn't know the best way to get the URI of the Team Project collection, so I made it a argument you need enter.
   - If you are not using VS2012 on your build server, you will need to find a way to get witadmin.exe on there and then update the path to the location.
 
Once the above has been completed you should be able to the queue a new build using the new defintion and check the output to see if the global list has been successfully uploaded. Just open the build and check the summary, if everything went well you should see the following:

![Build Summary]({{ site.contenturl }}GlobalList-Summary.png)

If there were any problem, check the "View Log", the build is using Detailed logging which should include enough information to figure out what went wrong.

# Conclusion

I've now stopped worrying about having to update the global list for everyone who needs something new adding and I no longer am affraid of lots of people been Collection Administrators who really shouldn't have been. I can just grant check-in permissions to the folder that contains our global list and leave people to it.

# Download

I'm keeping this on my GitHub:

- [View Here](https://github.com/xdaDaveShaw/TFS/blob/master/GlobalListTemplate.11.1.xaml)

If have any improvements (to the post / template), feel free to send me a PR.  