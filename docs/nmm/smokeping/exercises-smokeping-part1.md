# **Network Management & Monitoring - Smokeping**

## **Introduction**

### **Goals**

- Install and configure Smokeping

### **Notes**

- Commands preceded with "$" imply that you should execute the command as a general user - not as root.
- Commands preceded with "#" imply that you should be working as root.
- Commands with more specific command lines (e.g. "rtrX>" or "mysql>") imply that you are executing commands on remote equipment, or within another program.
- If a command line ends with "\\" this indicates that the command continues on the next line and you should treat this as a single line.
- References to "Y" represent your group number.

---

## **Exercise - Part I**

In this exercise you will install Smokeping and get it to monitor various devices in the class network.

**Log in to your shared workstation virtual machine as "vmXgY" user.** (Replace X with vm no and Y with group no)

Now we create new ansible-playbook file named **_smokeping.yml_**

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi smokeping.yml
~~~

~~~yaml
- hosts: smokeping_hosts
  become: true
  tasks:
    - name: ensure package cache is up to date
      apt: update_cache=yes cache_valid_time=3600
      tags: install

    - name: install smokeping and dependencies
      package:
        name: "{{ item }}"
        state: present
      with_items:
        - smokeping
        - fping
      tags: install

    - name: set fping setuid
      file:
        path: /usr/bin/fping
        owner: root
        group: root
        mode: 04755
      tags: install

    - name: enable apache cgi
      apache2_module:
        name: cgi
        state: present
      tags: install
      notify: restart apache

  handlers:
    - name: restart apache
      service:
        name: apache2
        state: restarted
~~~

update inventory/hosts as following

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi inventory/hosts
~~~

~~~txt
[nagios_hosts]
vmX-gY.lab.workalaya.net

[snmp_hosts]
vmX-gY.lab.workalaya.net

[smokeping_hosts]
vmX-gY.lab.workalaya.net
~~~

Now run ansible playbook to install _Smokeping_

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ ansible-playbook smokeping.yml

PLAY [smokeping_hosts] ****************************************************************************************

TASK [Gathering Facts] ****************************************************************************************
ok: [vmX-gY.lab.workalaya.com]

TASK [ensure package cache is up to date] *********************************************************************
[WARNING]: Could not find aptitude. Using apt-get instead

changed: [vmX-gY.lab.workalaya.com]

TASK [install smokeping and dependencies] *********************************************************************
changed: [vmX-gY.lab.workalaya.com] => (item=smokeping)
ok: [vmX-gY.lab.workalaya.com] => (item=fping)

TASK [set fping setuid] ***************************************************************************************
changed: [vmX-gY.lab.workalaya.com]

TASK [enable apache cgi] **************************************************************************************
ok: [vmX-gY.lab.workalaya.com]

PLAY RECAP ****************************************************************************************************
vmX-gY.lab.workalaya.com   : ok=5    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
~~~

Then point your web browser at

~~~url
http://vmX-gY.lab.workalaya.net/smokeping/smokeping.cgi
~~~

Now login to your VM and take note of smokeping config files so that we can update our ansible playbook to configure smokeping and monitor hosts.

~~~bash
root@vmX-gY:~# cd /etc/smokeping/config.d/
root@vmX-gY:/etc/smokeping/config.d# ls -al
total 40
drwxr-xr-x 2 root root 4096 Nov  6 07:02 .
drwxr-xr-x 3 root root 4096 Nov  6 07:02 ..
-rw-r--r-- 1 root root  177 Nov 28  2017 Alerts
-rw-r--r-- 1 root root  237 Nov 28  2017 Database
-rw-r--r-- 1 root root  489 Nov 28  2017 General
-rw-r--r-- 1 root root  876 Nov 28  2017 Presentation
-rw-r--r-- 1 root root   50 Nov 28  2017 Probes
-rw-r--r-- 1 root root  147 Nov 28  2017 Slaves
-rw-r--r-- 1 root root  380 Nov 28  2017 Targets
-rw-r--r-- 1 root root  259 Nov 28  2017 pathnames
root@vmX-gY:/etc/smokeping/config.d#
~~~

The files that you'll need to change, at a minimum, are:

- Alerts
- General
- Probes (to be done later)
- Targets

Now create template file for _General_ as

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ mkdir -p templates/smokeping
(venv) vmX-gY@ansible-host:~/ansible-playbook$ mkdir -p files/smokeping

