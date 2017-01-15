+++
author = "kiennt"
date = "2012-06-17T00:00:00Z"
title = "Weeken with python (part 2)"
url = "/blog/2012/06/17/weekend-with-python-part2/"
image = "images/post/python-weekend.jpg"
draft = false
tags = ["python", "programming"]
comments = true
share = true
+++

In this serial, I write about what I learned about Python over the weekend.
This week, I talk about 2 problems (1) function argument 's default value
and (2) function variable argument.

<!--more-->

### Function argument 's default value

Python supports default value for function argument like C++. But function
definition (using `def` keyword) actually a statement, so the default value of
function argument will be calculated at the time function was defined. It means,
when you set a default value for an argument, this value will change when you
change it in the function body. Let 's make an example:

``` python
import random

def make_array(data=[]):
    data.append(3)
    print data

```

The first time, you call `make_array`, data was set to new `list` object.
The object is bind with `data`. Later, every time you call `make_array`, the object
will change, so the size of data is increased with a number of the function call:

``` python
>>> make_array()
[3]
>>> make_array()
[3, 3]
>>> make_array()
```

The best practice to deal with this problem is we should set default value
is None:

```python
>>> def make_array(data=None):
        if not data:
            data = []
        data.append(3)
        print data
>>> make_array()
[3]
>>> make_array()
[3]
>>> make_array()
[3]
>>> make_array()
[3]

```

### Variable arguments

Python supports variable argument and key-value variables arguments.
Let 's start with an example:

``` python

>>> def test_variable_args(*args):
        for arg in args:
          print arg
>>> test_variable_args(10, 20, 30, 40)
10
20
30
40

>>> def test_key_value_variable_arguments(**kvargs):
        for key, value in kvargs:
            print "%s: %s" % (key, value)
>>> test_key_value_variable_arguments({ "name" : "kiennt", "age" : 24 })
name: kiennt
age: 24
```
