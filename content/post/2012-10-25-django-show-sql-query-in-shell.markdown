---
categories:
- programming
- python
- django
- tips
comments: true
date: 2012-10-25T00:00:00Z
title: Django show sql query in shell
url: /blog/2012/10/25/django-show-sql-query-in-shell/
---

To show sql query in `python manage.py shell`, we use this code

```python
import logging
l = logging.getLogger('django.db.backends')
l.setLevel(logging.DEBUG)
l.addHandler(logging.StreamHandler())
```
