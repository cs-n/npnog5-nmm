# **First playbooks in Ansible** #

## **1. Objective** ##

In this exercise you will be writing your first Ansible _playbooks_ containing _tasks_

---

## **2. Setup** ##

Make sure you are logged into your master ansible machine over SSH with agent forwarding enabled. You should be logged in as your normal non-root user ("vmX-gY").

Also make sure that from this host, ansible is able to login as root to all the other machines you are managing. To test this:

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ ansible all -m shell -a id -b
~~~

You should get a response like this:

~~~bash
vmX-gY.lab.workalaya.net | CHANGED | rc=0 >>
uid=0(root) gid=0(root) groups=0(root)
~~~

This shows that the login was successful (return code zero = OK) and that when the command "id" was run on the remote machines, it was running as user "root".

---

## **3. Writing a playbook** ##

A playbook comprises of a list of hosts and tasks entries, like this:

~~~yaml
- hosts: ...
  tasks: ...
- hosts: ...
  tasks: ...
- hosts: ...
  tasks: ...
~~~

In each section, you define a set of task(s) to be run on a set of host(s). The playbook is run in sequence, although the same task can run on multiple hosts in parallel.

### **3.1. Creating a first playbook** ##

You will do the following as the "sysadm" user. Check you are in your home directory:

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ pwd   # should show/home/vmX-gY/ansible-playbook
~~~

If necessary, use "cd" to change to the right directory.

Now use a text editor of your choice to create a file "first.yml"

The contents of this file should look like this:

~~~yaml
- hosts:
    - all
  tasks:
    - action: ping
~~~

Now run the playbook like this:

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ ansible-playbook first.yml
~~~

Did it work? The output should be like:

~~~txt
(venv) vmX-gY@ansible-host:~/ansible-playbook$ ansible-playbook first.yml

PLAY [all] *********************************************************************

TASK [Gathering Facts] *********************************************************
ok: [vmX-gY.lab.workalaya.net]

TASK [ping] ********************************************************************
ok: [vmX-gY.lab.workalaya.net]

PLAY RECAP *********************************************************************
vmX-gY.lab.workalaya.net   : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
~~~

Details about output of ansible-playbook have these sections:

`GATHERING FACTS`
This is when the "setup" module is being run to collect information about the hosts you are connecting to

`TASK: ping`
The task you defined in the playbook

`PLAY RECAP`
Summarises which tasks were run, how many were success or failure, and how many changes were made

So far your playbook is essentially doing what you did using the ansible command-line tool.

~~~bash
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ git add .
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ git commit -am "add first.yml file"
~~~

<!--
(If you get bored of the cows, you can either uninstall the `cowsay` package, or uncomment `nocows = 1` in `/etc/ansible/ansible.cfg`)
-->

---

## **4. Web server example** ##

To make a more realistic example, let's install a webserver (apache2) on your virtual machine.

Create **_web.yml_** which looks like this:

~~~yaml
- hosts:
    - vmX-gY.lab.workalaya.net
  become: true
  tasks:
    - action: apt update_cache=yes cache_valid_time=3600
    - action: apt pkg=apache2 state=present
~~~

Replace vmX-gY the hosts you are managing; they must exist in your inventory.

Run it (note that it may be slow the first time).

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ ansible-playbook web.yml
~~~

Did it work? Take a note of the "ok" and "changed" values.

Run it again:

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ ansible-playbook web.yml
~~~

How do the "ok" and "changed" values look now?

Explanation: there are two tasks involving the apt module. One updates the cache of available packages (like "apt-get update") and the other ensures that apache2 is installed.

At this point, a webserver should be running on your virtual machine. Test it by pointing your laptop's web browser to vmX-gY.lab.workalaya.net

You should see "Apache2 Ubuntu Default Page"

~~~bash
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ git add .
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ git commit -am "add web.yml file"
~~~

### **4. 1. Documentation** ###

It would be helpful if the playbook could be self-documenting, so edit web.yml so it now looks like this:

~~~yaml
- hosts:
    - vmX-gY.lab.workalaya.net
  become: true
  tasks:
    - name: ensure package cache is up to date
      action: apt update_cache=yes cache_valid_time=3600
    - name: install web server
      action: apt pkg=apache2 state=present
~~~

Run it again. You should get more helpful TASK descriptions as it runs.

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ ansible-playbook web.yml

PLAY [vmX-gY.lab.workalaya.net] ************************************************

TASK [Gathering Facts] *********************************************************
ok: [vmX-gY.lab.workalaya.net]

TASK [ensure package cache is up to date] **************************************
[WARNING]: Could not find aptitude. Using apt-get instead

ok: [vmX-gY.lab.workalaya.net]

