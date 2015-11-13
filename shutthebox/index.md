---
layout: page
title: Shut The Box
---
Shut the Box is my first attempt at a Windows Application. It runs on both Windows 8.1/10 and Windows Phone 8.1.

![Screenshot][3]

##Download
The game is **free** in both app stores, and has no adverts. I have no plans to monetise the application 
any more than the Donate links in the about page in the App.  

|[Windows Store][4]|&nbsp;&nbsp;&nbsp;&nbsp;|[Windows Phone][5]|
|---|---|---|
|[![Windows Store Download][2]][4]||[![Windows Phone Download][2]][5]| 

##Rules

The rules of the game are quite simple, roll the dice and shut any number of flaps that add up to the 
total on the dice, shut all the flaps, Win, run out of move, Lose. You can read more about the game on 
[Wikipedia][1]. I have only implemented the most basic game type, but I have a lot of ideas on my backlog
to support other game types.

##Why?
There are already a few versions of this in the store, so why make another? Well, the ones in the Store(s) are OK, but they are quite limited in what the offer in terms of game play. 
I also have a soft spot for this game and I wanted to make a version of the
game that I could customise. There's also the typical developer answer of "becase I can".

I've learnt a lot about XAML and Windows App development as this is quite a different application from what
I usually work on, so it was also a good challenge.

##How?
This started life before the UWP launched, so is a Windows 8 Universal App with a Shared Project (UWP is planned later).
Most of the code is shared between both projects. I have no design skills what so ever, so the "metro" feel comes from 
all the UI been pure XAML, no images were used except for store/app icons - those were hard enough. I kind of like the simplicity.

It has Internet access only for [Application Insights][6] at the moment, I have no plans to change this for any new features.

 [1]:https://en.wikipedia.org/wiki/Shut_the_Box
 [2]:store-icon.png
 [3]:screenshot.png
 [4]:https://www.microsoft.com/en-us/windows/apps-and-games
 [5]:https://www.microsoft.com/en-gb/store/apps/windows-phone
 [6]:https://azure.microsoft.com/en-gb/services/application-insights/