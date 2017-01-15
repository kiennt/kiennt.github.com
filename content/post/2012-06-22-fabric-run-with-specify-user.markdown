+++
author = "kiennt"
date = "2012-06-22T00:00:00Z"
title = "Fabric run remote with specify user on a hostname"
url = "/blog/2012/06/22/fabric-run-with-specify-user.html"
image = "images/post/python-object-and-dictionary-convertion.jpg"
tags = ["tips"]
comments = true
share = true
+++

A little snippet to run fabric under specify user with ssh config:

<!--more-->

```python
from fabric.api import * # not really good, i dont like this kind of import

env.use_ssh_config = True # use configuration was define in ~/.ssh/config

@task
@hosts("host_name") # host_name is one you define in your ~/.ssh/config file
                    # this file will contain information about: ip, username, port, indentity file
def task_name():
    with settings(user="user_name"): # username is the user you want to login
                                     # if you dont set in in settings(user=<user_name>)
                                     # the default user will be get from env.user
        # run your task here
```

A example of **~/.ssh/config** file

```bash
Host vagrant
HostName 127.0.0.1
User vagrant
IdentityFile ~/.ssh/id_rsa
Port 2222
```