(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi files/smokeping/General
~~~

Put the following contents in the file:

~~~txt
*** General ***

owner    = NOC
contact  = lab@localhost
mailhost = localhost
cgiurl   = http://localhost/smokeping/smokeping.cgi
# specify this to get syslog logging
syslogfacility = local5
# each probe is now run in its own process
# disable this to revert to the old behaviour
# concurrentprobes = no

@include /etc/smokeping/config.d/pathnames
~~~

Then, create template file for _Alerts_

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi files/smokeping/Alerts
~~~

Put the following contents in the file:

~~~txt
*** Alerts ***
to = lab@localhost
from = smokeping-alert@localhost

+someloss
type = loss
# in percent
pattern = >0%,*12*,>0%,*12*,>0%
comment = loss 3 times  in a row
~~~

Update ansible playbook named **_smokeping.yml_** to make changes to our smokeping configuration

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi smokeping.yml
~~~

~~~yaml
- hosts: smokeping_hosts
  become: true
  tasks:
    - name: ensure package cache is up to date
      apt: update_cache=yes cache_valid_time=3600
      tags: install

    - name: install smokeping and dependencies
      package:
        name: "{{ item }}"
        state: present
      with_items:
        - smokeping
        - fping
      tags: install

    - name: set fping setuid
      file:
        path: /usr/bin/fping
        owner: root
        group: root
        mode: 04755
      tags: install

    - name: enable apache cgi
      apache2_module:
        name: cgi
        state: present
      tags: install
      notify: restart apache

    - name: Smokeping General config
      copy:
        src: files/smokeping/{{ item }}
        dest: /etc/smokeping/config.d
        backup: yes
      with_items:
        - General
        - Alerts
      tags: base_config
      notify: restart smokeping

  handlers:
    - name: restart apache
      service:
        name: apache2
        state: restarted

    - name: restart smokeping
      service:
        name: smokeping
        state: restarted
~~~

Now run ansible playbook to update _Smokeping_ congiguration

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ ansible-playbook smokeping.yml -t base_config

PLAY [smokeping_hosts] ****************************************************************************************

TASK [Gathering Facts] ****************************************************************************************
ok: [vmX-gY.lab.workalaya.com]

TASK [Smokeping General config] *******************************************************************************
changed: [vmX-gY.lab.workalaya.com] => (item=General)
changed: [vmX-gY.lab.workalaya.com] => (item=Alerts)

RUNNING HANDLER [restart smokeping] ***************************************************************************
changed: [vmX-gY.lab.workalaya.com]

PLAY RECAP ****************************************************************************************************
vmX-gY.lab.workalaya.com   : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
~~~

## **Configure monitoring of devices**

The majority of your time and work configuring Smokeping will be done in the file /etc/smokeping/config.d/Targets.

For this class please do the following:

Use the default FPing probe to check:

- Hosts in your campus
- classroom NOC
- routers

You can use the classroom Network Diagram on the classroom wiki to figure out addresses for each item, etc.

Create some hierarchy to the Smokeping menu for your checks.

For this we will create new template file named _Targets_ inside _templates/smokeping/_ as

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi templates/smokeping/Targets
~~~

Put the following contents in the file:

~~~txt
*** Targets ***

probe = FPing

menu = Top
title = Network Latency Grapher
remark = Smokeping Latency Grapher for Network Monitoring \
         and Management Workshop.

+Local

menu = Local
title = Local Network

++LocalMachine

menu = Local Machine
title = This host
host = localhost

#
# ********* Classroom Servers **********
#

+NOCServers

menu = NOCServers
title = Network Management Servers

++noc

menu = noc
title = Workshop NOC
host = noc.lab.workalaya.net

#
# ******** Group {{class_group}} Hosts ***********
#

+Group{{class_group}}

menu = Group {{class_group}} Hosts
title = Hosts in Group {{class_group}}

++srv1

menu = srv1
title = Group {{class_group}} Shared Server 1
host = srv1-g{{class_group}}.lab.workalaya.net

{% for host in range(1,4) %}
++vm{{host}}

menu = vm{{host}}
title = Group {{class_group}} Server 1
host = vm1-g{{class_group}}.lab.workalaya.net

{% endfor %}
~~~

Update ansible playbook named **_smokeping.yml_** to make changes to our smokeping

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi smokeping.yml
~~~

~~~yaml
- hosts: smokeping_hosts
  become: true
  tasks:
    - name: ensure package cache is up to date
      apt: update_cache=yes cache_valid_time=3600
      tags: install

    - name: install smokeping and dependencies
      package:
        name: "{{ item }}"
        state: present
      with_items:
        - smokeping
        - fping
      tags: install

    - name: set fping setuid
      file:
        path: /usr/bin/fping
        owner: root
        group: root
        mode: 04755
      tags: install

    - name: enable apache cgi
      apache2_module:
        name: cgi
        state: present
      tags: install
      notify: restart apache

    - name: Smokeping General config
      copy:
        src: files/smokeping/{{ item }}
        dest: /etc/smokeping/config.d
        backup: yes
      with_items:
        - General
        - Alerts
      tags: base_config
      notify: restart smokeping

    - name: Smokeping Monitoring Target config
      template:
        src: templates/smokeping/{{ item }}
        dest: /etc/smokeping/config.d
        backup: yes
      with_items:
        - Targets
      tags: target_config
      notify: restart smokeping

  handlers:
    - name: restart apache
      service:
        name: apache2
        state: restarted

    - name: restart smokeping
      service:
        name: smokeping
        state: restarted
~~~

Now run ansible playbook to update _Smokeping_ congiguration

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ ansible-playbook smokeping.yml -t target_config

PLAY [smokeping_hosts] ****************************************************************************************

TASK [Gathering Facts] ****************************************************************************************
ok: [vmX-gY.lab.workalaya.com]

TASK [Smokeping Monitoring Target config] *********************************************************************
changed: [vmX-gY.lab.workalaya.com] => (item=Targets)

RUNNING HANDLER [restart smokeping] ***************************************************************************
changed: [vmX-gY.lab.workalaya.com]

PLAY RECAP ****************************************************************************************************
vmX-gY.lab.workalaya.com   : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
~~~

If you see error messages, then read them closely and try to correct the problem in the Targets file.

In addition, Smokeping is now sending log message to the file /var/log/syslog. Now login to your VM and You can view what Smokeping is saying by typing:

~~~bash
root@vmX-gY:~# tail -F /var/log/syslog
~~~

If you want to see all smokeping related messages in the file /var/log/syslog you can do this:

~~~bash
root@vmX-gY:~# grep smokeping /var/log/syslog
~~~

If there are no errors you can view the results of your changes by going to:

~~~url
http://vmX-gY.lab.workalaya.net/smokeping/smokeping.cgi
~~~

### **Configure monitoring of routers and switches**

Once you have configured the hosts on your campus, then it's time to add the entries for the routers and switches in your workshop group network.

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi templates/smokeping/Targets
~~~

Go to the bottom of the file and add in entries for your workshop group routers:

~~~txt
#
#******** Group {{class_group}} Network Devices ********
#

+Group{{class_group}}Network

menu = Group {{class_group}} Network Devices
title = Network Devices - Group {{class_group}}

#
# ********** Group {{class_group}} Border Router *********
#

++border
menu = Border
title = Border Router

+++Group{{class_group}}
menu = Group{{class_group}}
title = Border Router Group {{class_group}}
host = gw-rtr.lab.workalaya.net

#
# ********** Group {{class_group}} Core Router *********
#

++core
menu = Core
title = Core Router

+++Group{{class_group}}
menu = Group{{class_group}}
title = Core Router Group {{class_group}}
host = rtr1-g{{class_group}}.lab.workalaya.net
~~~

Now run ansible playbook to update _Smokeping_ congiguration

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ ansible-playbook smokeping.yml -t target_config

PLAY [smokeping_hosts] ****************************************************************************************

TASK [Gathering Facts] ****************************************************************************************
ok: [vmX-gY.lab.workalaya.com]

TASK [Smokeping Monitoring Target config] *********************************************************************
changed: [vmX-gY.lab.workalaya.com] => (item=Targets)

RUNNING HANDLER [restart smokeping] ***************************************************************************
changed: [vmX-gY.lab.workalaya.com]

PLAY RECAP ****************************************************************************************************
vmX-gY.lab.workalaya.com   : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
~~~

If there are no errors you can view the results of your changes by going to:

~~~url
http://vmX-gY.lab.workalaya.net/smokeping/smokeping.cgi
~~~

---
