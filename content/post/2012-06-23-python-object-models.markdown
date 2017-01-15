+++
author = "kiennt"
date = "2012-06-23T00:00:00Z"
title = "Python object model"
url = "/blog/2012/06/23/python-object-models/"
image = "images/post/python-object-and-dictionary-convertion.jpg"
tags = ["python", "programming"]
comments = true
share = true
+++

"In Python, everything is object".

What does it means? Is that like other Programming Language (for example Java),
everything in Python is instance of Base Class?
If it is, what is the Base Class in Python? I have heard about `object`
class in Python, is that Base Class?

<!--more-->

### Old-style and new-style class in Python

Well, with Python, it quite complex in here. Python have two model
`old-style` class and `new-style` class.
In fact, in old Python, there is not explicit base class for every
object in Python.
But from 2.2, with introduction of `new-style` class, we have (or must)
make every object is subclass of `object`.

Up to Python 2.1, `old-style` classes were the only flavour available
for user. The concept of `old-style` class is unrelated to concept of
type. If x is instance of an old-style class, `x.__class__` will reference to
the class of x. But type(x) is not, it is always `<type 'instance'>`.
Let look at the code below.

```python
    # old-style class was define by statement:
    #   class <class-name>: <class definition body>
    >>> class A:
            pass
    # type of class A is 'type' because 'type' is base-class in Python
    >>> type(A)
    <type 'type'>

    # make an instance of A
    >>> a = A()
    # a.__class__ reference to class A
    >>> a.__class__
    <class __main__.A at 0x10aea6ce8>
    # bute type of a is not A but 'instance'
    >>> type(a)
    <type 'instance'>
    # 'instance' still is 'type' class
    >>> type(type(a))
    <type 'type'>
```

New-style class was introduced from Python 2.2.
It was motivated from provide an unified object model for Python.
In new-style class, `object` class was introduced.
Everything will inheritance from `object`

```python
    >>> object.__class__
    <type 'type'>
    >>> type(object)
    <type 'type'>
```

`new-style` class was define by inheritance from `object` class.
In contrast with `old-style` class, if x is instance of `new-style` class,
both x.__class__ and type(x) will reference to the class of x.
```python
    >>> class A(object): pass
    >>> A.__class__
    <type 'type'>
    >>> x = A()
    >>> x.__class__
    >>> type(x)
    <type 'A'>
```

For compatibility with `old-style`, classes are still `old-style`
as default. If we want to using `new-stlye`, we need define class
is subclass from `object`

### The diffirence between `old-style` and `new-style` class
The clearly dirrirence between to styles was seen in type system.

Let look at how `old-style` class and `new-style` class handle
multiple inheritance. "Multiple inheritance" is capalicty a class
can inherit from many other classes. If A is inherit from B, A is subclass
(child class, derived class) of B, and B is superclas (base class, parent
class) of A.

Multiple class allow a class A can have many parents (with my opinion,
I dont like multiple inheritance at all, it quite wierd when a class
can have many parents. To solve same problem, other programming language
support another model like interface in Java, or mixins in Ruby.
Personally, I really like mixins model of Ruby).

In python object model, every class have `__bases__` attribute which
store all parent class in order of occurence in inheritance
```python
    >>> class A: pass
    >>> class B: pass
    >>> class C(A, B): pass
    >>> C.__bases__
    (<class __main__.A at 0x10aea6ce8>, <class __main__.B at 0x10af8de20>)
```

So, what is the problem with multiple inheritance?

Problem with multiple inheritance is order or superclass.
Why this order is important?
Because when an instance of subclass try to access an attribute
(variable or function). Firstly it will look its space to find that
attribute, if the attribute is not found, it keep looking in class space.
If still not found, the searching method continue with superclass space.
When a class have many superclass, the order of superclass is the
order in searching method.
In old-style class, order of superclass is depth-first, left-to-right
in the order of occurence in the bases list

```python
    >>> class A:
          def test(self): print "A"
    >>> class B(A):
          def test(self): print "B"
    >>> class C(A)
          def test(self): print "C"
    >>> class D(B, C): pass
    # order of D.__bases__ is (B, C) so D.test => B.test
    >>> D().test()
    "B"
    >>> class E(C, B): pass
    # order of E.__bases__ is (C, B) so E.test => C.test
    >>> E().test()
    "C"

    # so what if we make an class is inherited from D, E
    # note that, D and E are inherited from 2 class B, C with reverse order
    >>> class F(D, E): pass
    # in old-style class, it does not matter, the searching method
    # only care about order of superclass in __bases__
    # so now F.test => D.test => B.test
    >>> F().test()
    "B"

    # even if we make an class is inherited from A, D, E
    # it still works and test() method will be test() method of A
    >>> class G(A, D, E): pass
    >>> G().test()
    "A"
```

Old-style class method resolution is quite simple and easy to understand, right?
But if we follow this kind of rules, sometime we will make a mistake when
inheritance. For instance, we make an class G which is inherited from A, D, and
E, while A is parent of D and E. It should throw an error in this context to
prevent the circle inheritance like that

ANd new-style class solve this problem. New-style class have MRO (Method
Resolution Order) was introduced from Python 2.3.
The algorithm of MRO can describled as below

```python

def mro(cls):
    """
    Return ordering of superclass of cls
    This ordering was used when we want to access class instance atrribute

    `cls`: class type we want to resolve

    @raise `TypeError` if cannot resolution superclass order
    @return `list` of class
    """
    bases_cls = cls.__bases__
    mro_base_lists = [mro(base_cls) for base_cls in bases_cls]
    mro_list = [cls]
    while mro_base_lists:
        # find the good head
        # good head is head of a list which is not is tail of any list in mro_base_lists
        list_head = (x[0] for x in mro_base_lists)
        set_tails = set()
        for x in mro_base_lists:
            set_tails.update(x[1:])

        good_head = None
        for head in list_head:
            if head not in set_tails:
                good_head = head
                break

        # if cannot find good_head, raise TypeError
        if not good_head:
            raise TypeError
        else:
            # add to mro_list
            mro_list.append(good_head)

            # remove good_head in all list and add to mro_list
            for alist in mro_base_lists:
                try:
                    alist.remove(good_head)
                except Exception:
                    pass
            mro_base_lists = [x for x in mro_base_lists if x]
    return mro_list

class A: pass
class B(A): pass
class C(A): pass
class D(B, C): pass
class E(C, B): pass
class F(D, E): pass

def test_mro():
    assert mro(A) == [A]
    print "Test1 passed"

    assert mro(B) == [B, A]
    print "Test2 passed"

    assert mro(C) == [C, A]
    print "Test 3 passed"

    assert mro(D) == [D, B, C, A]
    print "Test 4 passed"

    assert mro(E) == [E, C, B, A]
    print "Test 5 passed"

    try:
        mro(F)
    except Exception as e:
        assert isinstance(e, TypeError)
        print "Test 6 passed"

test_mro()

```

The idea of MRO algorithm is sort baseclasses with condition:
If B is subclass of C, B always stand before C in list.
That is the reason why we have a TypeErorr if we define a class
D(B, C) and E(C, B) and after that F(D, E).

For more understand how MRO works, you should read
[explaination in python docs](http://www.python.org/download/releases/2.3/mro/)

To conclusion, ordering of baseclass is not only diffirence between
new-style and old-style class. I will write about this topic in next article.
