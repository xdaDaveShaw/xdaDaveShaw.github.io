---
layout: post
status: publish
published: true
title: Setting up my Ubiquiti Network
date: '2019-08-09 22:10:00 +0000'
date_gmt: '2019-08-08 23:10:00 +0100'
categories:
- Networking
---

For a while now, I've been having problems with my Virgin Media Super Hub 3 and the Wifi randomly dropping out.
At first I attributed it to bad devices (old 2Ghz stuff), and wasn't that bothered as I mostly used a wired connection
on my Desktop PC. However, since moving house I'm unable to use a wired connection - my PC and the Fibre are in
opposite corners of the house - and even with a brand new Wifi Card, I've been experiencing the same problems.
Another issue was that I could only get 150Mbps over Wifi - when I'm paying for 200Mbps.

I could have gone to Virgin Media support and requested a replacement, it would probably have
been some hassle, but I'm sure they would have sorted it eventually.

But, I still wanted something a bit better than what their standard Router/Wifi could
offer, so it was time for an overhaul.

After seeing some blogs on people implementing Ubiquiti products in their house, I thought I'd give it
a go.

![unifi bits][1]

*I didn't buy all that, but it's pretty looking stuff*

I'll be the first to admit that I'm never the best at buying things online, and I'm no networking expert.
So I ended up buying what I *thought* was enough bits - and technically it was - without proper research.

What initially I bought was:

- AC-PRO (Wifi)
- USG (Router)
- Cloud Key (a way to manage everything)

The first problem I came across was that I didn't have enough Ethernet cables in my house (thrown away
during the move). So I borrowed a couple from the office, and liberated one from another device in the house.

With just 4 Ethernet cables I just about managed to get everything setup, but it wasn't pretty.

Initially I setup the USG, and then added the AC-PRO. To do this I had to setup the Controller Software on
my Desktop, then I got around to setting up the Cloud Key, and then realised that it worked as the Controller
instead of what is on my Desktop, so had to start all over again.

I really struggled to get everything on the same LAN and keep internet connected - at times I had to remove the
Ethernet cable providing Internet so I could connect a Computer to the LAN to setup the Wifi, then with
the Wifi setup I could disconnect the Ethernet cable to reconnect the Internet.

## Lesson 1

Have enough Ethernet Cables before you start!

## Lesson 2

Check how everything will connect together - I foolishly thought that the USG had built-in Wifi and the AC-PRO
was a booster.

The little research I did online said you could use just the three devices without a switch,
but I don't see how people managed.

In the end I used the 3 spare ports on the VM Superhub (whilst in modem mode) as a switch for the AC-PRO, USG and Cloud Key.

## Lesson 3

Setup the Cloud Key before anything else.
Don't download the Controller and start Adopting all the devices to then realise you can do it all on the
Cloud Key.

## The Problems

I was happy everything worked. I could get 200Mbps + speeds over Wifi again - something I wasn't able to
do with the SuperHub:

**Before**

![before speed][2]

**After**

![after speed][3]

The problem I had now was that the AC-PRO was in a corner with everything else meaning I wasn't getting the best
range, ideally I wanted it the middle of my house. Moving it would require a power and Ethernet cable
running the 10M+ to it, as well the the Power Adaptor, which would be ugly and not pass the Spouse Approval Test.

I also had an abundance of things plugged in in that corner, so I needed a way to move it and make it pretty.

## Solution

I decided to fork out a little more money and get a Ubiquiti switch with PoE (power over ethernet) coming
out from it so that I could power the AC-PRO (and Cloud Key) without a power cable.

As those are the only 2 requirements for PoE I got a:

- US-8-60W

to add into the mix.

That provides 4 PoE ports, and is capable of powering a Cloud Key and AC-PRO.

Now I have my AC-PRO connected via a Flat White CAT7 cable, and not looking ugly at all.

![AC-PRO][4]

*I love how you cannot see the wire above the doorway unless you really look*.

The rest of the devices are wired up with Flat Black CAT7 cables (except the Tivo).

![The Gear][5]

## End Result

I'm really happy with the performance of everything, and the setup was really easy - except for my own failings
above.
Adding the switch in was just plug-in, go to the web interface and press "Adopt".

The devices I have connected at the moment are:

```plain
VM Router (modem)
          |
          |--------------------USG
                                |
                                |
                                |
                            □□□▣ □□□□
                          US-8-60W (switch)
                                |  
                                |
        ------------------------|--------------------
        |           |           |           |       |
      PS4         Tivo       Pi Hole    Cloud Key   |
    ▣□□□ □□□□   □▣□□ □□□□   □□□□ □□▣□   □□□□ □□□▣   |
                                                    |
                                                    |
                                                  AC-PRO  (wifi)
                                                □□□□ □▣□□
```

The Management via the Cloud Key / Controller is awesome.
There are so many settings and it is so easy to control everything.
I've not had a proper play yet, but so far my favourite feature is been able to assign Alias's
to devices so I know what everything is - most phones just show up as MAC addresses on the Superhub.
Simple things like that always make me happy.

## Final thoughts

I started writing this post a few months ago, but due to the stresses of moving house, it's taken me 6 months
to complete. But now I've had some time running with the above setup I can say that it is rock solid. I've had
no problems, and no complaints from the family either - you know you got it right if they don't complain.

Changes since I started:

- I've added a [pi-hole][6] to my network to block ads on mobile devices. This is something I wouldn't have been
able to do on the VM router, as I could not assign DNS to the DHCP clients, and manually changing it 
per device would not have been acceptable.
- I've installed the [Unifi Network][7] app on my phone to help manage it when I'm away.
- I've turned off the blue glow on the AC-PRO - it's pretty, but it did make the house glow all night.

Other than that, I've just been applying the odd updates and keeping an eye on things.

If anyone is thinking about getting setup with this, feel free to reach out to discuss, I can share
what little I know and maybe save you from my mistakes :)

 [1]: {{site.contenturl}}unifi-bits.png
 [2]: {{site.contenturl}}unifi-speedtest-before.png
 [3]: {{site.contenturl}}unifi-speedtest-after.png
 [4]: {{site.contenturl}}unifi-ac.png
 [5]: {{site.contenturl}}unifi-gear.png
 [6]: https://pi-hole.net/
 [7]: https://play.google.com/store/apps/details?id=com.ubnt.easyunifi
