---
categories:
- python
- django
- celery
- tips
comments: true
date: 2012-11-07T00:00:00Z
title: Running celery task synchronous when testing django app
url: /blog/2012/11/07/run-celery-task-synchronous-when-testing-django.html
---

Celery support running task synchronous by config variable `CELERY_ALWAYS_EAGER`.
But where to put this variable? and could I can select run celery task synchronous
with some testcase?

I do some googling but did not find any good result. So I post this on my blog
to help someone like me.

<!--more-->

To set this variable in a testcase, just modify default django config variable at
beginning of test case


```python
# run celery task synchronous
from django.conf import settings
settings.CELERY_ALWAYS_EAGER = True
```

You can put this code in any testcase you want or in `setUp` function of a testcase.
