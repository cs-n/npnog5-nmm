# **Nagios Installation and Configuration**

## **Introduction**

### **Goals**

- Install and configure Nagios

### **Notes**

- Commands preceded with "$" imply that you should execute the command as a general user - not as root.
- Commands preceded with "#" imply that you should be working as root.
- Commands with more specific command lines (e.g. "rtrX>" or "mysql>") imply that you are executing commands on remote equipment, or within another program.
- If a command line ends with "\\" this indicates that the command continues on the next line and you should treat this as a single line.
- References to "N" represent your group number.

---

## **Exercises**

## **Part I**

**Log in to your shared workstation virtual machine as "vmXgY" user.** (Replace X with vm no and Y with group no)

Nagios Installation has already been done. You may skip the installation part

### **Install Nagios Version 3 using Ansible**

Now we create new ansible-playbook file named **_nagios.yml_**

~~~yaml
- hosts: nagios_hosts
  become: true
  tasks:
    - name: ensure package cache is up to date
      apt: update_cache=yes cache_valid_time=3600
      tags: install

    - name: install Nagios Version 3
      package:
        name: "{{ item }}"
        state: present
      with_items:
        - nagios3
        - nagios3-doc
      tags: install

    - name: Check nagios Users
      stat:
        path: /etc/nagios3/htpasswd.users
      ignore_errors: true
      register: nagios_user_pwfile_exists
      tags: configure

    - name: Create empty password file
      command: touch /etc/nagios3/htpasswd.users
      args:
        creates: /etc/nagios3/htpasswd.users
      when: not nagios_user_pwfile_exists
      tags: configure

    - name: Create nagios admin user
      htpasswd:
        path: /etc/nagios3/htpasswd.users
        name: nagiosadmin
        password: "{{ class_password }}"
        state: present
      ignore_errors: true
      tags: configure
~~~

Create new YAML file named **_all.yml_** inside **_inventory/group_vars/_** and define variable name _class_password_

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ mkdir inventory/group_vars
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi inventory/group_vars/all.yml

ansible_ssh_user=lab
ansible_become_pass=lab

class_password: lab
class_group: Y
~~~

update inventory/hosts as following

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi inventory/hosts
~~~

~~~txt
[nagios_hosts]
vmX-gY.lab.workalaya.net
~~~

Now run ansible playbook to install nagios version 3

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ ansible-playbook nagios.yml

PLAY [vmX-gY.lab.workalaya.net] ************************************************

TASK [Gathering Facts] *********************************************************
ok: [vmX-gY.lab.workalaya.net]

TASK [ensure package cache is up to date] **************************************
[WARNING]: Could not find aptitude. Using apt-get instead

ok: [vmX-gY.lab.workalaya.net]

TASK [install Nagios Version 3] ************************************************
changed: [vmX-gY.lab.workalaya.net] => (item=nagios3)
changed: [vmX-gY.lab.workalaya.net] => (item=nagios3-doc)

TASK [Set htpasswd for nagiosadmin] ********************************************
changed: [vmX-gY.lab.workalaya.net]

PLAY RECAP *********************************************************************
vmX-gY.lab.workalaya.net   : ok=4    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
~~~

### **See Initial Nagios Configuration**

Open a browser, and go to your machine like this:

~~~txt
http://vmX-gY.lab.workalaya.net/nagios3/
~~~

At the login prompt, login as:

~~~txt
User Name: nagiosadmin
Password:  <CLASS PASSWORD>
~~~

Click on the "Hosts" link on the left of the initial Nagios page to see what has already been configured.

Click on the "Services" link to see what local services are being monitored.

### **Monitoring Routers, PCs and Switches**

We will create two files, routers.cfg and vms.cfg and make entries for the devices in your group. If you want, you can simply create a single file for all items - Nagios will read any file named *.cfg and sort out the details on its own.

#### **Creating the "routers.cfg" template file**

If you want some help to understand what your group network looks like take a look at the detailed network diagram for group1 linked on the main page for your workshop.

