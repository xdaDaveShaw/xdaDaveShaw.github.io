---
layout: post
status: publish
published: true
title: Hosting TFS Hands on Labs in Windows Azure
author:
  display_name: Dave Shaw
  login: DaveShaw
  email: dave@taeguk.co.uk
  url: http://taeguk.co.uk
author_login: DaveShaw
author_email: dave@taeguk.co.uk
author_url: http://taeguk.co.uk
wordpress_id: 422
wordpress_url: http://taeguk.co.uk/?p=422
date: '2013-08-30 00:40:54 +0100'
date_gmt: '2013-08-29 23:40:54 +0100'
categories:
- TFS
- Windows Azure
tags: []
comments:
- id: 22
  author: Hosting TFS 2013 VM on Windows Azure | Mark&#039;s Matrix
  author_email: ''
  author_url: http://marks-matrix-blog.azurewebsites.net/?p=81
  date: '2014-03-08 10:03:17 +0000'
  date_gmt: '2014-03-08 10:03:17 +0000'
  content: "[&#8230;] http:&#47;&#47;taeguk.co.uk&#47;blog&#47;hosting-tfs-hands-on-labs-in-windows-azure&#47;
    [&#8230;]"
- id: 52
  author: Getting Started with Release Management for Visual Studio - Please Release
    Me
  author_email: ''
  author_url: http://pleasereleaseme.net/getting-started-release-management-visual-studio/
  date: '2014-12-30 18:24:50 +0000'
  date_gmt: '2014-12-30 18:24:50 +0000'
  content: "[&#8230;] running under Hyper-V or alternatively run it as an Azure VM.
    If you choose the latter option then this post could help you, although bear in
    mind that it was written in mid-2013 and some aspects of [&#8230;]"
---
<p>In today&rsquo;s post I&rsquo;m going to go through the process for setting up the TFS Hands on Labs (HOLs) in Windows Azure.<&#47;p>
<p>The TFS Hands on Labs are great resources for learning the latest features in TFS. The latest TFS 2013 labs can be found <a href="http:&#47;&#47;blogs.msdn.com&#47;b&#47;briankel&#47;archive&#47;2013&#47;08&#47;02&#47;visual-studio-2013-application-lifecycle-management-virtual-machine-and-hands-on-labs-demo-scripts.aspx">here<&#47;a> on Brian Keller&rsquo;s blog. <&#47;p>
<p>I choose to use Windows Azure so that I can share the labs with my colleagues. I have an MSDN Subscription through my employment that gives me $150 (&pound;130) of Azure credit a month, so I don&rsquo;t have to worry too much about paying for all this.<&#47;p><br />
<h3><strong>Overview<&#47;strong><&#47;h3>
<p>My initial attempts to upload the VHD into Azure fell flat when I downloaded the 13GB RAR archive, unpacked it to a whopping 55GB VHD and then tried to upload to Windows Azure. My poor 2MB cable internet just wouldn&rsquo;t cut it and the estimate was at least a week to upload, as well as that I was been severely throttled by my ISP.<&#47;p>
<p>So I came up with a cunning workaround to save my bandwidth:<&#47;p>
<ul>
<li>Setup a &ldquo;Downloaded&rdquo; VM on Windows Azure.
<li>Download, unpack and re-upload the VHD on the &ldquo;Downloader&rdquo; VM in Windows Azure.
<li>Create a VM for the Hands on Lab and mount the VHD.<&#47;li><&#47;ul>
<p><strong>Prerequisites<&#47;strong><&#47;p>
<p>To follow this guide you will need a Windows Azure account and a basic understanding of Consoles (Command Prompt &#47; PowerShell) and know a little bit about setting up Windows Servers.<&#47;p><br />
<h3>1. Creating a &ldquo;Downloader&rdquo; VM<&#47;h3>
<p>The first thing you need to do is create a &ldquo;Downloader&rdquo; Virtual Machine on Windows Azure to perform the download, unpack and re-upload process. Once you have completed this process and you have your Labs up and running you can delete this &ldquo;Downloader&rdquo; VM to save your money.<&#47;p>
<ul>
<li>Login to your <a href="https:&#47;&#47;manage.windowsazure.com&#47;">Windows Azure Portal<&#47;a>.
<li>Select Virtual Machines and Click &ldquo;+ New&rdquo;.<&#47;li><&#47;ul>
<p><a href="http:&#47;&#47;taeguk.co.uk&#47;wp-content&#47;uploads&#47;2013&#47;08&#47;TFSHOL1.png"><img title="TFSHOL1" style="border-left-width: 0px; border-right-width: 0px; background-image: none; border-bottom-width: 0px; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-top-width: 0px" border="0" alt="TFSHOL1" src="http:&#47;&#47;taeguk.co.uk&#47;wp-content&#47;uploads&#47;2013&#47;08&#47;TFSHOL1_thumb.png" width="134" height="244"><&#47;a><&#47;p>
<ul>
<li>&ldquo;Quick Create&rdquo; a new Medium spec. VM. Select a data centre in the region <a href="https:&#47;&#47;maps.google.com&#47;maps&#47;ms?msid=214511169319669615866.0004d04e018a4727767b8&amp;msa=0&amp;ll=-3.513421,-145.195312&amp;spn=147.890481,316.054688">closest to you<&#47;a>.<&#47;li><&#47;ul>
<p><a href="http:&#47;&#47;taeguk.co.uk&#47;wp-content&#47;uploads&#47;2013&#47;08&#47;TFSHOL2.png"><img title="TFSHOL2" style="border-left-width: 0px; border-right-width: 0px; background-image: none; border-bottom-width: 0px; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-top-width: 0px" border="0" alt="TFSHOL2" src="http:&#47;&#47;taeguk.co.uk&#47;wp-content&#47;uploads&#47;2013&#47;08&#47;TFSHOL2_thumb.png" width="244" height="105"><&#47;a><&#47;p>
<ul>
<li>Windows Azure will have a think for a couple of minutes and your new VM should appear.
<li>When the status turns to &ldquo;Running&rdquo;, select it from your VM list and click the &ldquo;>< Connect&rdquo; button at the bottom of the screen.
<li>This will download a remote desktop profile for your VM and you can login using the username and password you supplied.<&#47;li><&#47;ul><br />
<h3>2. Downloading, unpacking and re-uploading the VHD<&#47;h3>
<p>These next steps will be performed on the new VM over remote desktop.<&#47;p>
<ul>
<li>The first thing you need to do is download and install the <a href="http:&#47;&#47;www.freedownloadmanager.org&#47;">Free Download Manager<&#47;a> (FDM) tool.
<li>I found it easier to download this on my local PC and then browse to it through the mapped remote desktop drives on the VM and copy it up. Internet Explorer on servers is annoyingly secured.
<li>Once you have FDM installed, run it and import the list of URLs from Brian&rsquo;s <a href="http:&#47;&#47;blogs.msdn.com&#47;b&#47;briankel&#47;archive&#47;2013&#47;08&#47;02&#47;visual-studio-2013-application-lifecycle-management-virtual-machine-and-hands-on-labs-demo-scripts.aspx">blog post<&#47;a>.
<li>This will take sometime to download, so now&rsquo;s a good time to get a cup of tea.
<li>Once the download is completed. Run the &ldquo;VisualStudio2013.Preview.part01.exe&rdquo; file on the server and click through the options to start the extraction. I did this on a Small VM and it took even longer than the download (that&rsquo;s why I am suggesting a Medium VM).
<li>Whilst it is unpacking now is a good time to get the &ldquo;Downloader&rdquo; VM and Windows Azure setup ready to upload the VHD.<&#47;li><&#47;ul><br />
<h3>2.1 Preparing to Upload a VHD to Azure.<&#47;h3>
<ul>
<li>First, grab a copy of <a href="http:&#47;&#47;www.microsoft.com&#47;web&#47;downloads&#47;platform.aspx">Web Platform Installer<&#47;a> and install it on the Server. Again, you may want to download it locally and copy it up to bypass Internet Explorer.
<li>Open Web Platform Installer and install &ldquo;Windows Azure PowerShell&rdquo; along with any dependencies.
<li>Open up PowerShell and run the following commands: <&#47;li><&#47;ul>
<pre class="brush: ps;">Set-ExecutionPolicy RemoteSigned<br />
Import-Module "C:\Program Files (x86)\Microsoft SDKs\Windows Azure\PowerShell\Azure\Azure.psd1"<br />
<&#47;pre></p>
<ul>
<li>This will setup PowerShell with all the Azure CmdLets.
<li>Get a copy of your Publish Settings file from Azure using this PowerShell command. This opens up a browser window to download a file (again I did this locally and uploaded it). <&#47;li><&#47;ul>
<pre class="brush: ps;">Get-AzurePublishSettingsFile<&#47;pre></p>
<ul>
<li>Now you have your Publish Settings file you need to import them and select your subscription using the following PowerShell commands:<&#47;li><&#47;ul>
<pre class="brush: ps;">Import-AzurePublishSettingsFile 'C:\SubscriptionName-8-27-2013-credentials.publishsettings'<br />
Set-AzureSubscription 'SubscriptionName'<&#47;pre></p>
<ul>
<li>Replace <strong>SubscriptionName<&#47;strong> with the name of your subscription.
<li>Finally, verify the settings with the following command. You should see your subscription details listed.<&#47;li><&#47;ul>
<pre class="brush: ps;">Get-AzureSubscription<br />
<&#47;pre></p>
<ul>
<h3><&#47;h3><&#47;ul></p>
<h3>2.2 Creating your Storage<&#47;h3></p>
<p>Now that you have PowerShell ready, you need somewhere to upload the VHD to on Azure.<&#47;p></p>
<ul>
<li>Head back to the <a href="https:&#47;&#47;manage.windowsazure.com&#47;">Windows Azure Portal<&#47;a>.
<li>On the left hand side, select Storage and click &ldquo;+ New&rdquo;.<&#47;li><&#47;ul>
<p><a href="http:&#47;&#47;taeguk.co.uk&#47;wp-content&#47;uploads&#47;2013&#47;08&#47;TFSHOL3.png"><img title="TFSHOL3" style="border-left-width: 0px; border-right-width: 0px; background-image: none; border-bottom-width: 0px; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-top-width: 0px" border="0" alt="TFSHOL3" src="http:&#47;&#47;taeguk.co.uk&#47;wp-content&#47;uploads&#47;2013&#47;08&#47;TFSHOL3_thumb.png" width="120" height="244"><&#47;a><&#47;p></p>
<ul>
<li>Click &ldquo;Quick Create&rdquo;. Give it a name and select the same region as the Downloader VM.
<li>Once Azure has created the Storage, you need a Container.
<li>Select the storage you have just created, and navigate to the &ldquo;Containers&rdquo; tab and click &ldquo;Add&rdquo; at the bottom.<&#47;li><&#47;ul>
<p><a href="http:&#47;&#47;taeguk.co.uk&#47;wp-content&#47;uploads&#47;2013&#47;08&#47;TFSHOL4.png"><img title="TFSHOL4" style="border-left-width: 0px; border-right-width: 0px; background-image: none; border-bottom-width: 0px; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-top-width: 0px" border="0" alt="TFSHOL4" src="http:&#47;&#47;taeguk.co.uk&#47;wp-content&#47;uploads&#47;2013&#47;08&#47;TFSHOL4_thumb.png" width="244" height="87"><&#47;a><&#47;p></p>
<ul>
<li>Give the Container a name and leave the access as &ldquo;Private&rdquo;.
<li>You now should have everything setup to upload the VHD<br />
<h3><&#47;h3><&#47;li><&#47;ul></p>
<h3>2.3 Uploading the VHD<&#47;h3></p>
<ul>
<li>Back on the Downloader VM, wait for the installer to complete, this may take some time.
<li>Now that the installation is complete you can start the upload process.
<li>To upload the VHD you need 2 pieces of information, the source and destination.
<li>The source will be something like:
<ul>
<li><font face="Consolas"><strong>C:\Downloads<&#47;strong>\Visual Studio 2013 Preview\WMIv2\Virtual Hard Disks\TD02WS12SFx64.vhd<&#47;font> &ndash; where <strong>C:\Downloads<&#47;strong> is where you let FDM download the files to. <&#47;li><&#47;ul>
<li>The destination you can get from the Azure Portal and will be something like:
<ul>
<li><font face="Consolas">http:&#47;&#47;<strong>storagename<&#47;strong>.blob.core.windows.net&#47;<strong>containername<&#47;strong>&#47;TD02WS12SFx64.vhd<&#47;font>&nbsp; &ndash; where <strong>storagename <&#47;strong>and <strong>containername<&#47;strong> are the names of your storage and container.<&#47;li><&#47;ul>
<li>In PowerShell on the Downloader VM run the following PowerShell command:<&#47;li><&#47;ul>
<pre class="brush: ps;">Add-AzureVhd<br />
<&#47;pre></p>
<ul>
<li>And supply the Destination and LocalFilePath (Source) when prompted.
<li>This upload will take a few hours, so keep and eye on the progress &ndash; I left mine overnight.
<li>When this is complete, you can create your Hands on Lab VM.<&#47;li><&#47;ul><br />
<h3>3. Creating the Disk and Hands on Lab VM<&#47;h3></p>
<p>Now you should have everything you need to create your Hands on Lab VM.<&#47;p></p>
<ul>
<li>Head back to the <a href="https:&#47;&#47;manage.windowsazure.com&#47;">Windows Azure Portal<&#47;a> again.
<li>Go to &ldquo;Virtual Machines&rdquo; and select the &ldquo;Disks&rdquo; tab at the top.
<li>Click &ldquo;Create&rdquo; and give your Disk a name and browse to the VHD in your storage container.<&#47;li><&#47;ul>
<p><a href="http:&#47;&#47;taeguk.co.uk&#47;wp-content&#47;uploads&#47;2013&#47;08&#47;TFSHOL5.png"><img title="TFSHOL5" style="border-left-width: 0px; border-right-width: 0px; background-image: none; border-bottom-width: 0px; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-top-width: 0px" border="0" alt="TFSHOL5" src="http:&#47;&#47;taeguk.co.uk&#47;wp-content&#47;uploads&#47;2013&#47;08&#47;TFSHOL5_thumb.png" width="244" height="195"><&#47;a><&#47;p></p>
<ul>
<li>Once your Disk is created go back and create another Virtual Machine.
<li>This time, don&rsquo;t use &ldquo;Quick Create&rdquo;, instead select &ldquo;From Gallery&rdquo;<&#47;li><&#47;ul>
<p><a href="http:&#47;&#47;taeguk.co.uk&#47;wp-content&#47;uploads&#47;2013&#47;08&#47;TFSHOL6.png"><img title="TFSHOL6" style="border-left-width: 0px; border-right-width: 0px; background-image: none; border-bottom-width: 0px; padding-top: 0px; padding-left: 0px; display: inline; padding-right: 0px; border-top-width: 0px" border="0" alt="TFSHOL6" src="http:&#47;&#47;taeguk.co.uk&#47;wp-content&#47;uploads&#47;2013&#47;08&#47;TFSHOL6_thumb.png" width="244" height="52"><&#47;a><&#47;p></p>
<ul>
<li>When you use &ldquo;From Gallery&rdquo; you will see an option on the left that says &ldquo;My Disks&rdquo;.
<li>Select you Disk that you just created and click &ldquo;Next&rdquo;.
<li>Fill in the rest of the options for creating a Large VM (a medium also might work).
<li>Keep filling in the form until the end. Your VM will be created and start provisioning.
<li>When this VM is and the status is &ldquo;Running&rdquo;, you are good to go.
<li>Click on the &ldquo;>< Connect&rdquo; button for the new VM and you should be able to login as &ldquo;Administrator&rdquo;. The password is in the &ldquo;Working with the Visual Studio 2013 ALM Virtual Machine&rdquo; document that comes with the VM.<&#47;li><&#47;ul><br />
<h3>Final Steps<&#47;h3></p>
<p>It is recommended that you secure the VM from the outside world &ndash; this Windows Azure VM is on the internet. So change the Administrator password and disable RDP access for any of the user accounts that don&rsquo;t need it.<&#47;p></p>
<h3>Conclusion<&#47;h3></p>
<p>Setting up this VM was fun and a great excuse to learn the Windows Azure platform. Remember you can delete the Downloaded VM and any associated artefacts (except the TFS HOL HVD) when you have done with it.<&#47;p></p>
<p>If you have any questions or comments, please <a href="http:&#47;&#47;taeguk.co.uk&#47;contact-me&#47;">contact me<&#47;a> and I&rsquo;ll do my best.<&#47;p></p>
<h3>Associated Links &#47; Credits<&#47;h3></p>
<p>Here are a few links I used to pull all this together, if you&rsquo;re stuck you might find something useful there.<&#47;p></p>
<ul>
<li><a href="http:&#47;&#47;blogs.msdn.com&#47;b&#47;briankel&#47;archive&#47;2013&#47;08&#47;02&#47;visual-studio-2013-application-lifecycle-management-virtual-machine-and-hands-on-labs-demo-scripts.aspx?PageIndex=1#comments">Brian Keller&rsquo;s Blog Comments<&#47;a>.
<li><a href="http:&#47;&#47;www.windowsazure.com&#47;en-us&#47;manage&#47;windows&#47;common-tasks&#47;upload-a-vhd&#47;">Windows Azure: Creating and Uploading a Virtual Hard Disk that Contains the Windows Server Operating System<&#47;a>
<li><a href="http:&#47;&#47;msdn.microsoft.com&#47;en-us&#47;library&#47;windowsazure&#47;jj554332.aspx">Windows Azure: Get Started with Windows Azure Cmdlets<&#47;a> (PowerShell)<&#47;li><&#47;ul><br />
