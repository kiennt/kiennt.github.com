+++
author = "kiennt"
date = "2012-06-25T00:00:00Z"
title = "Config virtual host with NGINX in DEBIAN"
url = "/blog/2012/06/25/config-virtualhost-with-nginx/"
image = "images/post/server.jpg"
draft = false
tags = ["server"]
comments = true
share = true
+++

This article, I want to shared what I learn when install a virtual host for
NGINX in an Debian server.

<!--more-->

### Install `nginx`
nginx is fast and lightweight server. In web development `nginx` mostly was use as web server for static file and reserved proxy.

To install nginx on DEBIAN, using our beloved **apt-get**
```bash
$> sudo apt-get install nginx
```

### Configuration virtual host for nginx
If in our system, we need to server many web application. Eg: port 8212 we server an API serve, on port 8214 we serve web client.

Nginx virtual host is easily to configuration

Firstly, we need to modify /etc/nginx/nginx.conf
```bash
$> vim /etc/nginx/nginx.config
user www-data;            # user which nginx with run at
worker_processes 4;       # number of worker
pid /var/run/nginx.pid;

events {
    worker_connections 768; # number of connection each worker can handle
}

http {
    # configuration for TCP
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # logfile
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    # gzip config
    gzip on;
    gzip_disable "msie6";
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_buffers 16 8k;
    gzip_http_version 1.1;
    gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript;

    # virtual host
    # this line is importance, we will include all configuration for
    #   each host in folder /etc/nginx/sites-enabled/
    include /etc/nginx/sites-enabled/*;
}
```

Now, we create new configuration for a host.
I often create many configuration file in folder /etc/nginx/site-available,
and then make soft link to folder /etc/nginx/site-enabled

```bash
$> vim /etc/nginx/site-available/contactsync.com
# name our server
upstream contactsync {
    server localhost:4444; # in here, we can create many application
                           # instance, but have some paper tell that
                           # we should create number of instance
                           # equal number of CPU core
}

server {
    listen 80;  # the port server will listen
                # with this config, every request from port 80
                # will redirect to port 4444

    # config log file
    access_log /var/log/nginx/contactsync/contactsync.access.log;
    error_log /var/log/nginx/contactsync/contactsync.error.log;

    # config the proxy
    location / {
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_redirect off;

        if (!-f $request_filename) {
            proxy_pass http://contactsync;
            break;
        }
    }
}

# create soft link
$> ln -s /etc/nginx/site-available/contactsync.com /etc/nginx/enabled/contactsyn.com

# restart nginx to apply
$> /etc/init.d/nginx restart
```
