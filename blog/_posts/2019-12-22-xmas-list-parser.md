---
layout: post
status: publish
published: true
title: Xmas List Parser
date: '2019-12-22 09:30:00 +0000'
date_gmt: '2019-12-22 09:30:00 +0000'
categories:
- FSharp
---

> This post is part of the [F# Advent Calendar 2019][1]. Many thanks to Sergey Tihon for organizing these.

[Last year][2] I wrote an [app][3] for Santa to keep track of his list of presents to buy for the nice children
of the world.

Sadly, the development team didn't do proper research into Santa's requirements; they couldn't be bothered with
a trek to The North Pole and just sat at home watching "The Santa Claus" and then reckoned they knew it all.
Luckily no harm came to Christmas 2018.

Good news is, Santa's been in touch and the additional requirements for this year are:

1. *I don't want to retype all the bloomin' letters.*
1. *I'd like to send presents to naughty children*.

![Raymond Brigg's Father Christmas][4]

## The Problem

This year I'm going to walk through how you can solve Santa's problem using something I've recently
began playing with - [FParsec][5].

This is only my second go at using it, my first was to solve [Mike Hadlow's "Journeys" coding challenge][6].
So this might not be the most idiomatic way to solve write a parser.

 [1]: https://sergeytihon.com/2019/11/05/f-advent-calendar-in-english-2019/
 [2]: https://taeguk.co.uk/blog/santas-xmas-list-in-fable/
 [3]: https://xmaslist.s3-eu-west-1.amazonaws.com/index.html
 [4]: {{site.contenturl}}xmas-2019-father-xmas.png
 [5]: https://www.quanttec.com/fparsec/
 [6]: https://twitter.com/xdaDaveShaw/status/1189683003074760716