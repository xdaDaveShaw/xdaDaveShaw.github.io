---
layout: post
status: publish
published: true
title: Adding Cloudapp DNS to Azure VM
date: '2015-11-15 20:26:00 +0000'
date_gmt: '2015-11-15 20:26:00 +0100'
categories:
- Azure
---

I've recently just deployed a new Azure Linux VM for hosting a [Discourse][1] instance I run and noticed that is didn't have a DNS entry on cloudapp.net. Last time I deployed one it was instantly given one in the format `server-name.cloudapp.net`, but this time it wasn't and I had to set it up by myself.

I suspect it is something new for [Resource Managed][12] deployments.	

Here's a list of the steps you need to follow if you ever need to do the same.

Assuming you have just deployed a VM and it doesn't have a DNS on cloudapp.net you will see something like this:

![newly deployed vm][2]

##Dissociate Public IP

First you need to Dissociate the Public IP so you can make changes.

Click the **Public IP Address** to open the settings:

![public ip settings][3]

Then click **Dissociate** and confirm when prompted.

![public ip settings dissociate][4]

> You cannot change any settings whilst the Public IP is in use.

##Configuring the DNS

From the Public IP page, click **All Settings** then **Configuration** to open up the settings:

![public ip settings configuration][5]

Then you can enter a new DNS prefix for *datacentre*.cloudapp.azure.net:

![public ip configuration new dns][6]

##Reassociate the Public IP

Now you need to reassociate the Public IP with the VM.

From the VM Screen (First Image) click **All Settings**, then **Network Interfaces**:

![vm network intefaces][7]

Click on the Interface listed:

![all vm network intefaces][8]

Click on **IP Addresses** from the **Settings** blade:

![network intefaces ip addresses][9]

Click on **Enable** then click on the **IP Address Configure Required...** and select the default (highlighted)
Public IP Address from the list.

![select public ip][10].

Then click **Save**.

#Validation and Testing

Now if you close and re-open the VM blade you should see a new Public IP address appear. 

Click on the **Public IP Address** to open the blade and you will see your full DNS Entry
and a **Copy to clipboard** button when you hover on it:

![vm with new dns][11]

To test, ping the VM and see if the DNS resolves:

    C:\> ping taeguk-test-dns.northeurope.cloudapp.azure.com

    Pinging taeguk-test-dns.northeurope.cloudapp.azure.com [40.127.129.7]

The requests will timeout because Azure has ICMP disabled, but so long as the DNS resolves, you've done it.

#Conclusion

This seems to be a change that I can't find a source for to do with Resource Managed VM's instead of Classic VM's. It used to work OK on classic VM's.

**Note**: I have deleted the VM in this post now. 

 [1]:https://discourse.org
 [2]:{{ site.contenturl }}azure-dns-new-vm.png
 [3]:{{ site.contenturl }}azure-dns-public-ip.png
 [4]:{{ site.contenturl }}azure-dns-public-ip-settings.png
 [5]:{{ site.contenturl }}azure-dns-public-ip-configuration.png
 [6]:{{ site.contenturl }}azure-dns-public-ip-configuration-new-dns.png
 [7]:{{ site.contenturl }}azure-dns-vm-network-interfaces.png
 [8]:{{ site.contenturl }}azure-dns-vm-network-interfaces2.png
 [9]:{{ site.contenturl }}azure-dns-nic-ip-addresses.png
 [10]:{{ site.contenturl }}azure-dns-enable-public-ip.png
 [11]:{{ site.contenturl }}azure-dns-new-dns.png
 [12]:https://azure.microsoft.com/en-gb/features/resource-manager/