---
categories:
- tips
- database
- mysql
comments: true
date: 2012-08-03T00:00:00Z
title: Mysql without password
url: /blog/2012/08/03/mysqldump-without-password.html
---

When dealing with database, sometime we want to make backup database.
I usually use mysqldump to store all database in sql file.
The problem is when running, mysqldump ask us to provide password.
If you must enter password everytime you run the command, you cannot make it run
automatically with crontab script

<!--more-->

So, how to solve it???

Well, mysqldump allow us can run automaticall with an configuration file was
located at ~/.my.cnf. Format of this file is

```bash
[mysqldump]
host=<your_host_name>
username=<your_user_name>
password=<your_password>
```

And the file need to set in mod 600
