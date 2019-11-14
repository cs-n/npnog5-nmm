# **SNMP Installation and Configuration**

## **Introduction**

### **Goals**

- Install and configure SNMP

### **Notes**

- Commands preceded with "$" imply that you should execute the command as a general user - not as root.
- Commands preceded with "#" imply that you should be working as root.
- Commands with more specific command lines (e.g. "rtrX>" or "mysql>") imply that you are executing commands on remote equipment, or within another program.
- If a command line ends with "\\" this indicates that the command continues on the next line and you should treat this as a single line.
- References to "Y" represent your group number.

---

## **Installing client (manager) tools**

Start by installing the net-snmp tools on your individual host.

**Log in to your shared workstation virtual machine as "vmXgY" user.** (Replace X with vm no and Y with group no)

Now we create new ansible-playbook file named **_snmp.yml_**

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi snmp.yml
~~~

~~~yaml
- hosts: snmp_hosts
  become: true
  tasks:
    - name: ensure package cache is up to date
      apt: update_cache=yes cache_valid_time=3600
      tags: snmp_client

    - name: install snmp tools
      package:
        name: "{{ item }}"
        state: present
      with_items:
        - snmp
        - snmp-mibs-downloader
      tags: snmp_client

    - name: Update /etc/snmp/snmp.conf
      lineinfile:
        dest: "/etc/snmp/snmp.conf"
        regexp: "^mibs :"
        line: "#mibs :"
      tags: snmp_client
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
~~~

Now run ansible playbook to install snmp client tools

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ ansible-playbook snmp.yml

PLAY [snmp_hosts] *********************************************************************************************

TASK [Gathering Facts] ****************************************************************************************
ok: [vmX-gY.lab.workalaya.com]

TASK [ensure package cache is up to date] *********************************************************************
[WARNING]: Could not find aptitude. Using apt-get instead

changed: [vmX-gY.lab.workalaya.com]

TASK [install snmp tools] *************************************************************************************
ok: [vmX-gY.lab.workalaya.com] => (item=snmp)
changed: [vmX-gY.lab.workalaya.com] => (item=snmp-mibs-downloader)

TASK [Update /etc/snmp/snmp.conf] *****************************************************************************
changed: [vmX-gY.lab.workalaya.com]

PLAY RECAP ****************************************************************************************************
vmX-gY.lab.workalaya.com   : ok=4    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
~~~

Now, in your home directory make a .snmp directory with file snmp.conf inside it, make it readable only by you, and add the credentials to it:

You will perform this task using ansible.

Now we update ansible-playbook file named **_snmp.yml_** as

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi snmp.yml
~~~

~~~yaml
- hosts: snmp_hosts
  become: true
  tasks:
    - name: ensure package cache is up to date
      apt: update_cache=yes cache_valid_time=3600
      tags: snmp_client

    - name: install snmp tools
      package:
        name: "{{ item }}"
        state: present
      with_items:
        - snmp
        - snmp-mibs-downloader
      tags: snmp_client

    - name: Update /etc/snmp/snmp.conf
      lineinfile:
        dest: "/etc/snmp/snmp.conf"
        regexp: "^mibs :"
        line: "#mibs :"
      tags: snmp_client

    - name: Create .snmp directory in /home/lab/
      file:
        path: "/home/lab/.snmp"
        state: directory
        mode: 0700
      become: false
      tags: snmp_client

    - name: Create .snmp/snmp.conf
      copy:
        src: files/snmp/snmp.conf
        dest: /home/lab/.snmp/snmp.conf
        mode: 600
      become: false
      tags: snmp_client
~~~

and create new file named snmp.conf inside file/snmp/

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ mkdir -p files/snmp
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi files/snmp/snmp.conf
~~~

Put the following contents in the file:

~~~txt
defVersion 3
defSecurityLevel authNoPriv
defSecurityName admin
defAuthPassphrase NetManage
defAuthType SHA
defPrivType AES

# Default community when using SNMP v2c
defCommunity NetManage
~~~

Now run ansible playbook named **_snmp.yml_** again should see similar output

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ ansible-playbook snmp.yml
PLAY [snmp_hosts] *********************************************************************************************

