---
layout: post
status: publish
published: true
title: XMAS Pi Fun
date: '2017-12-23 16:37:00 +0000'
date_gmt: '2017-12-23 16:37:00 +0000'
categories:
- Development
- Raspberry Pi
---

I've had a few days off over XMAS, so I decided to have a play with my Raspberry Pi and the
[3D XMAS Tree][1] from [ThePiHut.com][2].

With my (very) basic Python skills I managed to come up with a way of using a [Status Board][3]
on one Pi to control the four different light settings on the XMAS Tree, running on another Pi (the "tree-berry").

<iframe width="560" height="315" src="https://www.youtube.com/embed/l4qUhXMrNwo" frameborder="0" gesture="media" allow="encrypted-media" allowfullscreen></iframe>

*(sorry about the camera work, I just shot it on my phone on the floor)*

All the source for this is on [my GitHub][4], if you  want to see it.

## How it works ##

The "tree-berry" Pi has a Python SocketServer running on it, receiving commands from the client, another
Python program running on the other Pi.

The server is very rudimentary. Each light setting was initially written as a separate python script with
different characteristics on how it runs: some have `while True:` loops, others just set the lights and
`pause`. To save me from figuring out in how to "teardown" each setting and start a new one, I decided to fork
a new process from the server, and then kill it before changing to the next setting. This makes it slow to change, but ensures I clean up before starting another program.

The 2 consoles can be seen side by side here:

![Console Outputs][5]

There's a lot I need to learn about Python, but this is only for a few weeks a year ;).

 [1]:https://thepihut.com/products/3d-xmas-tree-for-raspberry-pi
 [2]:https://thepihut.com
 [3]:https://thepihut.com/products/status-board-pro
 [4]:https://github.com/xdaDaveShaw/rasp-projects/tree/master/tree-berry
 [5]:{{ site.contenturl }}xmas-consoles.png