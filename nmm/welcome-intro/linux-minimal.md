---
marp: true
title: Introduction Network Monitoring, Management and Automation
description: Introduction Network Monitoring, Management and Automation
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
}pre > code {
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
<br />
<br />

# <!-- fit --> Network Monitoring, Management and Automation

<br />


## Linux Basics

<br />


### npNOG 5

Dec 8 - 12, 2019

[![Creative Commons License](https://i.creativecommons.org/l/by-nc/4.0/88x31.png)](http://creativecommons.org/licenses/by-nc/4.0/)

```licence
This material is licensed under a Creative Commons Attribution-NonCommercial 4.0 International License (http://creativecommons.org/licenses/by-nc/4.0/)
```

---

<style scoped>
img {
    float: right;
    width: 30%;
}
</style>
## Our chosen platform

![Ubuntu Logo](../images/ubuntu_black-orange_st_hex.png)

- Ubuntu Linux
  - LTS = Long Term Support
  - no GUI, we administer using ssh
  - Ubuntu is Debian underneath
- There are other platforms you could use:
  - CentOS / RedHat, FreeBSD, …
- This isn’t a UNIX admin course, but some knowledge is necessary:
  - Worksheets are mostly step-by-step
  - Please help each other or ask us for help

---

## You need to be able to…

- Be `root` when necessary
  _$ sudo \<cmd\>_
- Install packages
  $ _sudo apt-get install \<pkg\>_
- Edit files
  $ _sudo nano /etc/mailname_
  $ _sudo vi /etc/mailname_
- Check for the process "apache"
  $ _ps auxwww | grep apache_
- Start/Stop/Status of services
  $ _systemctl [start|stop|status] \<NAME\>_

---

## nano editor

- Ctrl-x y “n” quit without saving
- Ctrl-x y “y” to quit and save
- Ctrl-g for help
- Ctrl-w for searching
- Cursors work as you expect

---

## vi editor

- The default editor for all UNIX and Linux distributions
- Can be difficult to use
- If you know it and prefer to use vi please do
- We provide a PDF reference in the materials

---

## Other tools

- Terminate foreground program:
  - ctrl-c
- Browse the filesystem:
  - cd /etc
  - ls
  - ls -l
- Delete and rename files
  - mv file file.bak
  - rm file.bak

---

## Viewing files

Sometimes files are viewed through a pager program (“more”, “less”, “cat”). Example:

- man sudo
- Space bar for next page
- “b” to go backwards
- “/” and a pattern (/text) to search
- “n” to find next match
- “N” to find previous match
- “q” to quit

---

<style scoped>
ol, ul {
    margin-top: 0;
    font-size: 85%;
}
</style>

## Using ssh

_**Configuring and using ssh incorrectly will guarantee a security compromise…**_

The wrong way:

- Using simple passwords for users
- Allowing root to login with a password
- In reality – allowing any login with a password

The right way:

- Disable all password access
- Disable root access with password
- Some disable root access completely

---

## Using ssh: our way

For class we will compromise.

Our way:
– Allow user login with improved passwords
– Allow root login with ssh keys only

Understanding password strength, see next
slide…*

<br />

\* <https://xkcd.com/936/>

---

<style scoped>
img {
    width: 102%;
    display: block;
    margin: -50px auto;
}
</style>

<!--## Password Strength-->

![ Password Strength ](https://imgs.xkcd.com/comics/password_strength.png)

---

<style scoped>
img {
    width: 64%;
    display: block;
    margin: -40px auto;
}
</style>

## No Passwords are better

![](https://scriptcrunch.com/wp-content/uploads/2016/12/public-key-auth-workflow.png)

---

<style scoped>
ol, ul {
    margin-top: 0;
    margin-bottom: 10px;
    font-size: 85%;
}
p {
    margin: 10px auto 10px;
}
</style>

## Improve password for `lab` user

**Method 1** (moderately strong)

- 8 characters or more
- Not a word in any language
- A mix of numbers, upper and lower case
- Include some punctuation characters

**Method 2** (stronger)

- Use four words of 6 characters, or more
- Use unrelated words

**Examples** (do not use these!)

1. Tr0ub4dor&3
2. CorrectHorseBatteryStaple

---

## Using ssh to connect to your VM

- Login to your virtual machine using ssh
  - On Windows use putty.exe
  - Connect to vmX-gY.lab.workalaya.net as user sysadm
  - We’ll do that now...
- Accept Public Key when prompted
- Windows users can download putty from <http://www.lab.workalaya.net> and connect
- Instructors will now assist everyone to connect

---

## Change `lab` user password

Logged in as user `lab` do:

```bash
$ passwd
changing password for lab.
(Current) UNIX password:  <enter current password>
Enter new UNIX password: <enter new password>
Retype new UNIX password: <confirm new password>
```

If everything goes well you will see the message:

```bash
passwd: password updated successfully
```

---

## Finish initial VM configuration

Now we’ll do our initial VM configuration, including:

- Software package database update
- nano editor software installation
- Install network time protocol service and update time
- Install mail server and utilities
- Practice using logs
- Practice using man

---

<!--
_class: lead
_paginate: false
-->

## <!--fit--> :question:

<!-- Slide end -->
