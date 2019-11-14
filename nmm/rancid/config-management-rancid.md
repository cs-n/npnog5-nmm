---
marp: true
title: Network Monitoring, Management and Automation - Configuration Management with RANCID
description: Network Monitoring, Management and Automation - Configuration Management with RANCID
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

# <!-- fit --> Network Monitoring, Management and Automation

<br />
<br />

## Configuration Management with RANCID

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
</style>

## What is RANCID?

### <!--fit--> Really Awesome New Cisco config Differ

![Nagios Core Logo](../images/nagios-core.png)

A configuration management tool:

- Keeps track of changes in the configs of your network equipment (Cisco, HP, Juniper, Foundry, etc.)
- Works on routers and switches

---

## What is RANCID? (Contd...)

- Automates retrieval of configs & archives them
- Functions as:
  - Backup tool - ”woops, my router burned”
  - Audit tool - ”how did this error get in?”
  - Blame allocation :) - ”who did it?”
- The data is stored in a VCS, either of:
  - CVS (Concurrent Versions Systems)
  - SVN (SubVersioN)

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

## How does RANCID work?

- Run (manually or automated)
- Lookup list of groups
  For each device in each list of groups
  - Connect to the equipment (telnet, ssh, …)
  - Run ”show” commands – config, inventory, ...
  - Collect, filter/format data
  - Retrieve the resulting config files
  - CVS/SVN check-in the changes
  - Generate a diff from the previous version
  - E-mail the diff to a mail address (individual or group)

---

## Why Use RANCID?

- Track changes in the equipment configuration
- Track changes in the hardware (S/N, modules)
- Track version changes in the OS (IOS, CatOS versions)
- Find out what your colleagues have done without telling you!
- Recover from accidental configuration errors (anyone have stories?)

---

## Post Processing

- Run traditional filtering commands on your configs (grep, sed, for information)
- Re-use the automated login tools to build your own batch tools or do interactive login
- On large configurations, you can parallelize operations

---

## Other Operations

- Automated checks
  (verify configs for strange / inconsistent setup)
- Generate DNS file from equipment list
- Use IP address adjacency to produce a graph of your network

---

## References

- RANCID Project: <http://www.shrubbery.net/rancid/>
- Subversion (SVN): <http://subversion.apache.org/>

---

<!--
_class: lead
_paginate: false
-->

## <!--fit--> :question:

<!-- Slide end -->