For each group you will end up monitoring each item in your group, this includes:

##### **Routers**

- rtr1-gY.lab.workalaya.net
- gw-rtr.lab.workalaya.net

##### **VMs**

- vm1-gY.lab.workalaya.net
- vm2-gY.lab.workalaya.net
- vm3-gY.lab.workalaya.net
- srv1-g{{class_group}}.lab.workalaya.net

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ mkdir -p templates/nagios
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi templates/nagios/routers.cfg
~~~

**NOTE:** Y is the number of your group (1, 2, 3, 4, 5, or 6)

~~~nagios
define host {
    use         generic-host
    host_name   gw-rtr
    alias       LAB Transit Provider Router
    address     gw-rtr.lab.workalaya.net
}

define host {
    use         generic-host
    host_name   rtr1-g{{class_group}}
    alias       Group {{class_group}}  Router
    address     rtr1-g{{class_group}}.lab.workalaya.net
}
~~~

Now save the file and exit the editor.

update ansible-playbook named **_nagios.yml_** to Generate the nagios monitoring templates to nagios host

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi naigos.yml
~~~

~~~yml
- hosts: nagios_hosts
  become: true
  tasks:
    - name: ensure package cache is up to date
      apt: update_cache=yes cache_valid_time=3600
      tags: install

    - name: install Nagios Version 3
      package:
        name: "{{ item }}"
        state: present
      with_items:
        - nagios3
        - nagios3-doc
      tags: install

    - name: Check nagios Users
      stat:
        path: /etc/nagios3/htpasswd.users
      ignore_errors: true
      register: nagios_user_pwfile_exists
      tags: configure

    - name: Create empty password file
      command: touch /etc/nagios3/htpasswd.users
      args:
        creates: /etc/nagios3/htpasswd.users
      when: not nagios_user_pwfile_exists
      tags: configure

    - name: Create nagios admin user
      htpasswd:
        path: /etc/nagios3/htpasswd.users
        name: nagiosadmin
        password: "{{ class_password }}"
        state: present
      ignore_errors: true
      tags: configure

    - name: Generate the nagios monitoring templates
      template:
        src: ./templates/nagios/{{ item }}
        dest: /etc/nagios3/conf.d
        backup: yes
      with_items:
        - routers.cfg
      tags: update_config
      notify: verify config

  handlers:
    - name: verify config
      shell: nagios3 -v /etc/nagios3/nagios.cfg
      notify: restart nagios3

    - name: restart nagios3
      service: name=nagios3 state=restarted
~~~

Now run ansible playbook to update changes

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ ansible-playbook nagios.yml -t update_config

PLAY [vmX-gY.lab.workalaya.net] ************************************************

TASK [Gathering Facts] *********************************************************
ok: [vmX-gY.lab.workalaya.net]

TASK [Generate the nagios monitoring templates] ********************************
changed: [vmX-gY.lab.workalaya.com] => (item=routers.cfg)

RUNNING HANDLER [verify config] ************************************************
changed: [vmX-gY.lab.workalaya.net]

RUNNING HANDLER [restart nagios3] **********************************************
changed: [vmX-gY.lab.workalaya.net]

PLAY RECAP *********************************************************************
vmX-gY.lab.workalaya.net   : ok=4    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
~~~

And, in a web browser view:

~~~txt
http://vmX-gY.lab.workalaya.net/nagios3/
~~~

and click on hosts. You should now see your routers listed. They may still be waiting to be checked. Eventually they should turn green once Nagios runs a check.

### **Creating the vms.cfg template file**

Now we create entries for the 3 vms (vm1-gY through vm3-gY) and the group shared server (srv1-g{{class_group}}).

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi templates/nagios/vms.cfg
~~~

For each group place this entry at the top of the vms.cfg file (replace "Y" with your group number):

~~~nagios
define host {
    use         generic-host
    host_name   srv1-g{{class_group}}
    alias       Server, Group {{class_group}}
    address     srv1-g{{class_group}}.lab.workalaya.net
}