TASK [Gathering Facts] ****************************************************************************************
ok: [vmX-gY.lab.workalaya.com]

TASK [ensure package cache is up to date] *********************************************************************
[WARNING]: Could not find aptitude. Using apt-get instead

ok: [vmX-gY.lab.workalaya.com]

TASK [install snmp tools] *************************************************************************************
ok: [vmX-gY.lab.workalaya.com] => (item=snmp)
ok: [vmX-gY.lab.workalaya.com] => (item=snmp-mibs-downloader)

TASK [Update /etc/snmp/snmp.conf] *****************************************************************************
ok: [vmX-gY.lab.workalaya.com]

TASK [Create .snmp directory in /home/lab/] *******************************************************************
changed: [vmX-gY.lab.workalaya.com]

TASK [Create .snmp/snmp.conf] *********************************************************************************
changed: [vmX-gY.lab.workalaya.com]

PLAY RECAP ****************************************************************************************************
vmX-gY.lab.workalaya.com   : ok=6    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
~~~

Creating this configuration file means you won't have to enter your credentials everytime you use one of the SNMP utilities. Otherwise you would have to add all these values on the command line like this:

now log into your vm and try executing following command

(this command will not yet work)

~~~bash
lab@vmX-gY:~$ snmpstatus -v3 -l authNoPriv -a SHA -u admin -A NetManage vmX-gY
~~~

## **Configure SNMP on Your Group Routers and Switches**

For this exercise you need to work together as a group. You will be enabling and configuring snmp to run on each of your group network devices. This includes:

- rtr1-gY.lab.workalaya.net

The commands to enable ssh are the same on each box, so divide the work between your group member:

Now connect to your campus network devices and on each do:

~~~bash
lab@vmX-gY:~$ ssh lab@rtr1-gY.lab.workalaya.net

username: lab
password: <CLASS PASSWORD>

rtr1-gY> enable
Password: <CLASS PASSWORD>
rtr1-gY# configure terminal
~~~

Now we need to add an Access Control List rule for SNMP access, turn on SNMP, assign a read-only SNMP community string as well as a SNMPv3 group and user and tell the router to maintain SNMP information across reboots. To do this we do:

(Note that "Y" is equal to your campus number)

~~~cisco
rtr1-gY(config)# snmp-server community NetManage ro 99
rtr1-gY(config)# snmp-server group ReadGroup v3 auth access 99
rtr1-gY(config)# access-list 99 permit 100.68.Y.1 0.0.0.0
rtr1-gY(config)# access-list 99 permit 100.68.Y.16 0.0.0.15
rtr1-gY(config)# access-list 99 permit 100.68.100.0 0.0.0.255
rtr1-gY(config)# snmp-server user admin ReadGroup v3 auth sha NetManage
rtr1-gY(config)# snmp-server ifindex persist
~~~

Now let's exit and save this new configuration to the routers permanent config.

~~~cisco
rtr1-gY(config)# exit
rtr1-gY# write memory
rtr1-gY# exit
~~~

If you have questions about what the access-list statement is restricting ask your instructors.

## **Testing SNMP**

To check that your SNMP installation works, run the snmpstatus command on each of the following devices from your host:

~~~bash
lab@vmX-gY:~$ snmpstatus <IP_ADDRESS>
~~~

Where is each of the following:

~~~txt
Group border router: 100.68.Y.1
~~~

**Note**: that you just used SNMPv3. Not all devices that implement SNMP support v3. Try again, adding "-v2c" as a parameter. Notice that the command automatically uses the community string in the snmp.conf file instead of the v3 user credentials. Try "-v1". That is try:

~~~bash
lab@vmX-gY:~$ snmpstatus -v2c <IP_ADDRESS>
~~~

and

~~~bash
lab@vmX-gY:~$ snmpstatus -v1 <IP_ADDRESS>
~~~

What happens if you try using the wrong community string (i.e. change NetManage to something else) using the options "-v2c -c NetWrong"?

~~~bash
lab@vmX-gY:~$ snmpstatus -v2c -c NetWrong <IP_ADDRESS>
~~~

