---
layout: post
status: draft
published: false
title: SnowPi in fsharp
date: '2020-12-11 08:00:00 +0000'
date_gmt: '2020-12-11 08:00:00 +0000'
categories:
- FSharp
- Xmas
---

> This post is part of the [F# Advent Calendar 2020][1]. Many thanks to Sergey Tihon for organizing these.
> Go checkout the other many and excellent posts.

## SnowPi RGB

Back in *July* I got an email from KickStarter about a project for RGB Snowman for Raspberry Pi and
BBC micro:bit, I instantly backed it, knowing of my daughters love of her micro:bit and all things Christmas.

![SnowPi RGB][2]

*image from the KickStarter campaign*

A few months later (and now in Winter) it has arrived, and my daughter has had
her fun programming it for the micro:bit, now it is my turn using the Raspberry Pi.

Unfortunately, most of my Raspberry Pi programming has previously been with cobbled
together python scripts with little attention for detail or correctness.

This is my journey to getting it working with F# 5 / .NET 5 and running on a Raspberry Pi.

 [1]: https://sergeytihon.com/2020/10/22/f-advent-calendar-in-english-2020/
 [2]: {{site.contenturl}}snowpi-rgb.png

----

Notes:

Publishing

dotnet publish -o publish --self-contained -r linux-arm

Copying
scp -rp publish/ pi@raspberrypi:/home/pi/snowpi

on Pi

cd ~/snowpi/

./install

cd publish/
./snowpi


First Run, Seg Fault!
95350a3b0b7ac46c8271491fa86f0780f644932f

Then:
WS2811_ERROR_HW_NOT_SUPPORTED

Fixing by install and building the native lib on the pi...

cloned https://github.com/jgarff/rpi_ws281x
scons (from as per above)
copied rpi_ws281x.i and rpi_ws281x_wrap.c from https://github.com/klemmchr/rpi_ws281x.Net/tree/master/src/ws281x.Net/Native
gcc -c -fpic ws2811.c rpi_ws281x_wrap.c (as per .NET)
gcc -shared ws2811.o rpi_ws281x_wrap.o -o librpi_ws281x.so
sudo ldconfig

Running...
./snowpi: symbol lookup error: /usr/local/lib/librpi_ws281x.so: undefined symbol: rpi_hw_detect

Better...
https://github.com/kenssamson/rpi-ws281x-csharp/tree/master/src/rpi_ws281x
Using this lib and the latest build of native libs from https://github.com/jgarff/rpi_ws281x
But these instructions
$ sudo apt-get install build-essential git scons
$ git clone https://github.com/jgarff/rpi_ws281x.git
$ cd rpi_ws281x
$ scons
$ gcc -shared -o ws2811.so *.o
$ sudo cp ws2811.so /usr/lib

Also copied to /usr/local/lib/ NOT sure if this helped though ;)