TASK [install web server] ******************************************************
ok: [vmX-gY.lab.workalaya.net]

PLAY RECAP *********************************************************************
vmX-gY.lab.workalaya.net   : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
~~~

### **4. 2. Alternate syntax** ###

As a shortcut, instead of writing

~~~yaml
action: foo ....
~~~

you can write

~~~yaml
foo: ....
~~~

This means you can slightly simplify that playbook to:

~~~yaml
- hosts:
    - vmX-gY.lab.workalaya.net
  become: true
  tasks:
    - name: ensure package cache is up to date
      apt: update_cache=yes cache_valid_time=3600
    - name: install web server
      apt: pkg=apache2 state=present
~~~

Which form you prefer is just a personal choice.

From this point on, learning ansible is really just a case of getting to know the different modules that are available.

### **4. 3. Copying a file** ###

Let's say we want to replace that Ubuntu default web page with our own.

Still in your sysadm home directory, create a file `front.html` with some HTML text, e.g.

~~~html
<html>
  <head>
    <title>Hello world</title>
  </head>
  <body>
    This is the page I installed
  </body>
</html>
~~~

Now add a new task to our playbook:

~~~yaml
- hosts:
    - vmX-gY.lab.workalaya.net
  become: true
  tasks:
    - name: ensure package cache is up to date
      apt: update_cache=yes cache_valid_time=3600
    - name: install web server
      apt: pkg=apache2 state=present
    - name: install index page
      copy: src=front.html dest=/var/www/html/index.html backup=yes
~~~

After this has run successfully (check for "changed=1"), point your laptop's web browser at your vm and check you have a new index page.

What about if we wanted to keep the original file? That is what `backup=yes` is for. If you log in to one of those hosts and look at the contents of that directory, you'll see that the original file is still there but renamed to a name containing its timestamp.

~~~bash
lab@vmX-gY:~$ ls /var/www/html/
index.html  index.html.379.2019-10-31@11:07:28~
~~~

~~~bash
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ git add .
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ git commit -am "add front.html and updated web.yml"
~~~

### **4. 4. Check and diff** ###

Suppose you want to know what changes ansible will make, before it makes them? Two flags are provided for this.

* `--check` will tell you which changes would be made, without actually making them. (Not all modules support this)
* `--diff` shows you the differences between the old and new files

It is common to use both flags. Try changing the text in front.html, and then running this command:

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ ansible-playbook web.yml --check --diff
~~~

It should identify that index.html is going to be updated, and show you the differences.

Run it again _without_ the `--check` flag and then it will actually apply the change.

### **4. 5. Handlers** ###

Sometimes when you make a configuration change it's necessary to restart the service. Ansible supports this though "handlers".

