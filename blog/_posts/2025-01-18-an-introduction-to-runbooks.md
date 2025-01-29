---
layout: post
status: publish
published: true
title: An Introduction to Runbooks
date: '2025-01-18 20:27:00 +0000'
date_gmt: '2025-01-18 20:27:00 +0000'
categories:
- DevOps
---

> It has been a long time since I've written anything just due to how busy I've
> been. I have a few articles planned, and hopefully can get back to writing
> at a regular cadence.

I'm going to take a look at runbooks, I'll be covering:

- What is a Runbook?
- When should you create them?
- How do you organise them?
- What should be in them?

----

## Story

I've been working for the last two years on transitioning a service from running
somewhere deep inside a data centre, where it was managed by an Ops Team and 
updates were scheduled through a Release Management team, to running in AWS where
the development team deploy, manage, monitor and update it.

During this time I've been looking into a lot of things in the DevOps and Site
Reliability Engineering (SRE) space to ensure that the service I am responsible
is up and running at all times.

Whilst on a call someone mentioned mentioned "executing a runbook" to resolve a
problem. I had previously only heard of runbooks in the context of 
[Microsoft System Centre][system-centre] and was amazed that teams were using 
similar approaches on an AWS native service without any Microsoft stuff.
Hoping to bring some of these into my service, I reached out for more information,
expecting some code or configuration for AWS, but instead I was told none of them
were automated, these were just documented processes that people followed.

<figure>
  <img src="{{ site.contenturl }}runbook.png" alt="Three ring binder"/>
  <figcaption>
    Image by <a href="https://www.flickr.com/photos/jkfid/">jkfid</a> from 
    <a href="https://www.flickr.com/photos/jkfid/4333767484">flickr</a> -
    Attribution (CC BY 2.0)
  </figcaption>
</figure>

## Understanding the value

I was a little crest fallen, "anyone can write a manual process, it wasn't hard",
I thought.

But, I'd not done it! 

I had no processes documented for such situations!

I started to look at the problems I might have with my service and
what steps I might take to resolve them. There were a few things I knew,
but had never written down. 
"How would someone else deal with it if I was on holiday?",
"Would I remember what to do in 12 months time?". These were all things I should put
into a runbook.

Now, I needed somewhere to store them. We use Atlassian Confluence, but any shared
team documentation would suffice: OneNote, ADO or GitHub Wikis, Google Docs, 
any place your team keeps their documentation and can easily collaborate. 

I setup a "parent" page for "Runbooks" with a quick intro and a table of contents,
and then created my first runbook.

Just because it is a manual process doesn't mean there's no automation. It may
be as simple as updating a line in a JSON configuration file in your repository and
performing a standard deployment. The point is, to have a process documented telling
you when and how you do it, and that it is clear.

## When to create one

I only create runbooks for processes that relate to production systems and things
I don't do every day.

**Good candidates**: Servers dying, certificates rotating, overnight jobs failing, etc.

**Poor candidates**: How to setup a development laptop, how to perform a release -
these **are** documented, but they don't meet the bar for creating a runbook - 
put them in another section.

If you don't set the bar high, you have processes for anything and everything, and
managing them becomes onerous. Keeping them focused means you have a small selection
of procedures that cover the most important processes.

## Structure

My runbooks have a simple structure. There is a Trigger and a Process, but I also have
some metadata such as who owns it, when was it last updated, etc.

Sometimes I will maintain a log of when it was last run, for example, certificate
rotation has a log of when it was rotated, and when it will next expire.

### Triggers

Triggers explain when to invoke a runbook. For example, it could be as simple as
"If a server dies". Or something a bit more involved "If X job fails, check the 
logs for A event, then follow process 1, otherwise follow process 2". I will nest
runbooks so top level ones cover a scenario and child runbooks cover 
different solutions to the same overall problem.

e.g.

- Process X failed - Trigger: process X has not completed
  - Process X.1 failed - Trigger: check the logs and see if X.1 completed
  - Process X.2 failed - Trigger: check the logs and see if X.2 completed

### Process

The process is a list of steps you need to follow. I've not needed to use flowcharts
yet, just using bulleted lists is enough. I ensure each step is clear
and has examples of things you expect to find.

e.g.

To resolve the issue with the Server follow these steps:

1. Locate the server IP
   1. Start, Run, cmd.exe
   1. Type `ipconfig` and press Enter
   1. Look for `IPv4 Address. . . . . . . . . . . : 192.168.0.1` 
      1. If there is more than one `IPv4 Address` you want the one starting `192.168.0.`
1. Enter the server IP from step `#3` into the box labelled "Server IP"
1. Etc.

## Types of runbooks

There are two main types of runbook I have created:

- Business as Usual (BAU)
- There's a problem

### BAU 

BAU runbooks cover any maintenance tasks that need to be performed on a semi-regular
basis, for example, the creating a new SSH Key, adding a new admin user, etc.

