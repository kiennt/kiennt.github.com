#!/usr/bin/env sh

# create gh-pages folder
mkdir -p gh-pages
rm -rf gh-pages/*
rm -rf gh-pages/.git

# generate content and move to gh-pages folder
hugo --theme casper
cp -r public/* gh-pages/
rm -rf gh-pages/deploy.sh

cd gh-pages

# init repo everytime we build
git init .
git remote add origin git@github.com:kiennt/kiennt.github.com.git

# need to add CNAME file everytime we build
touch CNAME
echo kiennt.com > CNAME

# add all file to git
git add -A

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# force push to gh-pages branch
git push origin master:master -f
