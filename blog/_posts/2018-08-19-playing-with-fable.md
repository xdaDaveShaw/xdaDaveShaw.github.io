---
layout: post
status: publish
published: true
title: Playing with Fable and the SAFE Stack
date: '2018-08-19 22:49:00 +0100'
date_gmt: '2018-08-19 22:49:00 +0100'
categories:
- FSharp
---

I've recently started looking at [Fable][1] as way to use F# to write Web Apps.

For the past 2 years I have had a *game* that I wrote in TypeScript as a playground
for learning more about the language. However, not been a JavaScript or a game developer
I think I had some fundamental problems with the app that I never managed to escape.

Over the past few months Fable has kept appearing on my twitter stream and looked
really interesting, especially as it can create React Web Apps, which is something I need
to know more about.

I began by using the [SAFE-Dojo][2] from CompositionalIT as a playground to learn
and found it did a real good job of introducing the different parts of the [SAFE-Stack][8].

Using it as a reference, I managed to re-write my *game* in Fable in very little time.

If you want to see it in action you can have a look [here][3]. It's quite basic and
doesn't push the boundaries in away, but it's inspired by my Daughter, and she loves to
help me add features.

![Monster Splatter][4]

### [Play it now][3] / [View Code][9]

## Why do I love SAFE?

There are a number of awesome features of this whole stack that I want to shout about:

### Less Bugs

With the old version, I found managing state really hard, there was a persistent bug where
the user could click "hit" twice on the same monster and get double points.

With Fable and [Elmish][5], you have a really great way of managing state. Yes, it is another model-view-*everything else* approach. But the idea of the immutable state
coming in and new state been returned is a great fit for functional programming.

You are also coding in F# which can model Domains really well meaning you are less likely
to have bugs.

### Less Code

I'm always surprised by how small each commit is. I might spend 30 minutes or more messing with
a feature, but when I come to commit it, it's only ever a few lines of code. Even replacing the
timer for the entire game was a small change.

### Fulma, or should I say Bulma

The SAFE Stack introduced me to [Fulma][6] which is a set of Fable helpers for using [Bulma][7].

At first I struggled to get to grips with Fulma, but once I realised how it just represented the
Bulma stylings, I found it much easier. Even someone as bad at UI as me, can create something
that doesn't look terrible.

I mostly kept the Bulma documentation open when styling the app as it had better examples and
I could translate them to Fulma in my head.

### It's React

React is quite a big thing at the moment, and something I'm looking to use at work. Having something
that is React, but isn't pure JS is great for me. It also supports Redux, so things like the
Chrome React and Redux developer tools work with it.

These are amazingly useful tools for debugging Web Apps, even ones this simple.

## Conclusion

I'm going to keep looking for situations where I can use the SAFE-Stack. Next will have to be
something more complicated - with multiple pages and a back-end with some persistence.

This will give me a feel if it could be something I could use everyday - I'd really like to
code this way all the time.

I'm already looking to push F# at work, and this would be a great compliment.

### [Play it now][3] / [View Code][9]

 [1]: http://fable.io
 [2]: https://github.com/CompositionalIT/SAFE-Dojo
 [3]: {{site.baseurl}}/MonsterSplatter
 [4]: {{site.contenturl}}monster-splatter.png
 [5]: https://elmish.github.io/
 [6]: https://mangelmaxime.github.io/Fulma/
 [7]: https://bulma.io/
 [8]: https://safe-stack.github.io/
 [9]: https://github.com/xdaDaveShaw/MonsterSplatter