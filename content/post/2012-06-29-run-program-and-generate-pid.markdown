+++
author = "kiennt"
date = "2012-06-29T00:00:00Z"
title = "Run program in UNIX and make pidfile for it"
url = "/blog/2012/06/29/run-program-and-generate-pid/"
image = "images/post/server.jpg"
draft = false
tags = ["tips", "server"]
comments = true
share = true
+++

We sometime want to run a program and after than stop it.

For example, at boot time, we start an [selenium](/blog/2012/06/29/using-selenium-with-headless-browser.html).
But after that, we want to stop it.

<!--more-->

The question is, how we could stop it?
One approach is using `ps -ef | grep` command.
But it hard to match exactly program we want to stop.
I think the correct way is using `pidfile`.
`pidfile` is the file which store a process id
(the process id of program we start)

This post will tell you 2 ways to create pid file

### 1. Using `start-stop-daemon` tool
Syntax of `start-stop-daemon` is

```bash
$> start-stop-daemon --start --chuid <username> --background \
     --make-pidfile --pidfile /var/run/<pidfile>.pid --exec $PROGRAM -- $PROGRAM-ARGUMENT
```

More details about program and its parameters
```bash
  `--chuid username`: set user you want to run program in.
        (It is best practice if we dont run it with root access)
  `--backgroud`: make program run in background
  `--make-pidfile`: force program to create pidfile
        (sometime it doesnot work. check document of `start-stop-daemon` for more details)
  `--pidfile`: specify pidfile for the program
  `$PROGRAM-ARGUMENT`: is ARGUMENT for the program
```

Example is with `selenium`
```bash
SELENIUM_PROGRAM=/usr/bin/java
SELENIUM_OPTS="-jar /home/vagrant/selenium-server-standalone-2.24.1.jar"
SELENIUM_PID_NAME=selenium
start-stop-daemon --start --chuid vagrant --make-pidfile --background --pidfile \
    /var/run/$SELENIUM_PID_NAME.pid --exec $SELENIUM_PROGRAM -- $SELENIUM_OPTS
```

### 2. Using bashscript
Bashscript also support a method `$!` to get process id of last command
```bash
$> python &
$> echo $!
4035
```

So, if we want to start our `selenium` server and make pidfile, we can write a script like this
```bash
SELENIUM_PROGRAM=/usr/bin/java
SELENIUM_OPTS="-jar /home/vagrant/selenium-server-standalone-2.24.1.jar"
SELENIUM_PID_NAME=selenium
SELENIUM_LOG_FILE=selenium.logfile
su -c "$SELENIUM_PROGRAM $SELENIUM_OPTS 2>&1 >>$SELENIUM_LOG_FILE &" vagrant
PID=$!
echo $PID > $SELENIUM_PID_NAME.pid
```

### 3. Stop process right way
Now, if you want to stop a program which process id was store in `pidfile`, it quite easy

```bash
# using cat and xargs and kill
$> cat <pidfile> | xargs kill

# using start-stop-daemon tool again
$> start-stop-daemon --stop --pid <pidfile>
```
