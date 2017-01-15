+++
author = "kiennt"
date = "2012-06-23T00:00:00Z"
title = "Weeken with python (part 3)"
url = "/blog/2012/06/23/weekend-with-python-part3/"
image = "images/post/python-weekend.jpg"
draft = false
tags = ["python", "programming"]
comments = true
share = true
+++

In this serial, I write about what I learned about Python over the weekend.
This week, I talked about (1) how to write a function to find an element in a
list , (2) remove function of list, and (3) the different between `__getattr__`
and `__getattribute__`.

<!--more-->

### How to write a function to find an element in a list
I have a list, and a condition, what is the best way to write code to
list in list the first element which satisfy condition



Currently, I not really happy with this solution

```python
res = None
for x in alist:
    if condition(x):
        res = x
        break
```

What I really want is write a 1 or 2 line of code which easy
to understand and run fast to do this task
Some solutions using `filter` and `find` can write in 1-2 line
of code, but it must scan all list before return the result.

### Strange behavior of remove in list
I have a list, and a condition, now i want to write a code to
remove all element in list satify this condition

I found 2 solutions in here

Solution 1:
  + dont use list.remove() - it cost you O(N)
  + when want to delete element in array, traversal it in reverse ordering

```python
for i in xrange(len(alist), -1, -1):
    if condition(alist[i]): del alist[i]
```

Solution 2:
Instead of removing element in list, make a new list with condition
This solution is easy to read, but if the list input is large, it cost memory
```python
alist = [x for x in alist if condition(x)]
```

Firstly, i try this code
```python
for x in alist:
    if condition(x):
        alist.remove(x)
```
But this code will not work.

For example, we have a = [[1, 2], [1, 3], [1], [2], [3]].
We want to remove all element of `a` which have 2 elements.

When traverse like `for x in a`, the first element is a[0] will be removed.
But after a[0] be removed, a = [[1, 3], [1], [2], [3]].
So now, a[1] will be [1] but not [1, 3].

That the problem. That 's why in solution 1,
I travesel in reverse order to prevent it

## Diffirent between `__getattr__` and `__getattribute__`
The main key point is
  + `__getattr__` was only call if object access is not found in usually space
  (with new-style class is __dict__)
  + `__getattribute__` was call before any other method when object try to access
  a attribute

```python
>>> class Person(object):
        def __init__(self, name, age):
            self.name = name
            self.age = age

        def __getattribute__(self, key):
            print "get attribute '%s'" % key
            return object.__getattribute__(self, key)

        def __getattr__(self, key):
            print "get attr '%s'" % key
            return None
>>> a = Person('kiennt', 24)
>>> a.name
get attribute 'name'
kiennt
>>> a.programming_language
get attribute 'programming_language'
get attr 'programming_language'
None

```