## **SNMP Walk and OIDs**

Now, you are going to use the **_snmpwalk_** command, part of the SNMP toolkit, to list the tables associated with the OIDs listed below, on each piece of equipment you tried above:

~~~txt
.1.3.6.1.2.1.2.2.1.2
.1.3.6.1.2.1.31.1.1.1.18
.1.3.6.1.4.1.9.9.13.1
.1.3.6.1.2.1.25.2.3.1
.1.3.6.1.2.1.25.4.2.1
~~~

You will try this with two forms of the **_snmpwalk_** command:

~~~bash
lab@vmX-gY:~$ snmpwalk -v2c <IP_ADDRESS> <OID>
~~~

and

~~~bash
lab@vmX-gY:~$ snmpwalk -v2c -On <IP_ADDRESS> <OID>
~~~

... where OID is one of the OIDs listed above: .1.3.6...

...where IP_ADDRESS can be your group's router...

**Note**: the -On option turns on numerical output, i.e.: no translation of the OID <-> MIB object takes place.

For these OIDs:

1. Do all the devices answer?
2. Do you notice anything important about the OID on the output?

## **Configuration of snmpd on your host (vmX-gY.lab.workalaya.net)**

For this exercise your group needs to verify that the snmpd service is running and responding to queries for all machines in your group. First enable snmpd on your machine, then test if your machine is responding, then check each machine of your other group members.

- Install the SNMP agent (daemon) on your host

Now we update ansible-playbook file named **_snmp.yml_** as

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi snmp.yml
~~~

~~~yaml
- hosts: snmp_hosts
  become: true
  tasks:
    - name: ensure package cache is up to date
      apt: update_cache=yes cache_valid_time=3600
      tags: snmp_client, snmpd_server

    - name: install snmp tools
      package:
        name: "{{ item }}"
        state: present
      with_items:
        - snmp
        - snmp-mibs-downloader
      tags: snmp_client

    - name: Update /etc/snmp/snmp.conf
      lineinfile:
        dest: "/etc/snmp/snmp.conf"
        regexp: "^mibs :"
        line: "#mibs :"
      tags: snmp_client

    - name: Create .snmp directory in /home/lab/
      file:
        path: "/home/lab/.snmp"
        state: directory
        mode: 0700
      become: false
      tags: snmp_client

    - name: Create .snmp/snmp.conf
      copy:
        src: files/snmp/snmp.conf
        dst: /home/lab/.snmp/snmp.conf
        mode: 600
      become: false
      tags: snmp_client

    - name: install snmpd tools
      package:
        name: "{{ item }}"
        state: present
      with_items:
        - snmpd
        - libsnmp-dev
      tags: snmpd-server

    - name: Update /etc/snmp/snmpd.conf
      lineinfile:
        dest: "/etc/snmp/snmpd.conf"
        regexp: "^mibs :"
        line: "#mibs :"
      tags: snmpd_server
~~~

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ ansible-playbook snmp.yml -t snmpd_server

PLAY [snmp_hosts] *********************************************************************************************

TASK [Gathering Facts] ****************************************************************************************
ok: [vmX-gY.lab.workalaya.com]

TASK [ensure package cache is up to date] *********************************************************************
[WARNING]: Could not find aptitude. Using apt-get instead

ok: [vmX-gY.lab.workalaya.com]

TASK [install snmpd tools] ************************************************************************************
changed: [vmX-gY.lab.workalaya.com] => (item=snmpd)
changed: [vmX-gY.lab.workalaya.com] => (item=libsnmp-dev)

PLAY RECAP ****************************************************************************************************
vmX-gY.lab.workalaya.com   : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
~~~

- Configuration

We will create our own "snmpd.conf" template file and not "snmp.conf" and update ansible playbook named **_snmp.yml_** file

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ mkdir -p templates/snmpd
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi templates/snmpd/snmpd.conf
~~~

Then, copy/paste the following (change vmX-gY to your own host and campus number) and replace "Y" with your campus number:

~~~txt
#  Listen for connections on all interfaces (both IPv4 *and* IPv6)
agentAddress udp:161,udp6:161

