+++
author = "kiennt"
date = "2012-06-28T00:00:00Z"
title = "Config PostgreSQL database with authentication"
url = "/blog/2012/06/28/config-postgresql-database-with-authentication/"
image = "images/post/startup.jpg"
draft = false
tags = ["tips", "server", "database", "postgresql"]
comments = true
share = true
+++

This article is what I learn about config PostgreSQL server and set its
authentication up.

<!--more-->

### 1. Config client authentication
After install postgresql database, you need to config the database in securely way.
Postgresql create new user `postgres`, you should start PostgresDB under this user.
The default configuration of PostgresDB is trusted. It means that, if you have any valided user with
login permission, you can login to PostgresDB in localhost.

We need change it. Assume that, when you run PostgresDB, the DBPATH is **/opt/postgres/database**

```bash
$> su postgres
$> vim /opt/postgres/database/pg_hba.conf
# TYPE  DATABASE        USER            ADDRESS                 METHOD
local   all             all                                     password
host    all             all             127.0.0.1/32            password
host    all             all             ::1/128                 password

```

At column METHOD, we have some options:

1. `trust`: this option allow every account login without password
2. `password`: this option force every account when login must provide an password
3. `md5`: this option force every account when login must provide md5 encrytion of password

For more information, please read [document at postgres website](http://www.postgresql.org/docs/9.1/static/auth-pg-hba-conf.html)

At `address` column, you specify the ip address PostgreSQL accept incomming connection.
The IPv4 addresses have format <ip_address>/<number_mark_bit> where `number_mark_bit` is number of bit in ip address will be match with the ip address you provides.

Eg:

```bash
192.168.1.130/32: match all 32 bit of 192.168.1.130 - exactly 192.168.1.130
192.168.1.130/24: match 192.168.1.*
192.168.1.130/16: match 192.168.*.*
```

But modify ADDRESS column is not enough if you want to accept incomming connection from other IP address. You also need to modidy `postgresql.conf` file.

In file `postgresql.conf` (in my case is /opt/postgres/database/postgresql.conf)

```bash
# change the line have listen_addresses
listen_addresses = '*'
# the default value is listen_address = 'localhost' -
# it means that database run in only localhost
# you want other machine can connect to database,
# you need set database run on other public ip
```

### 2. Create user

We need alter password for user `postgres` and create new user if neccessary

```bash
$> psql -U postgres
postgres=# ALTER ROLE postgres PASSWORD 'my_password'
postgres=# CREATE ROLE kiennt LOGIN;
postgres=# ALTER ROLE kiennt PASSWORD 'kiennt_password';
postgres=# ALTER ROLE kiennt CREATEDB;

# to see all role in database, postgres support commmand \du+
postgres=# \du+
```

Now, restart PostgresSQL, to see the change

```bash
$> sudo /etc/init.d/pg restart
$> psql -U psql
Password for user postgres:
# ok, cool
```

NOTE, if you want to know what is `/etc/init.d/pg` file, please read [my previous post](/blog/2012/06/18/install-virtual-machine-with-vagrant.html)