Imagine that whenever the index.html page changes you need to restart apache (although that's not actually true). You add a "notify:" statement to every action which needs the restart, and a "handler:" which performs the restart.

~~~yaml
- hosts:
    - vmX-gY.lab.workalaya.net
  become: true
  tasks:
    - name: ensure package cache is up to date
      apt: update_cache=yes cache_valid_time=3600
    - name: install web server
      apt: pkg=apache2 state=present
    - name: install index page
      copy: src=front.html dest=/var/www/html/index.html backup=yes
      notify: restart apache2
  handlers:
    - name: restart apache2
      service: name=apache2 state=restarted
~~~

Run your playbook again, firstly without changing front.html, and then after changing front.html.

In the latter case you should see

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ ansible-playbook web.yml

PLAY [vmX-gY.lab.workalaya.net] ************************************************

TASK [Gathering Facts] *********************************************************
ok: [vmX-gY.lab.workalaya.net]

TASK [ensure package cache is up to date] **************************************
[WARNING]: Could not find aptitude. Using apt-get instead

ok: [vmX-gY.lab.workalaya.net]

TASK [install web server] ******************************************************
ok: [vmX-gY.lab.workalaya.net]

TASK [install index page] ******************************************************
changed: [vmX-gY.lab.workalaya.net]

RUNNING HANDLER [restart apache2] **********************************************
changed: [vmX-gY.lab.workalaya.net]

PLAY RECAP *********************************************************************
vmX-gY.lab.workalaya.net   : ok=5    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
~~~

which shows that the handler was triggered.

~~~bash
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ git add .
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ git commit -am "add handler feature"
~~~

### **4. 6. Tags** ###

As your playbook gets bigger, it may get slower to run, and you may wish to run only part of a playbook to bypass the earlier steps. The way to do this is using 'tags'. Example:

~~~yaml
- hosts:
    - vmX-gY.lab.workalaya.net
  become: true
  tasks:
    - name: ensure package cache is up to date
      apt: update_cache=yes cache_valid_time=3600
      tags: install
    - name: install web server
      apt: pkg=apache2 state=present
      tags: install
    - name: install index page
      copy: src=front.html dest=/var/www/html/index.html backup=yes
      tags: configure
      notify: restart apache2
  handlers:
    - name: restart apache2
      service: name=apache2 state=restarted
~~~

Now try:

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ ansible-playbook web.yml -t configure

PLAY [vmX-gY.lab.workalaya.net] ************************************************

TASK [Gathering Facts] *********************************************************
ok: [vmX-gY.lab.workalaya.net]

TASK [install index page] ******************************************************
ok: [vmX-gY.lab.workalaya.net]

PLAY RECAP *********************************************************************
vmX-gY.lab.workalaya.net   : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
~~~

and it will run only the task which has been tagged as "configure". When writing a playbook, you can assign whatever tags make sense to you.

~~~bash
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ git add .
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ git commit -am "added tags feature on web.yml"
~~~

### **4. 7. Limit to specific hosts** ###

You can also tell the playbook to run against only a single host or a subset of hosts. The way to do this is with the '-l' (limit) option.

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ ansible-playbook web.yml -l vmX-gY.lab.workalaya.net
~~~

This is particularly useful for testing and staged rollout; but note that the `-l` flag is only a filter against the hosts already listed in the playbook. It cannot cause the playbook to run against other hosts.

For example:

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ ansible-playbook web.yml -l 'vm1-g1.lab.workalaya.net;vm1-g2.lab.workalaya.net'
~~~

will only run those tasks which were already defined to run on your playbook.

### **4. 8. Adding more "plays"** ###

A "play" is one group of hosts and tasks, and a playbook can contain multiple instances of these.

Let's say that in your web application cluster you need another host which is a mysql server. You can include this in the same playbook by adding another play. Add a new section to the end of your web.yml file so that it looks like this:

~~~yaml
- hosts:
    - vmX-gY.lab.workalaya.net
  become: true
  tasks:
    - name: ensure package cache is up to date
      apt: update_cache=yes cache_valid_time=3600
      tags: install
    - name: install web server
      apt: pkg=apache2 state=present
      tags: install
    - name: install index page
      copy: src=front.html dest=/var/www/html/index.html backup=yes
      tags: configure
      notify: restart apache2
  handlers:
    - name: restart apache2
      service: name=apache2 state=restarted

- hosts:
    - vmX-gY.lab.workalaya.net
  become: true
  tasks:
    - name: install mysql server
      apt: pkg=mysql-server state=present
~~~

Run this playbook to confirm that it does what you expect.

~~~bash
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ git add .
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ git commit -am "added more plays on web.yml"
~~~

### **4. 9. Host groups** ###

Finally, a way to make your playbook easier to maintain is to make use of host groups in the inventory.

Edit your inventory file (`/home/vmX-gY/ansible-playbook/inventory/hosts`). Divide it into groups by adding group headings surrounded by square brackets, so that it looks like this:

~~~ini
[app_web]
vm1-gY.lab.workalaya.net ansible_ssh_user=lab ansible_become_pass=lab
vm2-gY.lab.workalaya.net ansible_ssh_user=lab ansible_become_pass=lab
vm3-gY.lab.workalaya.net ansible_ssh_user=lab ansible_become_pass=lab

[app_db]
vmX-gY.lab.workalaya.net ansible_ssh_user=lab ansible_become_pass=lab
~~~

Then you can simplify your playbook by listing the groups instead of the individual hosts:

~~~yaml
- hosts:
    - app_web
  tasks:
    ... as before

- hosts:
    - app_db
  tasks:
    ... as before
~~~

Now test that everything still works:

~~~bash
ansible-playbook web.yml
~~~

You can also use groups on the command line, e.g.

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ ansible app_web -m shell -a 'ls /'
~~~

### **4. 10. Playbook storage** ###

Your `web.yml` file now documents exactly how you built your web servers, and can be used to create additional servers, or rebuild a server if its disk dies.

This means that it's a valuable asset. You should store it somewhere safe, e.g. in a version control system like subversion or git, or in a backed-up file server.

We have been using git for this purpose and also created GitHub repository for remote storage.

From now on after successful ansible playbook run, please, commit changes done to git and push it to remote repository as well like

~~~bash
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ git add .
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ git commit -am "<meaningful commit message>"
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ git push -u origin master
~~~

---

## **5. Conclusion** ##

* A playbook is a list of "hosts" and "tasks" to apply to those hosts, and optionally "handlers" which are tasks run only when notified by another task
* A playbook encapsulates all the logic needed to build and configure a system

---
