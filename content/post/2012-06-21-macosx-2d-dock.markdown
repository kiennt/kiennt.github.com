+++
author = "kiennt"
date = "2012-06-21T00:00:00Z"
title = "Mac OSX Lion with 2D Dock"
url = "/blog/2012/06/21/macosx-2d-dock/"
image = "images/post/python-object-and-dictionary-convertion.jpg"
tags = ["tips"]
comments = true
share = true
+++

Dock in MacOSX Lion is cool, but i like simplicity. I dont like 3D Dock, and prefer 2D Dock.
In MacOSX Lion, to disable 3D effect on Dock, i do by followed step

<!--more-->

```bash
# change dock setting
$> defaults write com.apple.dock no-glass -boolean YES
# kill Dock and wait to see affect
$> killall Dock
```

To reset 3D Dock, just do:

```bash
$> defaults write com.apple.dock no-glass -boolean NO
$> killall Dock
```
