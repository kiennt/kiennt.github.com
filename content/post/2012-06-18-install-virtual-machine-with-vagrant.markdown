+++
author = "kiennt"
date = "2012-06-18T00:00:00Z"
title = "Set up development environment with Vagrant"
url = "/blog/2012/06/18/install-virtual-machine-with-vagrant/"
image = "images/post/server.jpg"
draft = false
tags = ["server", "vagrant", "virtual machine"]
comments = true
share = true
+++

When you join a new company, to start to contribute to the code base, you will need
to set up a development environment on your local machine. Most of the time,
the team will give you the `bootstrap` script to do that. But sometimes, that
magical script does not exist, and that is the time you know you should introduce
the team your `bootstrap` script. In this article, I shared what I learned
while building a script by using Vagrant.

<!--more-->

### Vagrant
[Vagrant](http://vagrantup.com/) is a ruby-based tool to manage virtual machines.
Vagrant using [Virtual-box](https://www.virtualbox.org/) underlying.

This tool helps create many virtual machines easily. If you want to read more about vagrant, you should go to [vagrant home page](http://vagrantup.com).

To install vagrant in Mac OSX, firstly you need to install RUBY.
I recommend you should using `rvm` when using ruby.

To install `rvm`, you need `gcc` which already is installed when we install Xcode.
In this case, I use Xcode 4.3.3 from Apple Store.
But after getting Xcode, I did not find out `gcc`. To fixed it, open Xcode 4.3.3,
go to Preferences -> Downloads -> Choose install "Commandline tool for Xcode".
After it finishs, you got your magical GCC :-).

Next step is install `rvm`.

```bash
$> curl -L https://get.rvm.io | bash -s stable --ruby
$> source ~/.rvm/scripts/rvm
$> rvm install 1.9.3
$> gem install vagrant
```

Cool!!! Next we setup vagrant.

Vagrant use `boxes` to create VM. Boxes can download from http://vagrantbox.es.

```bash
$> vagrant box add debian-squeeze-32 http://mathie-vagrant-boxes.s3.amazonaws.com/debian_squeeze_32.box
```

Vagrant divides virtual machines to many projects. Each project can contain many machines. Each project is a store in a configuration file `Vagrantfile`:

```bash
$> mkdir debian
$> cd debian
$> vagrant init
```

A `Vagrantfile` has been placed in this directory. You are now
ready to `vagrant up` your first virtual environment! Please read
the comments in the Vagrantfile as well as documentation on
`vagrantup.com` for more information on using Vagrant.

Now change `Vagrantfile` to set up our new virtual machine.

```ruby
Vagrant::Config.run do |config|
  # using debian as virtual environment to build
  config.vm.box = 'debian'

  # Share an additional folder to the guest VM. The first argument is
  # an identifier, the second is the path on the guest to mount the
  # folder, and the third is the path on the host to the actual folder.
  config.vm.share_folder "srv", "/srv", "/Users/knt/srv"

  # Forward guest port 80 to host port 4567
  # forward_port is a method which takes two arguments:
  #   + guest port - The port on the virtual machine.
  #   + host port - The port on your local machine you want
  # to use to access the guest port.
  config.vm.forward_port 80, 4567

  # Config virtual machine memory
  config.vm.customize ["modifyvm", :id, "--memory", 512]
end
```

After modifying `Vagrantfile`, it is time to create our first virtual environment.
NOTE: More details about Vagrantfile configuration, please take a look at
[vagrant document](http://vagrantup.com/v1/docs/vagrantfile.html).

``` bash
$> vagrant up
[default] Importing base box 'debian'...
[default] The guest additions on this VM do not match the install version of
VirtualBox! This may cause things such as forwarded ports, shared
folders, and more to not work properly. If any of those things fail on
this machine, please update the guest additions and repackage the
box.

Guest Additions Version: 4.0.4
VirtualBox Version: 4.1.16
[default] Matching MAC address for NAT networking...
[default] Clearing any previously set forwarded ports...
[default] Forwarding ports...
[default] -- 22 => 2222 (adapter 1)
[default] -- 80 => 4567 (adapter 1)
[default] Creating shared folders metadata...
[default] Clearing any previously set network interfaces...
[default] Booting VM...
[default] Waiting for VM to boot. This can take a few minutes.
[default] VM booted and ready for use!
[default] Mounting shared folders...
[default] -- srv: /srv
[default] -- v-root: /vagrant
```

Finally, we have our `debian` machine. Let ssh to it

``` bash
$> vagrant ssh
Linux vagrant-debian-squeeze 2.6.32-5-686 #1 SMP Wed Jan 12 04:01:41 UTC 2011 i686

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Thu Feb 24 07:02:08 2011 from 10.0.2.2
vagrant@vagrant-debian-squeeze:~$
```

Cool !!!. Let 's config it to code

### Config virtual machine

#### Set up utility tools
Firstly, vagrant let us ssh to VM without a password. To make our own password on
VM, we change 'root' and 'vagrant' user password

```bash
$> sudo passwd # change root password
$> sudo passwd vagrant # chang vagrant password
```

Next, install my must have editor "vim".

```bash
$> sudo apt-get install vim
```

#### Change the hostname
Honestly, I do not like the name "vagrant-debian-squeeze".
It 's too long to remember. I just want to change it "debian"
"vagrant-debian-squeeze" is "hostname" of VM. To change it in debian,
we using bellow command:

``` bash
$> vim /etc/hostname
# Change to hostname to "debian"

$> vim /etc/hosts
# Add new line
127.0.0.1   debian
# we add this line to solve issue "unable to resolve hostname"

# Make it active in next login session
$> /etc/init.d/hostname.sh start
```

#### Add source.list

Change file /etc/apt/source.list as below
```bash
deb http://virror.hanoilug.org/debian/archive squeeze main contrib #non-free
deb http://virror.hanoilug.org/debian/archive squeeze-updates main #non-free contrib
deb http://virror.hanoilug.org/debian/security squeeze/updates main #non-free contrib
deb http://virror.hanoilug.org/debian/backports squeeze-backports main #non-free contrib

deb http://mirror.bytemark.co.uk/debian/ squeeze main
deb-src http://mirror.bytemark.co.uk/debian/ squeeze main

deb http://security.debian.org/ squeeze/updates main
deb-src http://security.debian.org/ squeeze/updates main

deb http://mirror.bytemark.co.uk/debian/ squeeze-updates main
deb-src http://mirror.bytemark.co.uk/debian/ squeeze-updates main


deb http://ftp.us.debian.org/debian testing main
```

Update source.list (NOTE: I logged  in as root to reduce typing :P).

``` bash
$> apt-get update
```

#### Install necessary tools


Install gcc and python.

```bash
$> apt-get install gcc
$> apt-get install python2.7 python-psutil python-psycopg2 python-pylibmc python-setproctitle

## install pip tool
$> apt-get install python-pip

## update pip
$> pip install update
$> pip install -r requirements.txt
```

Install `udpatedb` and `locate` tool

```bash
$> apt-get install locate
```

Install `svn` and `git`

```bash
$> apt-get install subversion git
```

#### Resolve locate

Edit `/etc/locale.gen`

```bash
$> echo en_US.UTF-8 UTF-8 > /etc/locale.gen
$> echo en_ES.UTF-8 UTF-8 >> /etc/locale.gen
$> echo en_GB.UTF-8 UTF-8 >> /etc/locale.gen
$> locale-gen
```

#### Install python PostgreSQL

I got this error when install psycopg2

``` bash
Error: pg_config executable not found.

Please add the directory containing pg_config to the PATH

or specify the full executable path with the option:

    python setup.py build_ext --pg-config /path/to/pg_config build ...

    or with the pg_config option in 'setup.cfg'.

    ----------------------------------------
    Command python setup.py egg_info failed with error code 1 in /srv/svn/build/psycopg2
```

To pass it, i use solutions from [stackoverflow](http://stackoverflow.com/a/5450183/126245)

```bash
$> apt-get install libpq-dev python-dev

#Reinstall requirements.txt agains, and it works
$> pip install -r requirements.txt
```

#### Install PostgreSQL database

First, install postgresql and postgis

```bash
$> apt-get install postgresql
$> apt-get install postgresql-9.1-postgis postgresql-contrib
```

Now, let config our PostgreSQL. PostgreSQL 9.1 was locate at /usr/lib/postgres/9.1.
Logout from "root" user, and login "vagrant", we should add postgres path to our
system by change ~/.bashrc file

```bash
$> echo export PATH=/usr/lib/postgresql/9.1/bin:\$PATH >> ~/.bashrc
$> source ~/.bashrc

# check whether path is active by test command createdb
$> createdb
createdb: could not connect to database postgres: could not connect to server: No such file or directory
    Is the server running locally and accepting
        connections on Unix domain socket "/var/run/postgresql/.s.PGSQL.5432
```

OK, postgres path is working. Now we write some script to control postgres easily.
NOTE that, to run postgres, you shouldn't run it by 'root' user.
In my case, i run it with 'vagrant' user.

Write the 'pg' script to control postgres

```bash
$> mkdir -p /home/vagrant/postgres/database
$> mkdir -p /home/vagrant/postgres/log
$> initdb /home/vagrant/postgres/database
$> sudo chown vagrant /var/run/postgresql
$> vim pg
#!/usr/bin/env sh
PROGRAM=pg
PGCTL=/usr/lib/postgresql/9.1/bin/pg_ctl
DATAPATH=/home/vagrant/postgres/database
LOGFILE=/home/vagrant/postgres/log/postgres.9.1.log
case $1 in
    start)
        $PGCTL -D $DATAPATH start 2>&1 > $LOGFILE
        ;;
    stop)
        $PGCTL stop
        ;;
    restart)
        $PGCTL stop
        echo "Starting postgres server ..."
        $PGCTL -D $DATAPATH start 2>&1 > $LOGFILE
        ;;
    *)
        echo "USAGE $PROGRAM {start|stop|restart}"
        ;;
esac

$> chmod +x pg
$> sudo mv pg /etc/init.d
$> pg start
$> createdb checkin_dev
```

Now, backup database from data.sql and schema.sql files in /srv/config/db.

```bash
$> psql checkin_dev < schema.sql
$> psql checkin_dev < data.sql
```

Or more convention, we should write a script to do all backup database.

```bash
#!/usr/bin/env sh
dropdb checkin_dev
createdb checkin_dev
pgsql checkin_dev < schema.sql
pgsql checkin_dev < data.sql
```

That 's all for tonight!
