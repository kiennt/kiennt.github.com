+++
author = "kiennt"
date = "2012-06-27T00:00:00Z"
title = "Start psql without enter password"
url = "/blog/2012/06/27/start-psql-without-enter-your-password/"
image = "images/post/startup.jpg"
draft = false
tags = ["tips", "server", "database", "postgresql"]
comments = true
share = true
+++

It 's so inconvenience when everytime you want to access `psql`, you
need to enter your **so long** password

Today, i learnt how to remove this step by using environment variable
`PGPASSWORD`

<!--more-->

```bash
export PGPASSWORD="<enter_your_password_here>"
exec psql -h <host_name> -d <database_name> -p <port> -U <user_name> "$@"
```

You even can write a script to make it fast. I name it *connect_db*

```bash
#!/usr/bin/env sh
prog=connect.db
case "$1" in
    <db1>)
        export PGPASSWORD="<enter_your_password_here>"
        exec psql -h <host_name> -d <db1> -p <port> -U <user_name> "$@"
        ;;
    <db2>)
        export PGPASSWORD="<enter_your_password_here>"
        exec psql -h <host_name> -d <db2> -p <port> -U <user_name> "$@"
        ;;
    *)
        echo "USAGE $prog {<db1>|<db2}"
        ;;
esac
```

If you want to automate every feed on prompt, you can using some **expect** library.

With python, we can look at [pexpect](http://sourceforge.net/projects/pexpect/)
