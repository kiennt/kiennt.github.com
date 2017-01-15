+++
author = "kiennt"
date = "2012-06-19T08:00:00Z"
title = "Using deamon tools to make process keep alive"
url = "/blog/2012/06/19/manager-daemon-process-with-daemon-tools.html"
image = "images/post/startup.jpg"
draft = false
tags = ["server"]
comments = true
share = true
+++

Sometime, you want your process run forever, for example your web server, your web application instance, your database, your crawler, ... But how you keep it running? Well, in UNIX we have [daemon](http://cr.yp.to/daemontools.html) tools. To install it on `debian`

<!--more-->

```bash
$> sudo apt-get install daemontools
```

`daemon tools` provide for use some useful tool. Today, i just have time to play with `supervise`. This is program to keep our process alive.

How to use `supervise`, let take a look at `man supervise`

```bash
supervise switches to the directory named s and starts ./run. It
restarts ./run if ./run exits. It  pauses  for  a  second  after
starting  ./run,  so  that it does not loop too quickly if ./run
exits immediately.

If the file s/down exists, supervise does not start ./run  imme‐
diately.  You  can  use  svc(8) to start ./run and to give other
commands to supervise.

supervise maintains status information in a binary format inside
the  directory s/supervise, which must be writable to supervise.
The status information can be read by svstat(8).

supervise may exit immediately after startup if it  cannot  find
the  files  it  needs  in  s  or if another copy of supervise is
already running in s.  Once supervise is  successfully  running,
it  will  not  exit unless it is killed or specifically asked to
exit. You can use svok(8) to check whether supervise is success‐
fully running. You can use svscan(8) to reliably start a collec‐
tion of supervise processes.
```

For example, I want to keep alive my tornado server

```bash
$> mkdir -p /service/tornado-local /var/log/tornado-local
$> vim /service/tornado-local/run
1. #!/usr/bin/env sh
2. export PYTHONPATH=$PYTHONPATH:/home/vagrant/current
3. . /home/vagrant/current/bin/envvars.local.sh
4. exec /usr/bin/python /home/vagrant/current/bin/manage.py start >> /var/log/tornado/tornado-local.log 2>&1
$> supervise /service/tornado-local &
```

NOTE: at line 3 for file `/service/tornado-local/run`, i using . - it similar like `source /home/vagrant/current/bin/envvars.local.sh`. That is the trick i learn after googling because `source` does not work with me. Hope you get any luck with it

The last thing is we should run supervise at startup. Let check it on my [other article](/blog/2012/06/19/debian-run-script-at-startup.html).

```bash
# add new services
$> vim /etc/init.d/supervise_tornado
#!/usr/bin/env sh
case $1 in
    start)
        su -c "/usr/bin/supervise /service/tornado-local &" vagrant
        ;;
    *)
        echo "USAGE {start}"
        ;;
esac

$> sudo chmod +x /etc/init.d/supervise_tornado
$> sudo update-rc.d supervise_tornado defaults
```
