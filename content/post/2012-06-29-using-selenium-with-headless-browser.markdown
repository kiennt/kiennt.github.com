+++
author = "kiennt"
date = "2012-06-29T00:00:00Z"
title = "Using selenium with headless browser"
url = "/blog/2012/06/29/using-selenium-with-headless-browser.html"
image = "images/post/server.jpg"
draft = false
tags = ["testing", "python"]
comments = true
share = true
+++

My note about setting selenium

<!--more-->

First install virtual display

```bash
# install virtual display xvfb
$> sudo apt-get install xvfb xserver-xephyr
# install PyVirtualDisplay which is python wrapper for xvfb
$> sudo pip install pyvirtualdisplay
# install selenium python driver
$> sudo pip install selenium
```

Second install selenium, google chrome and chromedriver on linux

```bash
# selenium server
$> curl -O http://selenium.googlecode.com/files/selenium-server-standalone-2.24.1.jar
# selenium chrome driver
$> curl -O http://chromedriver.googlecode.com/files/chromedriver_linux32_21.0.1180.4.zip
$> unzip chromedriver_linux32_21.0.1180.4.zip
# move chromedriver to /usr/bin, so next time you start selenium server, chromedriver will be loaded
$> sudo mv chromedriver /usr/bin
# install chrome on debia
$> sudo apt-get install chromium-browser chromium-browser-110n
```

Next, start selenium server
```bash
$> java -jar /home/<user_name>/selenium-server-standalone-2.24.1.jar 2>&1 > /dev/null &
```

Now, when write code to run chrome headless

```python
from pyvirtualdisplay import Display
from selenium import webdriver

display = Display(visible=0, size=(800, 600))
display.start()

browser = webdriver.Chrome()
browser.get("http://www.google.com")
print browser.title
browser.quit()

display.stop()
```
