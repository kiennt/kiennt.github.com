+++
author = "kiennt"
date = "2012-06-15T00:00:00Z"
title = "Weeken with python (part 1)"
url = "/blog/2012/06/15/weekend-with-python-part1.html"
image = "images/post/python-weekend.jpg"
draft = false
tags = ["python", "programming"]
comments = true
share = true
+++

In this serial, I write about what I learned about Python over the weekend.
This week, I talked about (1) what is different between `static method` and
`class method`, and (2) testing in python.

<!--more-->

### @staticmethod and @classmethod
When programming with python, you will see @staticmethod and @classmethod.
What is the different?

Both @staticmethod and @classmethod are like static methods in Java.
They are a function (method) of a class.
For example, if you have a class name `A`, which define a method `method_1` is static,
you can call this method without creating an instance of `A`

``` python
>>> class A(object):
        class_var = []

        @staticmethod
        def static_method_1():
            A.class_var.add(10)
            print A.class_var
            print "static method 1"

        @classmethod
        def class_method_1():
            """
            This will make an error when you run like
            TypeError: class_method_1() takes no arguments (1 given)
            """
            print "class method 1"

        @classmethod
        def class_method_2(klass):
            """
            This is fine
            """
            print klass.A
            print "class method 2"
>>>> A.static_method_1()
[10]
static method 1
>>>> A.class_method_1()
TypeError: class_method_1() takes no arguments (1 given)
>>>> A.class_method_2
[10]
class method 2
```

The only different between `@staticmethod` and `@classmethod` is `@classmethod`
must have first argument which is the class itself!


### Test framework with python
[nose](https://github.com/nose-devs/nose) is a test framework written in python

To install ``nose``

``` bash
$ sudo pip install nose
```

When working with our company project, I have to work with it.
Here is test case template was used

``` python
import unittest

def setup()
    pass

def teardown()
    pass

class ModuleWantToTest(object):
    def test_function1(self):
        pass

    def test_function2(self):
        pass
```

Next, you will want to test like this:

``` bash
$ nose test_file.py
```

Note that: two functions `setup` and `teardown` of a module will run before and after every class test cases.
If you want to make `setup` and `teardown` for every method in class, you must name it like `setUp` and `tearDown`.
and your TestSuiteClass must be an inheritance from `unittest.TestCase`.

``` python
import unittest
import nose

a = []

def setup():
    """
    This method will run before any class Test
    """
    with open('test_log', 'w') as f:
        f.write("setup module\n")
    a.extend([10, 20, 30])

def teardown():
    """
    If setup was run successful
    This method will will run after class Test
    """
    with open('test_log', 'a') as f:
        f.write("teardown module %s\n" % a)
    for i in xrange(0, len(a)):
        a.pop()

class SampleTestModule(unittest.TestCase):
    b = []

    @classmethod
    def setup_class(klass):
        """
        This method will run before any method Test of SampleTestModule
        """
        with open('test_log', 'a') as f:
            f.write("setup class\n")
        klass.b.extend([10, 20])
        pass

    @classmethod
    def teardown_class(klass):
        """
        This method will run after test and setup_class was run sucessful
        """
        with open('test_log', 'a') as f:
            f.write("teardown class\n")
        klass.b.pop()
        klass.b.pop()
        a.pop()
        pass

    def setUp(self):
        with open('test_log', 'a') as f:
            f.write("setup method\n")
        self.b.extend([40, 50])

    def tearDown(self):
        with open('test_log', 'a') as f:
            f.write("teardown method\n")
        self.b.pop()
        self.b.pop()

    def test_simple(self):
        assert len(a) == 3
        assert a == [10, 20, 30]
        assert len(self.b) == 4
        assert self.b == [10, 20, 40, 50]

    def test_simple2(self):
        assert len(a) == 3
        assert a == [10, 20, 30]
        # change a
        a.append(1)

        # because teardow will call after test_simple,
        # and setup_class re-run before test_simple2
        # so now b == [10, 20, 40, 50]
        assert len(self.b) == 4
        assert self.b == [10, 20, 40, 50]


class TestClass2(unittest.TestCase):
    def test_method(self):
        print a
        assert len(a) == 3
        assert a == [10, 20, 30]
```

Run this code, and check the log file we will see:

``` bash
$> python test_module.py
$> cat test_log
setup module
setup class
setup method
teardown method
setup method
teardown method
teardown class
teardown module [10, 20, 30]
```

It means  `setup` function of a module will run first, after that is `setup_class` function.
And with every test cases, `setUp` function will be called at the beginning, after that, the real test case will be called.
`tearDown` function will be called regardless of the result of the test case.
NOTE again 2 functions must be `setUp` and`tearDown` (it is camelCase but snake_case as PEP8 suggested)


But when in your test module, you want to import some other module, how you can do it?
Remember that, when you using `nose test_file.py`, the environment of python is the path of `nose` (which can get by `which nose`).
To solve it, you will want to add path of library to python path
Currently, I found 2 options:

+ Export to environment variable ``PYTHONPATH``

``` bash
$ export PYTHONPATH=path__to__library
```

Every time you run the test on another bash shell, you must retype this command.

+ You do not need to retype every time you run on another bash shell.
You add it on directly on you test file by the below snippet

``` python
import os
import sys

library__path = path__to__library
if library_path is not in sys.path:
    sys.path.insert(library_path, 0)
```

Most of the time, you want to structure your project folder like that:

``` bash
project_name/
   src/
   test/
```

So you will want to add `src` directory in python path:

``` python
current_path = os.path.dirname(__file__)
src_path = os.path.join(curent_path, '..', 'src')
if src_path not in sys.path:
    sys.path.insert(src_path, 0)
```

But it still got some annoying because the code to add `src path` must be provided in every test modules.
The better solution should have a script name `test` which include `src path`.
And this script has options run all test modules or single test module.
