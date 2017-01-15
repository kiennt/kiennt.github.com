+++
author = "kiennt"
date = "2012-06-25T00:00:00Z"
title = "Change LINUX timezone and datetime"
url = "/blog/2012/06/25/unix-change-time/"
image = "images/post/timezone.jpg"
draft = false
tags = ["server"]
comments = true
share = true
+++

This article is some TIL about setting up timezone in Debian server

<!--more-->

### Change timezone in Linux
In DEBIAN, to change timezone, we using file /etc/localtime
For example, in my case, I am living at Ho Chi Minh city, so I want to change timezone to Asia/Ho_Chi_Minh

```bash
# first you should backup your /etc/localtime :-P
$> sudo cp /etc/localtime /etc/localtime.old
# create a soft link of timezone you want to use to /etc/localtime
$> sudo ln -sf /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime

# check the result
$> date
Mon Jun 25 20:26:02 ICT 2012

# Cool, timezone now is ICT (indochina  timezone)
```

### Change date of Linux system
We using `date` command to change Linux datetime

```bash
# print current date time
$> date
Mon Jun 25 20:26:02 ICT 2012

# change datetime to another time using date --s=FORMAT
# with FORMAT = YYYYMMDD hh:mm:ss
#   YYYY: 4-character years
#     MM: 2-character months
#     DD: 2-character days
#     hh: hours
#     mm: minutes
#     ss: seconds
$> date --s="20120630 20:26:02"

# check the result
$> date
Sat Jun 30 20:26:02 ICT 2012
```
