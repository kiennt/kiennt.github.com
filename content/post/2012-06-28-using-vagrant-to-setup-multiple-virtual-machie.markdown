+++
author = "kiennt"
date = "2012-06-28T00:00:00Z"
title = "Using vagrant to setup multiple virtual machine"
url = "/blog/2012/06/28/using-vagrant-to-setup-multiple-virtual-machie.html"
image = "images/post/server.jpg"
draft = false
tags = ["server", "vagrant", "virtual machine"]
comments = true
share = true
+++

This is another post about using Vagrant to set up development environment
in your local machine.
Please consider to read previous post about setup [vagrant](/blog/2012/06/18/install-virtual-machine-with-vagrant.html) for one VM.

<!--more-->

My config to setup 2 virtual machine in a project
```ruby
Vagrant::Config.run do |config|
  SERVER_PATH = "/Volumes/DATA/WORK/SKUNKWORKS/SERVER"
  DEVELOPMENT_PATH = "/Volumes/DATA/DEVELOPMENT"

  config.vm.define :web do |web_config|
    web_config.vm.box = "debian"
    web_config.vm.share_folder "SERVER", "/SERVER", SERVER_PATH
    web_config.vm.share_folder "DATA", "/DEVELOPMENT", DEVELOPMENT_PATH
    web_config.vm.forward_port 22, 2222
    web_config.vm.forward_port 80, 4567
    web_config.vm.network :hostonly, "192.168.0.100"
    web_config.vm.customize ["modifyvm", :id, "--memory", 512]
  end

  config.vm.define :sentry do |sentry_config|
    sentry_config.vm.box = "debian"
    sentry_config.vm.share_folder "SERVER", "/SERVER", SERVER_PATH
    sentry_config.vm.share_folder "DATA", "/DEVELOPMENT", DEVELOPMENT_PATH
    sentry_config.vm.forward_port 22, 2223
    sentry_config.vm.network :hostonly, "192.168.0.101"
    sentry_config.vm.customize ["modifyvm", :id, "--memory", 512]
  end
end
```

This setup will create 2 Virtual Machine, one is "web" have ipaddress "192.168.0.100" and
another is "sentry" with ipaddress is "192.168.0.101".

But now, if you using `vagrant up`, this will start import `debian` box to create  two fresh new Virtual Machines. This is really problems if you already setup some virtual machines, and just want to associate that machine with `vagrant`.

To do this, look at your `.vagrant` file in same folder of `Vagrantfile`. The format of file is
```bash
{"active":{"default":"machine uuid"}}
```

Change it to format
```bash
{"active":{"web":"<uuid1>", "sentry":"<uuid2>"}}
```

To get uuid of virtual machine, using `VBoxManage` command
```bash
$> VBoxManage list vms
# using VBoxManage, you also can control virtual machine
$> VBoxManage controlvm <vm_uuid> start|poweroff|reset
# for more useful command, try to test VBoxManage
# try and failed is best way to learn :-)
```
