---
layout: page
title: Shut The Box
---

##Currently Work In Progress
I'm in the process of compiling all the visual assets and then I plan to submit it to the Stores.

I'll update this page and publish a blog post when finished. This page is just up here so I have one 
less task to do later :).

----

Shut the Box is my first attempt at a Windows Store Application. It runs on both Windows 8.1 Store and Phone.

![Screenshot][3]

##Download
The game is **free** in both app stores, and has no adverts. I have no plans to monetise the application 
any more than the Donate links in the about page in the App.  

|||
|---|---|---|
|![Windows Store Download][2]||![Windows Phone Download][2]| 
|Download for Windows |&nbsp;&nbsp;&nbsp;&nbsp;| Download for Windows Phone|

The rules of the game are quite simple, roll the dice and shut any number of flaps that add up to the 
total on the dice, shut all the flaps, Win, run out of move, Lose. You can read more about the game on 
[Wikipedia][1]. At the moment I have only implemented the most basic of game types, but I hope to add 
additional styles of play.

##Why?
There are already a few versions of this in the store, but they are quite limited in what the offer in 
terms of game play. There's also the typical developer answer of "becase I can". 

I have a soft spot for this game and I also wanted to make something that is "mine" in the store, it seemed
like a good combination to enter the store with.

I've learnt a lot about XAML and Windows App development as this is quite a different application from what
I usually work on, so it was also a good challenge.

##How?
This started life before the UWP launched, so is a Windows 8 Universal App with a Shared Project. Most of 
the code is shared between both projects. I have no design skills what so ever, so the "metro" feel to the 
UI is both intentional and necessary.

It has Internet access only for Application Insights at the moment.

 [1]:https://en.wikipedia.org/wiki/Shut_the_Box
 [2]:store-icon.png
 [3]:screenshot.png