{% for i in range(1,4) %}
define host {
    use         generic-host
    host_name   vm{{i}}-g{{class_group}}
    alias       VM 1, Group {{class_group}}
    address     vm{{i}}-g{{class_group}}.lab.workalaya.net
}
{% endfor %}
~~~

update ansible-playbook named **_nagios.yml_** to include **_vms.cfg_** template file to nagios monitoring

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi naigos.yml
~~~

~~~yml
- hosts: nagios_hosts
  become: true
  tasks:
    - name: ensure package cache is up to date
      apt: update_cache=yes cache_valid_time=3600
      tags: install

    - name: install Nagios Version 3
      package:
        name: "{{ item }}"
        state: present
      with_items:
        - nagios3
        - nagios3-doc
      tags: install

    - name: Check nagios Users
      stat:
        path: /etc/nagios3/htpasswd.users
      ignore_errors: true
      register: nagios_user_pwfile_exists
      tags: configure

    - name: Create empty password file
      command: touch /etc/nagios3/htpasswd.users
      args:
        creates: /etc/nagios3/htpasswd.users
      when: not nagios_user_pwfile_exists
      tags: configure

    - name: Create nagios admin user
      htpasswd:
        path: /etc/nagios3/htpasswd.users
        name: nagiosadmin
        password: "{{ class_password }}"
        state: present
      ignore_errors: true
      tags: configure

    - name: Generate the nagios monitoring templates
      template:
        src: ./templates/nagios/{{ item }}
        dest: /etc/nagios3/conf.d
        backup: yes
      with_items:
        - routers.cfg
        - vms.cfg
      tags: update_config
      notify: verify config

  handlers:
    - name: verify config
      shell: nagios3 -v /etc/nagios3/nagios.cfg
      notify: restart nagios3

    - name: restart nagios3
      service: name=nagios3 state=restarted
~~~

Now run ansible playbook to update changes

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ ansible-playbook nagios.yml -t update_config

PLAY [vmX-gY.lab.workalaya.net] ************************************************

TASK [Gathering Facts] *********************************************************
ok: [vmX-gY.lab.workalaya.net]

TASK [Generate the nagios monitoring templates] ********************************
ok: [vmX-gY.lab.workalaya.com] => (item=routers.cfg)
changed: [vmX-gY.lab.workalaya.com] => (item=vms.cfg)

RUNNING HANDLER [verify config] ************************************************
changed: [vmX-gY.lab.workalaya.net]

RUNNING HANDLER [restart nagios3] **********************************************
changed: [vmX-gY.lab.workalaya.net]

vmX-gY.lab.workalaya.com   : ok=4    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
~~~

And, in a web browser view:

~~~txt
http://vmX-gY.lab.workalaya.net/nagios3/
~~~

and click on hosts. You should now see your routers listed. They may still be waiting to be checked. Eventually they should turn green once Nagios runs a check.

---

## **Part II**

### **Create More Host Groups**

**Preparation**
In the web view, look at the pages "Hostgroups", "Hostgroup Summary", "Hostgroup Grid". This gives a convenient way to group together hosts which are related (e.g. in the same site, serving the same purpose).

Update **_templates/nagios/routers.cfg_** as

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi templates/nagios/routers.cfg
~~~

~~~txt
define hostgroup {
    hostgroup_name routers
    alias          Router Group
}

define host {
    use         generic-host
    host_name   gw-rtr
    alias       LAB Transit Provider Router
    address     gw-rtr.lab.workalaya.net
}

define host {
    use         generic-host
    host_name   rtr1-g{{class_group}}
    alias       Group {{class_group}}  Router
    address     rtr1-g{{class_group}}.lab.workalaya.net
}
~~~

and Update **_templates/nagios/vms.cfg_** as

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi templates/nagios/vmss.cfg
~~~

~~~txt
define hostgroup {
    hostgroup_name vms
    alias          VM Group
}

