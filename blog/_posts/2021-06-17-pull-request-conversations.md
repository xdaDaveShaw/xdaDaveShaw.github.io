---
layout: post
status: publish
published: true
title: Pull Request Conversations
date: '2021-03-04 21:35:00 +0000'
date_gmt: '2021-03-04 21:35:00 +0000'
categories:
- Development
---

Pull Requests are a common approach to code reviews when using Git source code management.
A developer creates a branch of a repository and then requests that their branch is merged
into the [Mainline][ml] branch, or some other [collaboration branch][cb].

From the linked articles, you can see there are many patterns to branching, and that it often
preferable to minimise friction getting code merged. However, the reality for a lot of
developers, especially those in larger organisations is to have a formal code review process
often based on a pull request using a source control system such as [Azure DevOps][ado] or 
[GitHub][gh].

In this article, I want to share a few observations to a successful pull request, whether you
are a junior having their code reviewed by an experienced developer, or a seasoned developer
going through the motions.

I have participated in thousands of code reviews in my day job, and these are based on my
experience in a large organisation working on a large code base (now over 1,000 C# projects
and many thousands of SQL objects), but there should be no reason why these don't apply to 
open-source contributions.

## (First) Be Nice

Whether you are the reviewer or reviewee, there is no reason not to be nice.

![Dalton: 'I want you to be nice until it's time to not be nice.' Dave: 'There's no reason not to be nice though.'][rh]

As a reviewer, assume people are trying their best, they usually are. What seems like a
simple mistake to you, might not be obvious to someone else. Try to put yourself in their
shoes. Are you been harsh to someone new to the company, team, or technology? How would
you feel reading your own comments back, both now, and yourself a few years ago?

As a reviewee, remember the reviewer isn't omniscient, reading a delta of code can be
hard and keeping everything in their head isn't easy. They will make mistakes too. Be
patient, sometimes you will be asked seemingly daft questions, if it isn't obvious to them,
would it be obvious to someone else. Remember code is [read a lot more often than it is
written][rc].

## Reviewees

Here are some observations for reviewees to consider:

### Setting up a good review

Commit messages are an important part of a pull request, as well as been important for
a maintainable code base. Many time I've seen a fix (often to WinForms code) which doesn't
make obvious sense. For example, why does a one line fix in one class fix an issue in
some other area of the code? There is probably a reason you understand, but only you.

For example, if the commit message says:

> Fixed #123. Stop crash in C by setting X = 3

and your code change is:

```patch
A.cs
---
- X = 2;
+ X = 3;
```

all I can discern is that indeed your change does set X to 3:

My first question given only that information and a moderate understanding of a system is:

> D: How does this fix "C"? X is usually used to control "B".

At this point a reply will often explain:

> R: Since C was added, B needs to have an X of 3 to operate correctly. B can work
> just fine with 2 or 3 as per _reasons_.

At this point, I click "Looks Good". But this has wasted both your time and and the
reviewers. This has gone form one interaction (review and looks good) to three (review and
question, reply, review reply and looks good).

A decent commit message would have saved everyone's time.

As a reviewer, I often link people to Chris Beams' post on [commit messages][cm] for some
good examples.

When creating a pull request on GitHub and Azure Dev Ops (and I'm sure other SCM products)
you are able to provide a description of what your change is. If you have a number of commits
to deliver a piece of work, you can summarise the changes or provide an overview of the solution
in addition to the commit messages.

### Have a conversation

Following on from "Be nice", a code review should be a conversation. Imagine you are talking to
the other person and having a conversation about the code. A good conversation requires both
participants to listen to each other, both what is said and what is not said.

As an example, here's the original change, just a call to `UpdateAddress` on the person's address.

```patch
A.cs
---
UpdatePerson(data.Person);
+ UpdateAddress(data.Person.Address);
```

A valid question might be:

> D: Do you need to check `Person` is not null here? `data` allows person to be null in some cases.

At this point the PR is updated with another commit:


```patch
A.cs
---
UpdatePerson(data.Person);
+ if (data.Person != null)
+     UpdateAddress(data.Person.Address);
```

And a reply of:

> R: Code changed

This seems valid, but it does not answer the question.

As a reviewer I have 2 new questions:

> D:
> 1. Was this a bug in the original implementation, is there a gap in the testing?
> 2. If this wasn't a bug, why did you change the code?

A better reply instead of "Code changed" would have been either:

> R: Yes, good spot, I didn't realise `Person` could be null here. I've updated the
> code and added a test cases for this.

or

> R: No, there's a precondition that prevents this method being called with a null
> person.



### Evidence

### Don't just "code changed"

### Looks good means looks good, not is good

## Reviewer

### Code Suggestions

 [ml]: https://www.martinfowler.com/articles/branching-patterns.html#mainline
 [cb]: https://www.martinfowler.com/articles/branching-patterns.html#collaboration-branch
 [ado]: https://dev.azure.com
 [gh]: https://github.com
 [rc]: https://devblogs.microsoft.com/oldnewthing/20070406-00/?p=27343
 [cm]: https://chris.beams.io/posts/git-commit/
 [rh]: {{site.contenturl}}pr-dalton.png