The trigger for a BAU runbook is usually some business process or event. These 
things are expected to happen and the runbook is just a record of the steps needed.

I label the BAU runbooks with `[BAU]` in the title so I can tell which is which.

### Problem

Problem runbooks are to be invoked when something goes wrong and it requires
manual intervention to remediate. For example, a release goes live and errors 
increase, or an overnight process doesn't run.

The trigger should be some alert from your monitoring solution. The process is
a list of steps to identify what has gone wrong and what needs to be done to 
remedy the problem.

## Examples

Above I've mentioned the structure of the pages and the structure of a runbook.
I can't replicate my runbooks, but I'll show some hypothetical examples.

### Example pages

- Production Runbooks
  - Runbook - Server Dies
  - Runbook - Job X Fails
    - Runbook - X.1 Failed
    - Runbook - X.2 Failed
  - Runbook - [BAU] Rotate SSH keys
- Architecture Documents
- Project Documents

----

*An example of the structure of a team's documentation site*

### Example runbook

| **Name** | Server Dies |
| **Description** | Process to follow when a server dies |
| **Date** | 15-Jan-2025 |
| **Version** | 2 |
| **Owner** | Dave |

**Trigger**

This runbook is to be executed when a email alert is received informing you a
server has died, or if you notice a server isn't responding.

> NOTE: if this is because of maintenance, you don't need to do anything as the
> engineer will restart it when they are done.

**Process**

1. Check the email alert for the name of the server (it will be after the heading
**Server:** - e.g. **Server**: sv01)
1. Run the "Restart Server Tool"
1. Enter the name of the server from step `#1` into the box labelled "Server to restart"
1. Press the "Restart" button. 
1. Read the logs looking for "Server xx online" (where xx is the server name).
  1. If this doesn't appear in 10 minutes, raise an incident (link here).

**References**

- Documentation for "Restart Server Tool"
- Process for Raising an Incident

----

*An example, to show what I might have in a runbook.*

## Best practices

Here are my best practices for runbooks.

### Review them regularly

On a Friday afternoon, or that boring meeting you can't get out of, have a browse
through and make sure they still make sense. When you write things you often do it from
a position of understanding, and only in time do you realise you have missed a vital
instruction. "Reboot the server" may be a valid instruction, but if you are SSH'd
into a Linux server, do you know the exact command to trigger an immediate reboot?

### Test them

If you have not actually performed the steps you cannot be sure your runbook is 
going to help you when you need it. If possible, test your process by following
the steps, or better yet, have someone else follow it whilst you observe.

However, sometimes you cannot test them if they require outside coordination.
In these cases it is still better to have them than not (see "Prepare for the Worst").

### Prepare for the worst

I have a number of runbooks I have never run, for events that I hope never happen.
These are for scenarios that are rare but would be a big problem if they triggered.
By writing down the most likely steps needed to resolve the problem, I give myself
a head start.

### Remember to create them

If you are doing a manual process for something with production and you realise 
"this is a bit complicated, I bet won't remember this", then it is an opportunity
to create a runbook.

### Golden rules

Runbooks should be:

- All in one place - don't have them all over the place, they should be easy to find.
- All for the same purpose - runbooks are for production related processes - they 
don't explain how you setup a new laptop.
- Focused - Each runbook should be one trigger that explains if this need running,
and a process that explains what to do. Create nested runbooks if needed.

## The power of runbooks

By giving these processes a name, defining a scope, keeping them simple and putting
them all together you have a powerful suite of processes for dealing with production
issues.

## Road to automation

Above, I said I was "crest fallen" when I found out these were manual processes, and not
some amazing feat of automation, so why am I espousing the values of manual runbooks
and not trying to just automated them all?

Simple. [Perfect is the enemy of good][perfect].

If I waited until I could automate every process, I wouldn't have any runbooks yet.

You have to balance the time it would take to automate these things with how much
value it would provide. Some processes are very complex to engineer, and happen
very rarely.
Some would require you to build a whole new solution to perform a task that takes
10 minutes once a quarter.
It isn't always suitable to fully automate these processes. 

By creating a manual runbook first, you can understand the process and measure
the time spent performing it, and then make a business decision if automation is 
the right approach.

## Conclusion

The lack of automation was a surprise at first, but once I got over myself, I
realise how beneficial manual runbooks can be. It's relatively simple to set them
up using the tools you already have, and then if something goes wrong, you are 
prepared.

These sort of things may be common in Ops led services, but where the development
team owns and operates them, this level of maturity is definitely still needed.
[DevOps][devops] must include the benefits of Development and Operations.

 [system-centre]: https://learn.microsoft.com/en-us/system-center/orchestrator/design-and-build-runbooks?view=sc-orch-2025
 [perfect]: https://en.wikipedia.org/wiki/Perfect_is_the_enemy_of_good
 [devops]: https://www.donovanbrown.com/post/what-is-devops
