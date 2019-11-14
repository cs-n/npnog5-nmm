---
marp: true
title: Network Monitoring, Management and Automation - Git Overview
description: Network Monitoring, Management and Automation - Git Overview
footer: '_npNOG5_'
paginate: true
theme: gaia 
# other themes: uncover, default
# class: lead
# Default size 16:9
size: 4:3
backgroundColor: #fff
backgroundImage: url('../images/hero-background.jpg')
style: |
    h1, footer {
        color: #4e8fc7;
    }
    h2 {
        color: #455a64;
        color: #f97c28;
    }
    footer {
        #text-align: right;
        height: 50px;
        line-height: 30px;
    }
    ol, ul {
        padding-top: 0;
        #margin-top: 0;
        font-size: 90%;
    }
    ol > li, ul > li {
        margin: 0;
    }
    ol > li> p, ul > li > p {
        margin: 0;
    }
    a {
        text-decoration: none;
    }
---

<!-- Local Page style -->
<style scoped>
h1 {
  color: #4e8fc7;
}
h2 {
    color: #455a64;
    color: #f97c28;
}
img {
    float: left;
    margin-left: -40px;
}
pre {
    margin: -33px 50px 0px;
    width: 810px;
    float: right;
}
pre > code {
    background-color: #f8f8f8;
    color: #4d4d4c;
}
</style>
<!--
_class: lead
_footer: '' 
_paginate: false
-->
<!-- End Local Page style-->

<!-- Slide starts -->
<br />

![bg top 25%](../images/Git-Logo-2Color.png)

# <!-- fit --> Network Monitoring, Management and Automation

<br />

## Git Overview

<br />
<br />
<br />

### npNOG 5

Dec 8 - 12, 2019
<br />

[![Creative Commons License](../images/cc-license.png)](http://creativecommons.org/licenses/by-nc/4.0/)

```licence
This material is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License (http://creativecommons.org/licenses/by-nc/4.0/)
```

---

<style scoped>
img {
    float: right;
    width: 30%;
    margin: auto -20px;
}
p {
    font-size: 75%;
    margin: 10px auto;
}
ol, ul {
    margin-top: 0;
    margin-bottom: 5px;
    font-size: 75%;
}
</style>

## What is Git?

![GIT Logo](../images/Git-Logo-2Color.png)

- an open source distributed version control system
- for tracking changes in source code during software development
- is designed for coordinating work among programmers
- but it can be used to track changes in any set of files
- developped by Linus Torvalds to support the development of the linux kernel
- its goals include speed, data integrity, and support for distributed, non-linear workflows

- a few other popular version control systems include:
  - RCS
  - CVS
  - Subversion
  - Mercurial
  - Bitkeeper (proprietary, led Linus to create Git)

---

## What is Version Control?

Three basic principles:

- Keep a record and history of changes
- Give public access to the information
- Maintain different versions from the same data set

What types of data?

- Source code
- **Documentation**
- **Configuration files**
- Generally, any type of data…

---

<style scoped>
img {
    float: right;
    width: 30%;
    margin: auto -20px;
}
p {
    font-size: 75%;
    margin: 10px auto;
}
ol, ul {
    margin-top: 0;
    margin-bottom: 5px;
    font-size: 75%;
}
</style>

## What is GitHub?

![GitHub Logo](../images/GitHub-Octocat.png)

- www.github.com
- largest web-based git repository hosting service
  - hosts `remote repositories`
- allows for collaboraton with anyone online
- adds extra functionality on top of git
  - UI
  - documentation
  - bug tracking
  - feature requests
  - pull requests
  - and more
- alternatives
  - GitLab
  - Bitbucket
  - Gitea
  - Gogs
  - more

---

<style scoped>
ol, ul {
    margin-top: 0;
    margin-bottom: 5px;
    font-size: 75%;
}
</style>

## <!--fit--> Your first time with git and github

- Get a github account.
- Download and install git.
- Set up git with your user name and email.

    ```bash
    $ git config --global user.name "Your name here"
    $ git config --global user.email "your_email@example.com"
    ```

- Set up ssh on your computer
- Paste your ssh public key into your github account settings.
  - Go to your github Account Settings
  - Click “SSH Keys” on the left.
  - Click “Add SSH Key” on the right.
  - Add a label (like “My laptop”) and paste the public key into the big text box.
  - In a terminal/shell, type the following to test it:

    ```bash
    $ ssh -T git@github.com
    ```

  - If it says something like the following, it worked:

    ```txt
    Hi username! You've successfully authenticated, but Github does not provide shell access.
    ```

---

<style scoped>
ol, ul {
    margin-top: 0;
    font-size: 75%;
}
pre {
    margin: 0px;
    padding: 0px;
    font-size: 80%;
}
</style>

## Routine use of git and github

- create repository

  ```bsh
  $ git init .
  ```

- clone git remote repository to local working project directory

  ```bsh
  $ git clone git@github.com:username/repo
  ```

- add all file in project directory into git

  ```bash
  $ git add .
  ```

- add specific file named 'Readme.md' into repository

  ```bash
  $ git add Readme.md
  ```

- commit changes into repository

  ```bash
  $ git commit -am "Added Readme.md file"
  ```

- get git status

  ```bash
  git status
  ```

- push changes to remote repository

  ```bash
  $ git push origin master
  ```

---

<style scoped>
ul, p, pre {
    font-size: 80%;
}
</style>

## Connect it to github

- Create a local git repository
- Go to github
- Log in to your account
- Click the new repository button in the top-right. You’ll have an option there to initialize the repository with a README file, but don’t.
- Click the “Create repository” button.

Now, follow the second set of instructions, “Push an existing repository…”

```bash
$ git remote add origin git@github.com:username/new_repo
$ git push -u origin master
```

---

<!--
_class: lead
_paginate: false
-->

## <!--fit--> :question:

<!-- Slide end -->
