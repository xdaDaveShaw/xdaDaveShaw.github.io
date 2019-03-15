---
layout: post
status: publish
published: true
title: Setting up my Ubiquiti Network
date: '2019-01-12 23:10:00 +0000'
date_gmt: '2019-01-12 23:10:00 +0000'
categories:
- Networking
---

I've been having problems for a while with the Virgin Media Super Hub 3 Wifi randomly dropping out.
At first it was attributed to bad devices (old and 2Ghz), but since moving house I've had to put
my Desktop PC on Wifi, as it is at the opposite corner of the house to where the Fibre comes in. I bought a decent Gigabyte PCI Wifi Card, and I had the same problems, so it was time to do something
about it. I was also onlyable to get 150Mbps over Wifi - when I'm paying for 200Mbps.

I could have simply gone to Virgin Media support and requested a replacement, it would probably have
been some hassle, and I still wanted something a bit better than what their standard Router/Wifi could
offer.

After seeing some blogs on people implementing Ubiquiti Products in their house, I thought I'd give it
a go.

![unifi bits][1]

*I didn't buy all that, but it's pretty looking stuff*

I'll be the first to admit that I'm never the best at buying things online, and I'm no networking expert.
So I ended up buying what I thought was enough bits - and technically it was - without proper research.

What initially I bought was:

- AC-PRO (Wifi)
- USG (Router)
- Cloud Key (a way to manage everything)

The first problem I came across was that I didn't have enought Ethernet cables in my house (thrown away
during the move). So I borrowed a couple, and liberated one from another device in the house.

With just 4 Ethernet cables I just about managed to get everything setup, but it wasn't pretty.

Initially I setup the USG, and then added the AC-PRO. To do this I had to use the Controller Software on
my Desktop, then I got around to setting up the Cloud Key, and reaslised that it worked as the Controller
instead of what is on my Desktop, so had to start again.

I really struggled to get everything on the same LAN and internet connected - at times I had to remove the
Ethernet cable providing Internet so I could connect a Computer to the LAN to setup the Wifi, then with
the Wifi setup I could disconnect the Ethernet cable to reconnect the Internet.

## Lesson 1

Have enough Ethernet Cables before you start!

## Lesson 2

Check how everything will connect together - I foolishly was mislead that the USG had Wifi.

The little reasearch I did online said you could the three devices I bought without a switch,
but I don't see how.

In the end I used the 3 spare ports on the Superhub as a switch for the AC-PRO, USG and Cloud Key.

## Lesson 3

Setup the Cloud Key before anything else.
Don't download the Controller and Adopt all the devices to then realise you can do it all on the
Cloud Key.

## The Problems

I was happy everything worked. I could get 200Mbps + speeds over wifi again - something I wasn't able to
do with the SuperHub:

**Before**

![before speed][2]

**After**

![after speed][3]

The problem I had was that the AC-PRO was in a corner with everything else meaning I wasn't getting the best
range, ideally I wanted it the middle of my house. Moving it would require a power and Ethernet cable
running to it, as well the the Adaptor, which would be ugly and not pass the Spouse Approval Test.

I also had an abudance of things plugged in in that corner, so I needed a way to move it and make it pretty.

## Solution

I decided to fork out a little more money and get a Ubiquiti switch with PoE (power over ethernet) coming
out from it so that I could power the AC-PRO (and Cloud Key) without a power cable.

As those are the only 2 requirements for PoE I got a:

- US-8-60W

to add into the mix.

That provides 4 PoE ports, and is capable of powering a Cloud Key and AC-PRO.

Now I have my AC-PRO connected via a Flat White CAT7 cable, and not looking ugly at all.
The rest of the devices are wired up with Flat Black CAT7 cables to match the surface they are sitting on:

<font color="red">PICTURE

HERE</font>

## End Result

I'm really happy with the performance of everything, and the setup was really easy - except for my own failing
listed above.
Adding the switch in was just plug-in, goto the web interface and press "Adopt".

It's a fairly simple layout at the moment:

```plain
VM Router (modem)
          |
          |--------------------USG
                                |
                                |
                                |
                            ▣□□□ □□□□
                          US-8-60W (switch)
                                |  
                                |
                    ------------|------------
                    |           |           |
                Cloud Key      Tivo         |
                □□□□ □□▣□   □▣□□ □□□□      |
                                            |
                                            |
                                          AC-PRO  (wifi)
                                        □□□□ □□□▣
```

But I have some plans in store for spicing things up in the future...

The Management via the Cloud Key / Controller is awesome.
There are so many settings and it is so easy to control everything.
I've not had a proper play yet, but so far my favourite feature is been able to assign Alias's
to devices so I know what eveything is - most phones just show up as MAC addresses on the Superhub.
Simple things like that always make me happy.

If anyone is thinking about getting setup with this, feel free to reach out to discuss, I can share
what little I know and maybe save you from a mistake :)

 [1]: {{site.contenturl}}unifi-bits.png
 [2]: {{site.contenturl}}unifi-speedtest-before.png
 [3]: {{site.contenturl}}unifi-speedtest-after.png