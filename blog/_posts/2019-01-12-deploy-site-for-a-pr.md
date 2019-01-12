---
layout: post
status: publish
published: true
title: Deploy a website for a Pull Request
date: '2019-01-12 23:10:00 +0000'
date_gmt: '2019-01-12 23:10:00 +0000'
categories:
- DevOps
---

Some of my colleagues shared a great idea the other day for one of our internal repositories...

> Spin up a new website for each PR so you can see what the finished site will look like.

I really like this idea, so I thought I'd change the [Fable Xmas List][1] to deploy a new version on
each PR I submitted. 

**Note:** I've only done this for my repository, not Forks.

## Previous Setup

The Xmas List code is built and deployed by Azure Pipelines from my Public Azure DevOps to a static website
in an AWS S3 Bucket.

The previous process was to only trigger a Build on pushes to `master` and if everything succeeded then a
release was triggered automatically to push the latest code into the Bucket.

The live site lives on:

[https://s3-eu-west-1.amazonaws.com/xmaslist/index.html][2]

## Plan

The plan is to deploy each Pull Request to another bucket with a naming convention of:

https://s3-eu-west-1.amazonaws.com/xmaslist**-pr-branch-name**/index.html

> I could have use subfolder in another bucket, but I thought I'd keep it simple here.

The Pipeline for pushes to `master` will remain unchanged.

## Implementing

To get this to work, you will need to change the Build and Release pipelines.

### Build

The first thing you will need to do is get the name of the Pull Request branch in the Release.
At the moment this is only available in the Build via the `SYSTEM_PULLREQUEST_SOURCEBRANCH` variable.

> I'll use the `UPPER_CASE` version of the variable names when working in PowerShell and the 
> `$(Title.Case`) version when working in the Task.

To pass the value of a variable from the Build to the Release you will have to add it into the Pipeline Artifact. 
As I only had a single value to pass, I just used a text file with the value of the variable in it.

I added a PowerShell Task and used an inline script:

![PowerShell Build Task][3]

The script is:

```powershell
$Env:SYSTEM_PULLREQUEST_SOURCEBRANCH > $(Build.Repository.LocalPath)\deploy\branch.txt
```

> `deploy` is the root of the published website

To stop a file been added to the live site deployments, I set the **Custom Conditions** on the task to:

![Build Custom Condition][4]

```
and(succeeded(), ne(variables['Build.SourceBranch'], 'refs/heads/master'))
```

It only writes the file if the source branch is not equal (`ne`) to `master`.

The Build will now publish the Pipeline artifact for Pull Requests with the name of the PR branch in a file
called `branch.txt`.

This is a little bit of a pain, but it is the only way I can find.

**Note:** There is a variable in the Release Pipeline called `Release.Artifacts.{alias}.SourceBranchName` but in a Pull Request
this is set to `merge`. That is because we build the PR branch of `refs/pull/5/merge`. There isn't a Pull Request source
branch name in Releases at this moment.

### Releases

To enable a release on a Pull Request you first need to alter the triggers...

#### Triggers

Click on the Continuous Deployment Trigger icon

![Release triggers][5]

and then Enable the Pull Request Trigger and set the source branch:

![Pull Request trigger][6]

To keep things simple I created a duplicate Stage of the live stage and called it **PR Deployment(s)** and changed it's pre-deployment conditions to run on Pull requests:

![Pre-deployment conditions][7]

#### Stages

With the duplicate stage setup, I needed to add some extra logic to change the bucket path on AWS. 

> Again, as I was keeping things simple, I just duplicated and changed the stage. I could have created Task Group and made the Tasks conditional, but this way is easier to know what each stage does.

To get the Branch name available to the Agent I needed to get the contents of the `branch.txt` file from the Pipeline 
Artifact that was created by the build. 

I added a PowerShell task with an Inline script with the following:


```powershell
$p = $Env:AGENT_RELEASEDIRECTORY + '\' + $Env:RELEASE_PRIMARYARTIFACTSOURCEALIAS + '\drop\branch.txt'
$PRBranch = Get-Content $p -Raw 
del "$p"

Write-Host $PRBranch #for debugging

Write-Host "##vso[task.setvariable variable=PRBranch;]$PRBranch"
```

This gets the path to `branch.txt` into a variable called `$p`, reads the entire contents into a variable called `$PRBranch`, and deletes `branch.txt` so it isn't published.

The line `Write-Host "##vso[task.setvariable variable=PRBranch;]$PRBranch"` will set a variable called `$(PRBranch)`
in the Build agent, so that I can access it in the AWS tasks later.

The final piece is to use this in the S3 tasks:

![S3 path with PR Branch Name][8]

**Note:** `$(BucketName)` is set to `xmaslist`.

The last thing I added was to write out the URL of the website at the end of the Process so I can just grab it from the
logs and try without having to remember the address.

## Summary

This is a really nice way to test out any changes on a version of your site before merging a pull request, even it is
only for your own PR's. This will be much more powerful if a team is working on the repository.

There will be many different ways to achieve this, especially if you are using Infrastructure as Code (e.g. ARM
Templates on Azure), but this works even on simple static sites.

[1]: {{site.url}}/blog/santas-xmas-list-in-fable
[2]: https://s3-eu-west-1.amazonaws.com/xmaslist/index.html
[3]: {{site.contenturl}}site-pr-buildtask.png
[4]: {{site.contenturl}}site-pr-condition.png
[5]: {{site.contenturl}}site-pr-release-trigger.png
[6]: {{site.contenturl}}site-pr-pr-trigger.png
[7]: {{site.contenturl}}site-pr-conditions.png
[8]: {{site.contenturl}}site-pr-s3-path.png