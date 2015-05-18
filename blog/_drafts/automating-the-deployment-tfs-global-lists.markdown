---
layout: post
status: draft
published: false
title: Automating the Deployment TFS Global Lists
date: '2015-05-18 20:25:00 +0000'
date_gmt: '2015-05-18 20:25:00 +0000'
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

To build the template I started by copying the DefaultTemplate.11.1.xaml file that ships with TFS 2012 and stripped out all of the activities and process parameters that were no longer required then added a new activity to invoke the witadmin command line tool to import the Global List.

I won’t go into detail on the process of removing activities because there were quite a few to remove. It is quite straight forward, just remove anything to do with compiling code, running tests or gated checkins. It will probably be easier understood by looking at the finished template.

# Removing Process Parameters

To remove the unnecessary process parameters appear when editing a build definition is not straight forward, so I thought it would be worth a mention.

There are two places where process parameters are defined. 

The first is in the Arguments.

Select the outer most part of the process and select the Arguments tab at the bottom:

PICTURE HERE

Removing from here will get rid of them from the Build Definition. I removed quite a few for this template: Test Specs, Solution Specific Build Outputs, Run Code Analysis, Source and Symbol Server Settings, Associate Changeset and Work Items, Anything with "MSBuild", Perform Test Impact Analysis, Disable Tests, Private Drop Location. What remained was enough for the activity to run and checkout some code.

The second place is the "Metadata", this is another argument, you can access the list from the ellipsis next to the argument with the name "Metadata".

Remove all the parameters from here because you don’t need them.

Metadata



# Removing Activities

You can see the final process template with all activities removed below (click for the fill size version bigger version):

PICTURE HERE



asda

asd

asd

# Adding the WITAdmin Import Activity

Once you have a stripped down build template it will end with "Initialize Workspace" as the final activity. The new sequence of activities will follow this one.







asd

# Setting up the Build
as