# For SNMPv2: Configure Read-Only community and restrict who can connect
rocommunity NetManage 100.68.100.0/24
rocommunity NetManage 100.68.{{class_group}}.16/28
rocommunity NetManage 100.68.{{class_group}}.254/32
rocommunity NetManage 127.0.0.1
rocommunity6 NetManage ::1

# Information about this host
sysLocation    NPIX Network Management Workshop
sysContact     lab@{{inventory_hostname}}

# Which OSI layers are active in this host
# (Application + End-to-End layers)
sysServices    72

# Include proprietary dskTable MIB (in addition to hrStorageTable)
includeAllDisks  10%

createUser admin SHA "NetManage" AES
rwuser admin
~~~

~~~yaml
- hosts: snmp_hosts
  become: true
  tasks:
    - name: ensure package cache is up to date
      apt: update_cache=yes cache_valid_time=3600
      tags: snmp_client, snmpd_server

    - name: install snmp tools
      package:
        name: "{{ item }}"
        state: present
      with_items:
        - snmp
        - snmp-mibs-downloader
      tags: snmp_client

    - name: Update /etc/snmp/snmp.conf
      lineinfile:
        dest: "/etc/snmp/snmp.conf"
        regexp: "^mibs :"
        line: "#mibs :"
      tags: snmp_client

    - name: Create .snmp directory in /home/lab/
      file:
        path: "/home/lab/.snmp"
        state: directory
        mode: 0700
      become: false
      tags: snmp_client

    - name: Create .snmp/snmp.conf
      copy:
        src: files/snmp/snmp.conf
        dst: /home/lab/.snmp/snmp.conf
        mode: 600
      become: false
      tags: snmp_client

    - name: install snmpd tools
      package:
        name: "{{ item }}"
        state: present
      with_items:
        - snmpd
        - libsnmp-dev
      tags: snmpd_server

    - name: Update /etc/snmp/snmpd.conf
      template:
        src: templates/snmpd/snmpd.conf
        dest: "/etc/snmp/snmpd.conf"
      notify: restart snmpd
      tags: snmpd_server

  handlers:
    - name: restart snmpd
      service:
        name: snmpd
        state: restarted
~~~

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ ansible-playbook snmp.yml -t snmpd_server

PLAY [snmp_hosts] *********************************************************************************************

TASK [Gathering Facts] ****************************************************************************************
ok: [vmX-gY.lab.workalaya.com]

TASK [ensure package cache is up to date] *********************************************************************
[WARNING]: Could not find aptitude. Using apt-get instead

ok: [vmX-gY.lab.workalaya.com]

TASK [install snmpd tools] ************************************************************************************
ok: [vmX-gY.lab.workalaya.com] => (item=snmpd)
ok: [vmX-gY.lab.workalaya.com] => (item=libsnmp-dev)

TASK [Update /etc/snmp/snmpd.conf] ****************************************************************************
changed: [vmX-gY.lab.workalaya.com]

RUNNING HANDLER [restart snmpd] *******************************************************************************
changed: [vmX-gY.lab.workalaya.com]

PLAY RECAP ****************************************************************************************************
vmX-gY.lab.workalaya.com   : ok=5    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
~~~

## **Check that snmpd is working:**

log into your vm and run following command

~~~bash
lab@vmX-gY:~$ snmpstatus localhost
~~~

## **Test your neighbors**

Check now that you can run snmpstatus against your other group members host.

~~~bash
lab@vmX-gY:~$ snmpstatus vm[1..3]-gY.lab.workalaya.net
~~~

For instance, in group 5, you should verify against:

- vm1-g5.lab.workalaya.net
- vm2-g5.lab.workalaya.net
- vm3-g5.lab.workalaya.net
and, so on.

## **Configuration of snmpd on your srv1-gY.lab.workalaya.net server**

You may want to install the snmp daemon on your campus server at this time. If so, select someone from your group to do this. If not, it will be configured during a later exercise.

(follow the same process as of configuring your own VM)

## **Adding MIBs**

Remember when you ran:

~~~bash
lab@vmX-gY:~$ snmpwalk 100.68.Y.1 .1.3.6.1.4.1.9.9.13.1
~~~

