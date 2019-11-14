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

## **Part IV**

### **Adding Parent Relationships**

If you look at the Nagios interface for your server and select Status Maps you will see your group servers and devices centered around your Nagios instance. In order for Nagios to work efficiently you need to include parent relationships for each device defined.

Go to <http://vmX-gY.lab.workalaya.net/nagios3> and click on the "Map" link.

Now we will add parent relationships for router, switch and server.

Adding Parents to **_templates/nagios/routers.cfg_** as

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
    alias       Group {{class_group}} Router
    address     rtr1-g{{class_group}}.lab.workalaya.net
    hostgroups routers,ssh-servers
    parents     gw-rtr
}
~~~

and Adding Parents to **_templates/nagios/vms.cfg_** as

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
    parents     rtr1-g{{class_group}}
}

{% for i in range(1,4) %}
define host {
    use         generic-host
    host_name   vm{{i}}-g{{class_group}}
    alias       VM {{i}}, Group {{class_group}}
    address     vm{{i}}-g{{class_group}}.lab.workalaya.net
    hostgroups  vms,ssh-servers,http-servers,ubuntu-servers
    parents     rtr1-g{{class_group}}
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

## **Part V**

### **Extended Host Information ("making your graphs pretty")**

If you would like to use appropriate icons for your defined hosts in Nagios this is where you do this. We have the two types of devices:

- Cisco routers
- Ubuntu servers vms

There is a fairly large repository of icon images available for you to use located here:

~~~bash
/usr/share/nagios/htdocs/images/logos/
~~~

these were installed by default as dependent packages of the nagios3 package in Ubuntu. In some cases you can find model-specific icons for your hardware, but to make things simpler we will use the following icons for our hardware:

~~~bash
/usr/share/nagios/htodcs/images/logos/base/debian.*
/usr/share/nagios/htdocs/images/logos/cook/router.*
/usr/share/nagios/htdocs/images/logos/cook/switch.*
~~~

The next step is to edit the file **_templates/nagios/vms.cfg_**  and tell nagios what image you would like to use to represent your devices.

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi templates/nagios/routers.cfg
~~~

Here is what an entry for your routers looks like (there is already an entry for debian-servers that will work as is). Note that the router model (3600) is not all that important. The image used represents a router in general.

~~~txt
define hostgroup {
    hostgroup_name routers
    alias          Router Group
}

define hostextinfo {
    hostgroup_name   routers
    icon_image       cook/router.png
    icon_image_alt   Cisco Routers (7200)
    vrml_image       router.png
    statusmap_image  cook/router.gd2
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
    alias       Group {{class_group}} Router
    address     rtr1-g{{class_group}}.lab.workalaya.net
    hostgroups routers,ssh-servers
    parents     gw-rtr
}
~~~

and push config to nagios host

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ ansible-playbook nagios.yml -t update_config

PLAY [nagios_hosts] ************************************************************

TASK [Gathering Facts] *********************************************************
ok: [vmX-gY.lab.workalaya.com]

TASK [Generate the nagios monitoring templates] ********************************
changed: [vmX-gY.lab.workalaya.com] => (item=routers.cfg)
ok: [vmX-gY.lab.workalaya.com] => (item=vms.cfg)

RUNNING HANDLER [verify config] ************************************************
changed: [vmX-gY.lab.workalaya.com]

RUNNING HANDLER [restart nagios3] **********************************************
changed: [vmX-gY.lab.workalaya.com]

PLAY RECAP *********************************************************************
vmX-gY.lab.workalaya.com   : ok=4    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
~~~

Take a look at the Status Map in the web interface (Map link on the left). It should be much nicer, with real icons instead of question marks for most items.

---

## **Part VI**

### **Create Service Groups**

#### **Create service groups for ssh and http for your group servers.**

The idea is to create service groups for your 4 group servers. Servicegroups consider the service defined by the combined services to be down if any of the services in a group are down.

In this case we'll group together ssh and http. In real life you might do msyql, imap, smtp, http and your mta (postfix, mail, exim) if those were services required to deliver a mail interface to your users.

We start by editing the file:

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi templates/nagios/servicegroups.cfg
~~~

For group 1 this service group would look like:

~~~txt
define servicegroup {
    servicegroup_name   group{{class_group}}-ssh-http
    alias               Group {{class_group}} SSH and Web
    members             vm1-g{{class_group}},SSH,vm1-g{{class_group}},HTTP,vm2-g{{class_group}},SSH,vm2-g{{class_group}},HTTP, \
                        vm3-g{{class_group}},SSH,vm3-g{{class_group}},HTTP,srv1-g{{class_group}},SSH,srv1-g{{class_group}},HTTP
}
~~~

We used "\\" to indicate a new line. Without this you will see errors.

Note that "SSH" and "HTTP" need to be uppercase as this is how the service_description is written in the file /etc/nagios3/conf.d/services_nagios2.cfg

update ansible playbook named **_nagios.yml_** to include **_servicegroups.cfg_** as

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi nagios.yml
~~~

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

    - name: Generate the nagios monitoring templates
      template:
        src: ./templates/nagios/{{ item }}
        dest: /etc/nagios3/conf.d
        backup: yes
      with_items:
        - routers.cfg
        - vms.cfg
        - servicegroups.cfg
      tags: update_config
      notify: verify config

  handlers:
    - name: verify config
      shell: nagios3 -v /etc/nagios3/nagios.cfg
      notify: restart nagios3

    - name: restart nagios3
      service: name=nagios3 state=restarted
~~~

Save your changes, verify your work and push changes to Nagios host using ansible.

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ ansible-playbook nagios.yml -t update_config

PLAY [nagios_hosts] ************************************************************

TASK [Gathering Facts] *********************************************************
ok: [vmX-gY.lab.workalaya.com]

TASK [Generate the nagios monitoring templates] ********************************
ok: [vmX-gY.lab.workalaya.com] => (item=routers.cfg)
ok: [vmX-gY.lab.workalaya.com] => (item=vms.cfg)
changed: [vmX-gY.lab.workalaya.com] => (item=servicegroups.cfg)

RUNNING HANDLER [verify config] ************************************************
changed: [vmX-gY.lab.workalaya.com]

RUNNING HANDLER [restart nagios3] **********************************************
changed: [vmX-gY.lab.workalaya.com]

PLAY RECAP *********************************************************************
vmX-gY.lab.workalaya.com   : ok=4    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
~~~

Now if you click on the Service Groups menu item in the Nagios web interface you should see this information grouped together.

---

## **PART VII**

### **Configure Guest Access to the Nagios Web Interface***

You will edit the file /etc/nagios3/cgi.cfg to give read-only guest user access to the Nagios web interface.

By default Nagios is configured to give full r/w access via the Nagios web interface to the user nagiosadmin. You can change the name of this user, add other users, change how you authenticate users, what users have access to what resources and more via the cgi.cfg file.

First, update your **_nagios.yml_** ansible playbook file to create a "_guest_" user and password in the **_htpasswd.users_** file.

You can use any password you want (or none). A password of "guest" is not a bad choice if you plan for this to be a r/o account.

Next, update your **_nagios.yml_** ansible playbook file to update the file "_/etc/nagios3/cgi.cfg_" and tell Nagios to allow the "guest" user some access to information via the web interface.

Edit **_nagios.yml_** ansible playbook file

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi nagios.yml
~~~

Content to **_nagios.yml_** ansible playbook file should look like

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

    - name: Create nagios guest user
      htpasswd:
        path: /etc/nagios3/htpasswd.users
        name: "{{ item.username }}"
        password: "{{ item.password }}"
        state: present
      ignore_errors: true
      with_items:
        - { username: 'guest', password: 'guest' }
      tags: add_guest

    - name: Configure nagios.cgi to allow guest access
      lineinfile:
        dest: "/etc/nagios3/cgi.cfg"
        regexp: "^{{ item.property | regex_escape() }}="
        line: "{{ item.property }}={{ item.value }}"
      with_items:
        - { property: 'authorized_for_system_information', value: 'nagiosadmin,guest' }
        - { property: 'authorized_for_configuration_information', value: 'nagiosadmin,guest' }
        - { property: 'authorized_for_all_services', value: 'nagiosadmin,guest' }
        - { property: 'authorized_for_all_hosts', value: 'nagiosadmin,guest' }
      tags: add_guest
      notify: verify config

    - name: Generate the nagios monitoring templates
      template:
        src: ./templates/nagios/{{ item }}
        dest: /etc/nagios3/conf.d
        backup: yes
      with_items:
        - routers.cfg
        - vms.cfg
        - servicegroups.cfg
      tags: update_config
      notify: verify config

  handlers:
    - name: verify config
      shell: nagios3 -v /etc/nagios3/nagios.cfg
      notify: restart nagios3

    - name: restart nagios3
      service: name=nagios3 state=restarted
~~~

Save your changes, verify your work and push changes to Nagios host using ansible.

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ ansible-playbook nagios.yml -t add_guest

PLAY [nagios_hosts] ************************************************************

TASK [Gathering Facts] *********************************************************
ok: [vmX-gY.lab.workalaya.com]

TASK [Create nagios guest user] ************************************************
changed: [vmX-gY.lab.workalaya.com] => (item={'username': 'guest', 'password': 'guest'})

TASK [Configure nagios.cgi to allow guest access] **********************************
changed: [vmX-gY.lab.workalaya.com] => (item={'property': 'authorized_for_system_information', 'value': 'nagiosadmin,guest'})
changed: [vmX-gY.lab.workalaya.com] => (item={'property': 'authorized_for_configuration_information', 'value': 'nagiosadmin,guest'})
changed: [vmX-gY.lab.workalaya.com] => (item={'property': 'authorized_for_all_services', 'value': 'nagiosadmin,guest'})
changed: [vmX-gY.lab.workalaya.com] => (item={'property': 'authorized_for_all_hosts', 'value': 'nagiosadmin,guest'})

RUNNING HANDLER [verify config] ************************************************
changed: [vmX-gY.lab.workalaya.com]

RUNNING HANDLER [restart nagios3] **********************************************
changed: [vmX-gY.lab.workalaya.com]

PLAY RECAP *********************************************************************
vmX-gY.lab.workalaya.com   : ok=5    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
~~~

To see if you can log in as the "guest" user you will need to clear the cookies in your web browser or open an alternate web browser if you have one. You will not notice any difference in the web interface. The difference is that a number of items that are available via the web interface (forcing a service/host check, scheduling checks, comments, etc.) will not work for the guest user.

---

## **PART VIII**

### **Enable External commands in nagios.cfg**

This change is required in order to allow users to "Acknowledge" problems with hosts and services in the Web interface. The default file permissions are set up in a secure way to prevent the web interface from updating nagios, so you need to make them slightly more permissive.

Next, update your **_nagios.yml_** ansible playbook file to update the file "_/etc/nagios3/nagios.cfg_" and to change directory permissions and to make the changes permanent.

Edit **_nagios.yml_** ansible playbook file

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi nagios.yml
~~~

Content to **_nagios.yml_** ansible playbook file should look like

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

    - name: Create nagios guest user
      htpasswd:
        path: /etc/nagios3/htpasswd.users
        name: "{{ item.username }}"
        password: "{{ item.password }}"
        state: present
      ignore_errors: true
      with_items:
        - { username: 'guest', password: 'guest' }
      tags: add_guest

    - name: Configure nagios.cgi to allow guest access
      lineinfile:
        dest: "/etc/nagios3/cgi.cfg"
        regexp: "^{{ item.property | regex_escape() }}="
        line: "{{ item.property }}={{ item.value }}"
      with_items:
        - { property: 'authorized_for_system_information', value: 'nagiosadmin,guest' }
        - { property: 'authorized_for_configuration_information', value: 'nagiosadmin,guest' }
        - { property: 'authorized_for_all_services', value: 'nagiosadmin,guest' }
        - { property: 'authorized_for_all_hosts', value: 'nagiosadmin,guest' }
      tags: add_guest
      notify: verify config

    - name: Update nagios.cfg to Enable External commands
      lineinfile:
        dest: "/etc/nagios3/nagios.cfg"
        regexp: "^{{ item.property | regex_escape() }}="
        line: "{{ item.property }}={{ item.value }}"
      with_items:
        - { property: 'check_external_commands', value: '1' }
      register: update_directory_permission
      tags: external_command
      notify: verify config

    - name: change directory permissions
      shell: "dpkg-statoverride --update --add {{ item.user }} {{ item.group }} {{ item.permission }} {{ item.dir }}"
      with_items:
        - { user: 'nagios', group: 'www-data', permission: '2710', dir: '/var/lib/nagios3/rw' }
        - { user: 'nagios', group: 'nagios', permission: '751', dir: '/var/lib/nagios3' }
      when: update_directory_permission.changed
      tags: external_command
      notify: restart nagios3

    - name: Generate the nagios monitoring templates
      template:
        src: ./templates/nagios/{{ item }}
        dest: /etc/nagios3/conf.d
        backup: yes
      with_items:
        - routers.cfg
        - vms.cfg
        - servicegroups.cfg
      tags: update_config
      notify: verify config

  handlers:
    - name: verify config
      shell: nagios3 -v /etc/nagios3/nagios.cfg
      notify: restart nagios3

    - name: restart nagios3
      service: name=nagios3 state=restarted
~~~

Save your changes, verify your work and push changes to Nagios host using ansible.

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ ansible-playbook nagios.yml -t external_command

PLAY [nagios_hosts] ************************************************************

TASK [Gathering Facts] *********************************************************
ok: [vmX-gY.lab.workalaya.com]

TASK [Update nagios.cfg to Enable External commands] ***************************
changed: [vmX-gY.lab.workalaya.com] => (item={'property': 'check_external_commands', 'value': '1'})

TASK [change directory permissions] ********************************************
changed: [vmX-gY.lab.workalaya.com] => (item={'user': 'nagios', 'group': 'www-data', 'permission': '2710', 'dir': '/var/lib/nagios3/rw'})
changed: [vmX-gY.lab.workalaya.com] => (item={'user': 'nagios', 'group': 'nagios', 'permission': '751', 'dir': '/var/lib/nagios3'})

RUNNING HANDLER [verify config] ************************************************
changed: [vmX-gY.lab.workalaya.com]

RUNNING HANDLER [restart nagios3] **********************************************
changed: [vmX-gY.lab.workalaya.com]

PLAY RECAP *********************************************************************
vmX-gY.lab.workalaya.com   : ok=5    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
~~~

Once this is done, go to 'Problems' > 'Services (Unhandled)' and find a service in the red (critical) or yellow (warning) state. Click on the service name. Then under "Service commands" click on "Acknowledge this service problem".

The problem should disappear from the list of unhandled problems.

---
