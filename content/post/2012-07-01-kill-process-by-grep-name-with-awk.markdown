---
categories:
- server
- shell
comments: true
date: 2012-07-01T00:00:00Z
title: Kill process by name with `awk`
url: /blog/2012/07/01/kill-process-by-grep-name-with-awk/
---

```bash
$> ps -ef | grep <process_name> | awk '{print $2}' | xargs kill -9
```