If you noticed, the SNMP client (snmpwalk) couldn't interpret all the OIDs coming back from the Agent:

~~~txt
SNMPv2-SMI::enterprises.9.9.13.1.3.1.2.1 = STRING: "chassis"
SNMPv2-SMI::enterprises.9.9.13.1.3.1.6.1 = INTEGER: 1
~~~

What is _9.9.13.1.3.1_ ?

To be able to interpret this information, we need to download extra MIBs:

We will use the following MIBs (Don't download them yet!):

### **CISCO MIBS**

~~~txt
ftp://ftp.cisco.com/pub/mibs/v2/CISCO-SMI.my
ftp://ftp.cisco.com/pub/mibs/v2/CISCO-ENVMON-MIB.my
~~~

To make it easier, we have a local mirror on <http://www.lab.workalaya.net/downloads/mibs/>

we will update ansible playbook named **_snmp.yml_** to Download mib and update _/etc/snmp/snmp.conf_ to include them as follows:

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi snmp.yml
~~~

~~~yaml
- hosts: snmp_hosts
  become: true
  tasks:
    - name: ensure package cache is up to date
      apt: update_cache=yes cache_valid_time=3600
      tags: snmp_client, snmpd_server

    - name: install snmp tools
      package:
        name: "{{ item }}"
        state: present
      with_items:
        - snmp
        - snmp-mibs-downloader
      tags: snmp_client

    - name: Update /etc/snmp/snmp.conf
      lineinfile:
        dest: "/etc/snmp/snmp.conf"
        regexp: "^mibs :"
        line: "#mibs :"
      tags: snmp_client

    - name: Create .snmp directory in /home/lab/
      file:
        path: "/home/lab/.snmp"
        state: directory
        mode: 0700
      become: false
      tags: snmp_client

    - name: Create .snmp/snmp.conf
      copy:
        src: files/snmp/snmp.conf
        dst: /home/lab/.snmp/snmp.conf
        mode: 600
      become: false
      tags: snmp_client

    - name: install snmpd tools
      package:
        name: "{{ item }}"
        state: present
      with_items:
        - snmpd
        - libsnmp-dev
      tags: snmpd_server

    - name: Update /etc/snmp/snmpd.conf
      template:
        src: templates/snmpd/snmpd.conf
        dest: "/etc/snmp/snmpd.conf"
      notify: restart snmpd
      tags: snmpd_server

    - name: Create /var/lib/snmp/mibs/cisco
      file:
        path: "/var/lib/snmp/mibs/cisco"
        state: directory
        mode: 0700
      tags: mibs

    - name: check if mibs exists
      stat:
        path: '/var/lib/snmp/mibs/cisco/{{ item }}'
      register: mib_files
      with_items:
      - CISCO-SMI.my
      - CISCO-ENVMON-MIB.my
      tags: mibs

    - name: Check if mib files exist
      set_fact:
        mib_file_stat: '{{ mib_file_stat|default({}) | combine({item.item: item.stat.exists}) }}'
      with_items: '{{ mib_files.results }}'
      tags: mibs

    - name: Download mibs
      get_url:
        url: http://www.lab.workalaya.net/downloads/mibs/{{ item }}
        dest: /var/lib/snmp/mibs/cisco/{{ item }}
      when: not mib_file_stat[item]
      with_items:
        - CISCO-SMI.my
        - CISCO-ENVMON-MIB.my
      tags: mibs

    - name: update /etc/snmp/snmp.conf file
      lineinfile:
        dest: "/etc/snmp/snmp.conf"
        line: "{{item}}"
      with_items:
        - "mibdirs +/var/lib/snmp/mibs/cisco"
        - "mibs +CISCO-ENVMON-MIB:CISCO-SMI"
      tags: mibs

  handlers:
    - name: restart snmpd
      service:
        name: snmpd
        state: restarted
~~~

run ansible playbook as follows and should see similar output:

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ ansible-playbook snmp.yml -t mibs

PLAY [snmp_hosts] *********************************************************************************************

TASK [Gathering Facts] ****************************************************************************************
ok: [vmX-gY.lab.workalaya.com]

TASK [Create /var/lib/snmp/mibs/cisco] ************************************************************************
changed: [vmX-gY.lab.workalaya.com]

TASK [check if mibs exists] ***********************************************************************************
ok: [vmX-gY.lab.workalaya.com] => (item=CISCO-SMI.my)
ok: [vmX-gY.lab.workalaya.com] => (item=CISCO-ENVMON-MIB.my)

TASK [Check if mib files exist] *******************************************************************************
ok: [vmX-gY.lab.workalaya.com] => (item={'invocation': {'module_args': {'checksum_algorithm': 'sha1', 'get_checksum': True, 'follow': False, 'path': '/var/lib/snmp/mibs/cisco/CISCO-SMI.my', 'get_md5': None, 'get_mime': True, 'get_attributes': True}}, 'stat': {'exists': False}, 'changed': False, 'failed': False, 'item': 'CISCO-SMI.my', 'ansible_loop_var': 'item'})
ok: [vmX-gY.lab.workalaya.com] => (item={'invocation': {'module_args': {'checksum_algorithm': 'sha1', 'get_checksum': True, 'follow': False, 'path': '/var/lib/snmp/mibs/cisco/CISCO-ENVMON-MIB.my', 'get_md5': None, 'get_mime': True, 'get_attributes': True}}, 'stat': {'exists': False}, 'changed': False, 'failed': False, 'item': 'CISCO-ENVMON-MIB.my', 'ansible_loop_var': 'item'})

TASK [Download mibs] ******************************************************************************************
changed: [vmX-gY.lab.workalaya.com] => (item=CISCO-SMI.my)
changed: [vmX-gY.lab.workalaya.com] => (item=CISCO-ENVMON-MIB.my)

TASK [update /etc/snmp/snmp.conf file] ************************************************************************
changed: [vmX-gY.lab.workalaya.com] => (item=mibdirs +/var/lib/snmp/mibs/cisco)
changed: [vmX-gY.lab.workalaya.com] => (item=mibs +CISCO-ENVMON-MIB:CISCO-SMI)

PLAY RECAP ****************************************************************************************************
vmX-gY.lab.workalaya.com   : ok=6    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
~~~

Now, try again (the example uses rtr1-gY.lab.workalaya.net below. You can do this whichever network device you are configuring):

~~~bash
lab@vmX-gY:~$ snmpwalk 100.68.Y.1 .1.3.6.1.4.1.9.9.13.1
~~~

What do you notice ?

## **SNMPwalk - the rest of MIB-II**

Try and run snmpwalk on any hosts (routers and virtual machines) you have not tried yet, in the 100.68.Y.X network

Note the kind of information you can obtain.

~~~bash
lab@vmX-gY:~$ snmpwalk 100.68.Y.1 ifDescr
lab@vmX-gY:~$ snmpwalk 100.68.Y.1 ifAlias
lab@vmX-gY:~$ snmpwalk 100.68.Y.1 ifTable | less
lab@vmX-gY:~$ snmpwalk 100.68.Y.1 ifXTable | less
lab@vmX-gY:~$ snmpwalk 100.68.Y.1 ifOperStatus
lab@vmX-gY:~$ snmpwalk 100.68.Y.1 ifAdminStatus
lab@vmX-gY:~$ snmpwalk 100.68.Y.1 if
~~~

(Remember that with _less_ you press **_\<space\>_** for next page, **_b_** to go back to previous page, and **_q_** to quit)

Can you see what's different between **_ifTable_** and **_ifXTable_**?

What do you think might be the difference between **_ifOperStatus_** and **_ifAdminStatus_**? Can you imagine a scenario where this could be useful ?

## **More MIB-OID fun**

Use SNMP to examine:

- the running processes on your neighbor's host (hrSWRun)
- the amount of free diskspace on your neighbor's host (hrStorage)
- the interfaces on your neighbor's host (ifIndex, ifDescr)

Can you use short names to walk these OID tables ?

- Experiment with the "snmptranslate" command, example:

~~~bash
lab@vmX-gY:~$ snmptranslate .1.3.6.1.4.1.9.9.13.1
~~~

- Try with various OIDs

---
