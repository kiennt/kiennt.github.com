---
categories:
- vim
- regular expresion
comments: true
date: 2012-06-30T00:00:00Z
title: VIM with regex
url: /blog/2012/06/30/regex-in-vim.html
---

Regular expression in VIM, you can specify a regex group by `\(` and `\)`.
To get value of group, use `\1` where 1 is number of group in regex

For example, i want to replace all ``name`` with :name
```bash
:%s/`\(\w+\)`/:\1/g
```
