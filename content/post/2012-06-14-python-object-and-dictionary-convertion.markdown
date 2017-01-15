+++
author = "kiennt"
date = "2012-06-14T00:00:00Z"
title = "Python object and dictionary convertion"
url = "/blog/2012/06/14/python-object-and-dictionary-convertion.html"
image = "images/post/python-object-and-dictionary-convertion.jpg"
tags = ["python", "programming"]
comments = true
share = true
+++

When programing in Python, sometimes you want to convert an object to
dictionary and vise versal. In this article, I share my expericences
to do that.

<!--more-->


### Convert from class to dictionary

When you want to convert a class to dictionary just define class override from
object (this is important) and then call method `__dict__`:

``` python
>>> class Person(object):
        def __init__(self, age, name):
            self.age = age
            self.name = name
>>> a = Person('kiennt', 24)
>>> a.__dict__
{ 'name' : 'kiennt', 'age' : 24 }
```

### Convert from dictionary to class

In contrast, if you want to convert a dictionary to object, use this method.
I did not invent this method, it is borrowed from [stackoverflow.com](http://stackoverflow.com/a/1305663/126245))

``` python
>>> class Struct(object):
        def __init__(self, **entries):
            self.__dict__.update(entries)
>>> d = { 'name' : 'kiennt', 'age' : 24 }
>>> a = Struct(**d)
>>> a.name
"kiennt"
>>> a.age
24
```

I change above methods like bellow to get recusive convertion dictionary:

``` python
class Struct(object):
    def __init__(self, adict):
        """Convert a dictionary to a class

        @param :adict Dictionary
        """
        self.__dict__.update(adict)
        for k, v in adict.items():
        if isinstance(v, dict):
            self.__dict__[k] = Struct(v)

def get_object(adict):
    """Convert a dictionary to a class

    @param :adict Dictionary
    @return :class:Struct
    """
    return Struct(adict)
```

That 's it. Happy working with python!
