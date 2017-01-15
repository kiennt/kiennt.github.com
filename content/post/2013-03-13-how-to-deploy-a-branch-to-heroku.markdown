---
categories:
- server
- git
- tips
comments: true
date: 2013-03-13T00:00:00Z
title: How to deploy a feature branch to heroku
url: /blog/2013/03/13/how-to-deploy-a-branch-to-heroku/
---

We often have many issues/feature which need to fix/enhance/add.

When developing an feature, we write code in local, the code is not finished.
But we found out there is a critical bugs in production, and that bug need to fix
immediately. We will need to deploy a hot fix the bug, but the hot fix should
not contains the incomplete code we wrote for the new feature.

<!--more-->

This case, we will need to create another branch in our git local repository.
And we will want to deploy the `hot fix` branch to our heroku dyno?

### How we deploy a branch to heroku
First, we need to create a branch for the hotfix, and checkout to the branch in
our local

For example, our local git repository have 3 branches:

* master
* feature-A
* hotfix-B (current branch)

We want to deploy `hotfix-B` to `staging`. We will use command

```bash
$> git push staging hotfix-B:master
```

And now, we will write code to fix the bug, testing on local, and push to staging
(if needed) to test

When we sure that the bug is fixed, in local, we will merge branch `hotfix-B` to
`master`, and move to branch `feature-A` to continue our work on new feature.
