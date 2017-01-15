---
categories:
- programming
- server
- python
comments: true
date: 2012-07-05T00:00:00Z
title: Watch directory change with Python watchdog library
url: /blog/2012/07/05/watch-directiory-change-with-python-watchdog.html
---

Watchdog is Python API and shell utilities to monitor file system events.

Watchdog come with a tool call `watchmedo` to call shell command
when we get change on a directiory.
The "change" include: delete/modify/create a file in directory.

<!--more-->

For example, i want to terminate a tornaldo server (which was run by `supervise` tool)
everytime i change a python file. Here i what i make

I create a file /service/tornaldo-local/run

```bash
#!/usr/bin/env sh
TORNADO_PID=/var/run/tonardo.pid

export PYTHONPATH=$PYTHONPATH:/home/vagrant/current

. /home/vagrant/current/bin/envvars.local.sh

exec /usr/bin/python /usr/local/bin/watchmedo shell-command \
    --patterns="*.py;*.sh" \
    --recursive \
    --command="pgrep -f '/*manage.py' | xargs kill -9" \
    `ls -l /home/vagrant | grep current | awk '{print $11}'`/.. 2>&1 >/dev/null &
exec /usr/bin/python /home/vagrant/current/bin/manage.py start >> /var/log/tornado/tornado-local.log 2>&1

```
