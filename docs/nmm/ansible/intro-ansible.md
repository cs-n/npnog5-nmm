---
marp: true
title: Network Monitoring, Management and Automation - Introduction to Ansible
description: Network Monitoring, Management and Automation - Introduction to Ansible
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

![bg top 15%](../images/ansible-logo.png)

# <!-- fit --> Network Monitoring, Management and Automation

<br />

## Introduction to Ansible

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
</style>

## What is Ansible?

![Ansible Logo](../images/ansible-logo.png)

- A _**configuratoin management**_ tool
- Applies changes to your system to bring it to a desired state
- Similar applications include
  - [SaltStack](https://www.saltstack.com/)
  - [Puppet](https://puppet.com/)
  - [Chef](https://www.chef.io/)
  - [Juju](https://jujucharms.com/)
  - [CFEngine](https://cfengine.com/)

---

## Why choose Ansible?

- Target system requires only sshd and python
  - No daemons or agents to install
- Security
  - Relies on ssh
- Easy to get started, compared to the others!

---

## Ansible Modules

- Ansible _**modules**_ are small pieces of code which perform one function
  - eg. copy a file, start or stop a daemon
- Most are _**idempotent**_: running repeatedly has
the same effect as running once
  - only makes a change when the system is not already in the desired state
- Many modules supplied as standard
  - <https://docs.ansible.com/modules.html>

---

## Invoking modules from shell

```bash
            Host or Group            Module Name
                  |                        |
                  V                        V
    $ ansible vmX-gY.lab.workalaya.net -m service \
           -a "name=apache2 state=started"
              ----------------------------
                          ^
                          |
                   Module arguments

```

---

## Configuring Ansible behaviour

- _**Tasks**_ are modules called with specific arguments
- _**Handlers**_ are triggered when something changes
  - e.g. restart daemon when a config file is changed
- _**Roles**_ are re-usable bundles of tasks, handlers and templates
- All defined using YAML

---

## YAML

- A way of storing structured data as text
- Conceptually similar to JSON
  - String and numeric values
  - Lists: ordered sequences
  - Hashes: unordered groups of key-value pairs
- String values don't normally need quotes
- Lists and hashes can be nested
- Indentation used to define nesting

---

## YAML list (ordered sequence)

- single line form
  
  ```yaml
  [name, address, age]
  ```

- multi-line form
  
  ```yaml
  - name
  - address
  - age
   ^
   Space after dash required
  ```

---

## YAML hash (key-value pairs)

- single line form
  
  ```yaml
  {item: shirt, colour: red, size: 40}
        ^
        Space after colon required
  ```
  
- multi-line form
  
  ```yaml
  item: shirt
  colour: red
  size: 40
  description: |
    this is a very long multi-line
    text field which is all one value
  ```

---

## Nesting: list of hashes

- compact
  
  ```yaml
  - {item: shirt, colour: red, size: 40}
  - {item: shirt, colour: green, size: 44}
  ```
  
- multi-line form
  
  ```yaml
  - item: shirt
    colour: red
    size: 40
  - item: shirt
    colour: green
    size: 44
    ^
    Note alignment
  ```

---

<style scoped>
pre{
    font-size: 90%
}
</style>

## More complex YAML example
  
```txt
A list with 3 items
|
|  each item is a hash (key-value pairs)
|  |
V  V
- do: laundary  <-- simple value
  item:
    - shirts    <-- list value (note indentation)
    - trousers
- do: shopping
  item:
    - bread
    - jam
- do: relax
  eat:
    - chips
    - fruits
```

---

<style scoped>
pre{
    font-size: 90%
}
</style>

## Ansible Playbook
  
```txt
Top level: a list of "plays"
|  Each play has "hosts" plus "tasks" and/or "roles"
|  |
V  V
- hosts:
    - vm1-g1.lab.workalaya.net
    - vm2-g2.lab.workalaya.net
  tasks:
    - name: install Apache
      action: package name=apache2 state=present
    - name: ensure Apache is started
      action: service name=apache2 state=started
- hosts: dns_servers
  roles:
    - dns_server
    - ntp
```

---

## Ansible Roles

- A bundle of related tasks/handlers/templates

**roles/**_\<rolename>_**/tasks/main.yml**
**roles/**_\<rolename>_**/handlers/main.yml**
**roles/**_\<rolename>_**/defaults/main.yml**
**roles/**_\<rolename>_**/files/...**
**roles/**_\<rolename>_**/templates/...**

- Recommended way to make re-usable configs
- Not all these files need to be present

---

## Ansible Tags

- Each role or individual task can be labelled with one or more "tags"
- When you run a playbook, you can tell it only to run tasks with a particular tag: -t \<tag>
- Lets you selectively run parts of playbooks

---

## Ansible Inventory

- Lists all hosts which Ansible may manage
- Simple "INI" format, not YAML
- Can define groups of hosts
- Default is /etc/ansible/hosts
  - Can override using -i \<filename>

---

<style scoped>
pre {
    font-size: 85%;
}
</style>

## Inventory (hosts) example

```ini
[dns_servers]          <-- Name of group
ns1.lab.workalaya.net  <-- Hosts in this group
ns2.lab.workalaya.net

[vms]
vm1-g1.lab.workalaya.net
vm1-g1.lab.workalaya.net

[nagios_server]
noc.lab.workalaya.net
vm1-g1.lab.workalaya.net
vm1-g1.lab.workalaya.net
```

```txt
Note:
- the same host can be listed under multiple groups.
- Group "all" is created automatically
```

---

## Inventory variables

- You can set variables on hosts or groups of hosts
- Variables can make tasks behave differently when applied to different hosts
- Variables can be inserted into templates
- Some variables control how Ansible connects

---

## Setting host vars

- Directly in the inventory (hosts) file

  ```ini
  [core_servers]
  ns1.lab.workalaya.net ansible_connection=local
  ns2.lab.workalaya.net
  ```

- In file host_vars/pc2.example.com

  ```yaml
  ansible_ssh_host: 10.10.0.241
  ansible_ssh_user: root
  flurble:
    - foo
    - bar
  ```

  - This is in YAML and is preferred

---

## Setting group vars

- **group_vars/dns_servers**

  ```yaml
  # More YAML
  flurble:
    - foo-foo
    - bar-foo
  ```

- **group_vars/all**

  ```yaml
  # More YAML, applies to every host
  ansible_ssh_user: lab
  ansible_beccome_pass: yourpass
  ```

```txt
Note: host vars take priority over group vars
```

---

## Ansible Facts

- Facts are variables containing information collected automatically about the target host
- Things like what OS is installed, what interfaces it has, what disk drives it has
- Can be used to adapt roles automatically to the target system
- Gathered every time Ansible connects to a host (unless playbook has "gather_facts: no")

---

<style scoped>
pre {
    font-size: 85%;
}
</style>

## Showing facts

```bash
~$ ansible vmX-gY.lab.workalaya.net -m setup | less

vmX-gY.lab.workalaya.net | SUCCESS => {
    "ansible_facts": {
        "ansible_all_ipv4_addresses": [
            "100.68.X.21"
        ],
        "ansible_architecture": "x86_64",
        "ansible_bios_date": "12/12/2018",
        "ansible_bios_version": "6.00",
        "ansible_cmdline": {
            "BOOT_IMAGE": "/boot/vmlinuz-4.15.0-58-generic",
            "ro": true,
            "root": "/dev/mapper/lab--main--vg-root"
        },
        "ansible_date_time": {
            "date": "2019-11-13",
            "day": "13",
            "epoch": "1573634010",
```

---

## jinja2 template examples

- Insert a variable into text
  
  ```txt
  INTERFACES="{{ dhcp_interfaces }}"
  ```

- Looping over lists

  ```jija2
  search lab.workalaya.net
  {% for host in dns_servers %}
  nameserver {{ host }}
  {% endfor %}
  ```

---

## Many other cool features

- conditionals
  
  ```yaml
  - action: package name=apache2 state=present
    when: ansible_os_family=='Debian'
  ```

- Loops

  ```yaml
  - action: package name={{item}} state=present
    with_items:
      - openssh-server
      - rsync
      - telnet
  ```

---

## Getting up-to-date Ansible

- Your package manager's version may be old
- For Ubuntu LTS: use the PPA

  ```bash
  apt-get install python-software-properties
  add-apt-repository ppa:rquillo/ansible
  apt-get update
  apt-get install ansible
  ```
  
- or, if using python venv

  ```bash
  (venv) vmX-gY@ansible-gY:~/ansible-playbook$ pip install --upgrade ansible
  ```

---

## More info and documentation

- <https://docs.ansible.com/>
- <https://jinja.palletsprojects.com/>
- <https://yaml.org/>

---

<!--
_class: lead
_paginate: false
-->

## <!--fit--> :question:

<!-- Slide end -->
