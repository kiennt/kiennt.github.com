+++
author = "kiennt"
date = "2012-06-27T00:00:00Z"
title = "Add new startup items on Mac OSX"
url = "/blog/2012/06/27/add-new-startup-items-on-mac-osx.html"
image = "images/post/startup.jpg"
draft = false
tags = ["server", "booting", "macosx"]
comments = true
share = true
+++

In DEBIAN, when we want to add new start up item, we create new script file in
/etc/init.d and using update-rc.d to add it.
But in Mac OSX, there is not /etc/init.d and update-rc.d anymore.

<!--more-->

### Booting in Mac OSX
When the computer is powered up, the firmware is complete control.
After the firmware initializes the hardware, it hands off control the BootX loader.
BootX locate in **/System/Library/CoreSerives**. It draws the Apple logo on the screen and proceeds to setup the kernel environment.
BootX first looks for kernel extension (drivers, also known as kexts) that are cached in the **mkext cache**. If the cache does not exits, BootX loads only those extensions in **/System/Library/Extensions** that have *OSBundleRequired* key in their Info.plist file.
Each extension live in folder (*ExtensionName.kext*) and the Info.plist file is an XML document that resides in its Contents subfolder.

After the required drivers are loaded, BootX hands off control to the kernel (/mach_kernel).

The kernel first initializes all the data structures needed to support Mach and BSD. Next, it initializes the I/O Kit, which connects the kernel with the set of extensions that correspond to the machine's hardware configuration. Then, the kernel finds and mounts the root filesystem. The kernel next loads mach_init, which starts Mach message handling. mach_init then launches the BSD init process. In keeping with Unix conventions, init is process ID (PID) 1, even though it was started second. mach_init is given PID 2, and its parent PID is set to 1 (init's PID).

The init process launches the /etc/rc.boot and /etc/rc shell scripts to start the system. Both rc scripts (and all startup items) source the /etc/rc.common script, which sets the initial environment, defines some useful functions, and loads the /etc/hostconfig file. /etc/hostconfig controls which system services need to be started and defines such things as the AppleTalk hostname. Example 2-2 is an excerpt from the hostconfig file.

SystemStarter examines **/System/Library/StartupItems** and **/Library/StartupItems** for applications that should be started at boot time. **/Library/StartupItems** contains items for locally installed applications; you can also put your own custom startup items there. **/System/Library/StartupItems** contains items for the system. You should not modify these or add your own items here.

## Add new startup script on `/System/Library/StartupItems`
To add new script on startup, for example, we want to start my virtual machine VirtualBox at startup.

Firstly, in need to create new folder name VirtualBox in **/System/Library/StartupItems**, and in this folder we create 2 files: **StartupParameters.plist** and **VirtualBox** (same name with folder name).

```bash
$> sudo mkdir -p /System/Library/StartupItems/VirtualBox
$> sudo touch /System/Library/StartupItems/VirtualBox/VirtualBox
$> sudo chmod +x /System/Library/StartupItems/VirtualBox/VirtualBox
$> sudo touch /System/Library/StartupItems/VirtualBox/StartupParameters.plist

# modify contents of StartuParameters.plist
# `Description` is description about this program
# `Provides`  This is an array of services that the item provides (
#             for example, Apache provides Web#   Server).
#             These services should be globally unique.
#             In the event that SystemStarter finds two items that
#             provide the same service, it will start the first one it finds.
# `Requires`  This is an array of services that the item depends on.
#             It should correspond to another item's Provides attribute.
#             If a required service cannot be started, the system won't start the item.
# `Uses`      This is similar to Requires, but it is a weaker association.
#             If SystemStarter can find a matching service, it will start it.
#             If it can't, the dependent item will still start.
# `OrderPreference` The Requires and Uses attributes imply a particular
#             order, in that dependent items will be started after the
#             services they depend on. You can specify First, Early, None
#             (the default), Late, or Last here. SystemStarter will do its
#             best to satisfy this preference, but dependency orders prevail.
$> sudo vim /System/Library/StartupItems/VirtualBox/StartupParameters.plist
{
    Description     = "VirtualBox Support and USB Drivers";
    Provides        = ("VirtualBox");
    OrderPreference = "None";
}

# modify contents of VirtualBox
$> sudo vim /System/Library/StartupItems/VirtualBox/VirtualBox
#!/usr/bin/env sh
. /etc/rc.common

StartService()
{
    # your function in here
}

StopService()
{
    # your function in here
}

RestartService()
{
    # your function in here
}
RunService "$1"
```
