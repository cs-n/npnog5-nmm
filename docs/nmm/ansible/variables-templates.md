# **Variables and templates** #

## **1. Objective** ##

You have already seen how the variable `ansible_ssh_user` can be set and change how ansible connects to remote hosts.

In this exercise you will try out some ansible features using variable substitution and templates, so that you can customise behaviour per host.

---

## **2. Template expansion with jinja2** ##

[jinja2](http://jinja.pocoo.org/) is a python library which allows templates to be expanded in various ways, such as substituting a variable expression into parts of that template.

Let's go back to our web server example. Edit the file front.html so it looks like this:

~~~html
<html>
<head>
  <title>Hello world</title>
</head>
<body>
This server is acting as {{ server_role }}
</body>
</html>
~~~

And change the module which installs this file from "copy" to "template". That section of your web.yml file should now look like this:

~~~yaml
...
    - name: install index page
      template: src=front.html dest=/var/www/html/index.html backup=yes
...
~~~

Run your playbook:

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ ansible-playbook web.yml
~~~

What happens? It should fail like this.

~~~bash
TASK [install index page] ******************************************************
fatal: [vmX-gY.lab.workalaya.net]: FAILED! => {"changed": false, "msg": "AnsibleUndefinedVariable: 'server_role' is undefined"}
~~~

This is because our file is now a _jinja2 template_ and it is trying to substitute a variable called "server_role" into the file, but no such variable exists.

You could set these in the inventory, but let's do it a different way. Inside **_inventory_** directory, create a subdirectory called "**_host_vars_**"

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ mkdir inventory/host_vars
~~~

Using a text editor, create a file for each host you are managing. For the first host:

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi inventory/host_vars/vmX-gY.lab.workalaya.net

### make the contents of the file be like this:
server_role: primary webserver
~~~

Exit and save.

Run the playbook as usual.

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ ansible-playbook web.yml
~~~

Did it work? Seek help if not.

Now point your laptop web browser at your vm. They should display different content.

In general, this is a really useful way to install configuration files which are similar, but have minor differences for different hosts.

## **2.1. Conditional template expansion** ##

You are not limited to substituting variables. You can also make different parts of the template be used depending on some condition.

Try changing front.html to this:

~~~html
<html>
<head>
  <title>Hello world</title>
</head>
<body>
{% if server_role is defined %}
This server is acting as {{ server_role }}
{% else %}
I don't know what I am!
{% endif %}
</body>
</html>
~~~

What should happen is:

* if a variable called "server_role" has been defined, then it will be used
* if the variable hasn't been defined for this host, then different text will be used

To test this, remove the file `inventory/host_vars/vmX-gY.lab.workalaya.net` and re-run the playbook

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ rm inventory/host_vars/vmX-gY.lab.workalaya.net
(venv) vmX-gY@ansible-host:~/ansible-playbook$ ansible-playbook web.yml
~~~

Point your web browser at the your vm again, and see what response you get. (You may need to "reload" your browser to update the page if it has been cached)

---

## **3. Loops** ##

You can have the same task run iterate multiple times with different data. Here is one example: to install multiple packages you can do this in a loop:

~~~yaml
...
    tasks:
      - name: install debugging tools
        apt: pkg={{item}} state=present
        with_items:
          - tcpdump
          - strace
          - sysstat
~~~

Apart from being a bit simpler than having three separate tasks, it also runs a lot faster.

Notice how there is a Jinja2 expansion `{{item}}` within the YAML. The task is run once for each entry in `with_items`, and `{{item}}` is replaced with the current value of that item.

Another example is installing multiple files:

~~~yaml
...
    tasks:
      - name: install html files
        copy: src={{item}} dest=/var/www/html/{{item}} mode=644 owner=root
        with_items:
          - a.html
          - b.html
          - c.html
~~~

Exercise: incorporate these two new tasks into your playbook. Make them work. Remember that for the second one you will need to create some source files (a.html, b.html, c.html) to copy.

---

## **4. Conditional tasks** ##

### **4.1. The "setup" module** ###

Ansible collects a whole bunch of information, called "facts", about the hosts you are managing. Use the ansible (not ansible-playbook) command to run the "setup" module to see the available facts.

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ ansible all -m setup | less
~~~

Scroll through using space (next page), "b" (back), and then "q" to quit.

### **4.2. Conditional behaviour** ###

So now you can write tasks which run differently depending on the system being connected to. For example:

~~~yaml
...
    tasks:
      - name: install web server (Debian)
        apt: pkg=apache2 state=present
        when: ansible_os_family == 'Debian'

      - name: install web server (RedHat)
        yum: pkg=httpd state=present
        when: ansible_os_family == 'RedHat'
~~~

This set of tasks can be run against Debian-derived systems (including Ubuntu), and RedHat-derived systems (including CentOS), and the tasks relevant to each type of system will be run.

You can also set additional variables (facts) dynamically dependent on what has been set already, and use them in subsequent tasks.

~~~yaml
      - name: set default web root
        set_fact: web_root=/var/www

      - name: set web root (Debian)
        set_fact: web_root=/var/www/html
        when: ansible_os_family == 'Debian'

      - name: install index page
        template: src=front.html dest={{web_root}}/index.html backup=yes
~~~

Exercise: update your playbook to include this, so that it can install a webserver on either Debian or RedHat.

An alternative way to do this is to set default variables using a "vars:" section in your playbook; these can be overridden later.

~~~yaml
- hosts: ...

  vars:
    web_root: /var/www

  tasks:
    - name: set web root (Debian)
      set_fact: web_root=/var/www/html
      when: ansible_os_family == 'Debian'

    - name: install index page
      template: src=front.html dest={{web_root}}/index.html backup=yes
~~~

---

## **5. Further reading** ##

See [playbooks variables](http://docs.ansible.com/playbooks_variables.html) and the subsequent sections of the Ansible documentation.

See also the [templates](http://jinja.pocoo.org/docs/dev/templates/) section of the jinja2 documentation.

---
