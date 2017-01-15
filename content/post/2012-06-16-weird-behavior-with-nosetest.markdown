+++
author = "kiennt"
date = "2012-06-16T00:00:00Z"
title = "Weird behavior of nosetest"
url = "/blog/2012/06/16/weird-behavior-with-nosetest.html"
image = "images/post/work-around.jpg"
draft = false
tags = ["python", "programming"]
comments = true  
share = true
+++

In this article, I shared my experience with a weird bug in `nosetests`. Let 's
see what is it, and what we could do to fix/avoid it in future.

<!--more-->

With unittest, two functions `setUp` and `tearDown` will call before and after
every test case function.  With code bellow, I expected test cases will be passed:

``` python
import unittest

class TestSuite(unittest.TestCase):
    b = []

    def setUp(self):
        self.b.extend([10, 20])

    def tearDown(self):
        self.b = []

    def test_case_1(self):
        self.b.append(30)
        assert len(self.b) == 3
        assert self.b == [10, 20, 30]

    def test_case_2(self):
        self.b.append(40)
        assert len(self.b) == 3
        assert self.b == [10, 20, 40]
```

But when I run it with nose, the result is unexpected:

``` bash
$> nosetest test_module.py
.F
======================================================================
FAIL: test_case_2 (test_module2.TestSuite)
----------------------------------------------------------------------
Traceback (most recent call last):
File "/Users/knt/test_module2.py", line 19, in test_case_2
    assert len(self.b) == 3
AssertionError

----------------------------------------------------------------------
Ran 2 tests in 0.001s

FAILED (failures=1)
```

What 's happend ??? I expect after run `test_case_1`, `tearDown` will be
called, so `self.b` is [].  With next test case `test_case_2`, `setUp`
run and `self.b` is [10, 20]. But in fact, at `setUp` value of `self.b` is
`[10, 20, 30]`.  I don't know why??? I think there must be some problems with statement
`self.b = []`.  Anything related pointer, I guess. I still didn't figure it out, but I find a way
to work around this bug. Just change `self.b = []` to `del self.b[:]`:

``` python
    def tearDown(self):
        del self.b[:]
```

Now, lunch time !!!

#### Update

I post my question on [stackoverflow](http://stackoverflow.com/questions/11061943/weird-behavior-of-nosetest),
and the [answer](http://stackoverflow.com/a/11062902/126245) explains about
this bug.

In `tearDown` function, when I `self.b = []`, the `b` variable is not
class variable. In fact, python will create a new instance variable for this
class.  After that, at next test case, nose and unittest will create new instance of
TestSuite so, `self.b` of this instance still is a class variable. The reason
why `del self.b[:]` works is it does not create a new instance variable, but
still access class variable.

This bug gives me a new lesson when dealing with class variables.
The "best practice" with me is every time I want to access class variable in
method, I should use `self.__class__.<variable_name>`.
