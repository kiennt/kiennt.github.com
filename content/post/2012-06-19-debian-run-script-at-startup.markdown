+++
author = "kiennt"
date = "2012-06-19T00:00:00Z"
title = "Debian run script at startup time"
url = "/blog/2012/06/19/debian-run-script-at-startup.html"
image = "images/post/startup.jpg"
draft = false
tags = ["server", "debian"]
comments = true
share = true
+++

When managing a server, we sometimes want when a server boots up, it also starts some services automatically. Especially if you are running a web application, you will want to run: web server, database server, your app instances, your background queue manager, ... and many other things.

This article will write about how to do these kinds of things with `debian` (please take a look at my other article about [config debian virtual machine](/blog/2012/06/18/install-virtual-machine-with-vagrant.html).

<!--more-->

Debian using Sys-V like init system for executing commands when the system run level changes.

Using `update-rc.d` to add new startup script.
(If you want to know more about Sys-V startup script, please take a look at `update-rc.d` document from `man` command)

If `udpate-rc.d` is not found in your terminal, update your $PATH

```bash
# please remember add the character '\' before $PATH in below command
$> echo export PATH=/sbin:/usr/sbin:\$PATH >> ~/.bashrc
$> source ~/.bashrc
```

Then you write a script to run at startup. You can check out my `pg` script for startup PostgreSQL database server at [config Debian virtual ma    chine](/blog/2012/06/18/install-virtual-machine-with-vagrant.html).

Please puts the script at `/etc/init.d` folder.

Now, using `update-rc.d` to add this script at startup time

```bash
$> sudo update-rc.d pg defaults
```

If you want to remove this script when system boot, using command

```bash
$> sudo update-rc.d -f pg remove
```


#### UPDATE 1
From Debian 6, they support command `insserv` to replace `update-rc.d`

#### UPDATE 2
The PostgreSQL script pg_ctl can not run with `root` user, to run it, you must run with other user.

But the problem is: At start up time, you run with `root` user, so we must using another user to run it.

When you install PostgreSQL database, it create in the system a new user "postgres".  We will use this use to run postgres

NOTE: To run a command with another user, using
```bash
$> su -c "<command> <parameters>" <user_name>
```

```bash
$> sudo mkdir -p /opt/postgres
$> sudo chown postgres /opt/postgres
$> su -c "mkdir -p /opt/postgres/database /opt/postgres/log" postgres
$> su -c "touch /opt/postgres/log/postgres.1.9.log"
$> vim /etc/init.d/pg
#!/usr/bin/env sh

### BEGIN INIT INFO
# Provides:          pg
# Required-Start:    $local_fs $remote_fs $network $syslog
# Required-Stop:     $local_fs $remote_fs $network $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: starts the postgresql database
# Description:       starts pg_ctl using start-stop-daemon
### END INIT INFO

PROGRAM=pg
START_STOP_DAEMON=/sbin/start-stop-daemon
PGCTL=/usr/lib/postgresql/9.1/bin/pg_ctl
DATAPATH=/opt/postgres/database
LOGFILE=/opt/postgres/log/postgres.9.1.log
DAEMON=$PGCTL
DAEMON_OPTS="-D $DATAPATH start -l $LOGFILE"

start() {
    echo "Starting PostgreSQL server ..."
    su -c "$DAEMON $DAEMON_OPTS" postgres
}

stop() {
    su -c "$PGCTL -D $DATAPATH stop" postgres
}

case $1 in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        stop
        start
        ;;
    *)
        echo "USAGE $PROGRAM {start|stop|restart}"
        ;;
esac
$> sudo update-rc.d pg defaults
```