define host {
    use         generic-host
    host_name   srv1-g{{class_group}}
    alias       Server, Group {{class_group}}
    address     srv1-g{{class_group}}.lab.workalaya.net
    hostgroups  vms
}

{% for i in range(1,4) %}
define host {
    use         generic-host
    host_name   vm{{i}}-g{{class_group}}
    alias       VM {{i}}, Group {{class_group}}
    address     vm{{i}}-g{{class_group}}.lab.workalaya.net
    hostgroups  vms
}
{% endfor %}
~~~

and push config to nagios host

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ ansible-playbook nagios.yml -t update_config

PLAY [nagios_hosts] ************************************************************

TASK [Gathering Facts] *********************************************************
ok: [vmX-gY.lab.workalaya.com]

TASK [Generate the nagios monitoring templates] ********************************
changed: [vmX-gY.lab.workalaya.com] => (item=routers.cfg)
changed: [vmX-gY.lab.workalaya.com] => (item=vms.cfg)

RUNNING HANDLER [verify config] ************************************************
changed: [vmX-gY.lab.workalaya.com]

RUNNING HANDLER [restart nagios3] **********************************************
changed: [vmX-gY.lab.workalaya.com]

PLAY RECAP *********************************************************************
vmX-gY.lab.workalaya.com   : ok=4    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
~~~

---

## **PART III**

### **Defining Services for all Servers and routers**

**Determine what services to define for what devices**
To start we are simply using ping to verify that our servers and network devices are responding or "Up".

Now let's add monitoring of services for our various servers and network devices:

In this class we, so far, have:

routers: running ssh and ntp
VMs: All VMs are running ssh and http and will be running snmp (including srv1)
The classroom NOC is currently running an snmp daemon we can monitor if you wish.

**Verify that SSH is running on the routers and VMs and HTTP is running on the VMs**
Update **_templates/nagios/routers.cfg_** as

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi templates/nagios/routers.cfg
~~~

~~~txt
define hostgroup {
    hostgroup_name routers
    alias          Router Group
}

define host {
    use         generic-host
    host_name   gw-rtr
    alias       LAB Transit Provider Router
    address     gw-rtr.lab.workalaya.net
    hostgroups   routers,ssh-servers
}

define host {
    use         generic-host
    host_name   rtr1-g{{class_group}}
    alias       Group {{class_group}}  Router
    address     rtr1-g{{class_group}}.lab.workalaya.net
    hostgroups routers,ssh-servers
}
~~~

and Update **_templates/nagios/vms.cfg_** as

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi templates/nagios/vmss.cfg
~~~

~~~txt
define hostgroup {
    hostgroup_name vms
    alias          VM Group
}

define host {
    use         generic-host
    host_name   srv1-g{{class_group}}
    alias       Server, Group {{class_group}}
    address     srv1-g{{class_group}}.lab.workalaya.net
    hostgroups  vms,ssh-servers,http-servers,ubuntu-servers
}

{% for i in range(1,4) %}
define host {
    use         generic-host
    host_name   vm{{i}}-g{{class_group}}
    alias       VM {{i}}, Group {{class_group}}
    address     vm{{i}}-g{{class_group}}.lab.workalaya.net
    hostgroups  vms,ssh-servers,http-servers,ubuntu-servers
}
{% endfor %}
~~~

and push config to nagios host

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ ansible-playbook nagios.yml -t update_config

PLAY [nagios_hosts] ************************************************************

TASK [Gathering Facts] *********************************************************
ok: [vmX-gY.lab.workalaya.com]

TASK [Generate the nagios monitoring templates] ********************************
changed: [vmX-gY.lab.workalaya.com] => (item=routers.cfg)
changed: [vmX-gY.lab.workalaya.com] => (item=vms.cfg)

RUNNING HANDLER [verify config] ************************************************
changed: [vmX-gY.lab.workalaya.com]

RUNNING HANDLER [restart nagios3] **********************************************
changed: [vmX-gY.lab.workalaya.com]

PLAY RECAP *********************************************************************
vmX-gY.lab.workalaya.com   : ok=4    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
~~~

---
