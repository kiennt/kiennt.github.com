---
categories:
- tips
- server
comments: true
date: 2012-07-09T00:00:00Z
title: Use `grep` command to find content in Linux
url: /blog/2012/07/09/use-grep-to-find-content-in-linux.html
---

```bash
$> grep -r -in "SENTRY" --include=*.py .
```

-R : recursive
-in: show line and color
--include: only find files with pattern "*.py"
. : the directory we will find in
