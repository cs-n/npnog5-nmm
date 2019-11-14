# **Network Management & Monitoring - Using RANCID**

## **Introduction**

### **Goals**

- Gain experience with RANCID

### **Notes**

- Commands preceded with "$" imply that you should execute the command as a general user - not as root.
- Commands preceded with "#" imply that you should be working as root.
- Commands with more specific command lines (e.g. "rtrX>" or "mysql>") imply that you are executing commands on remote equipment, or within another program.
- If a command line ends with "\\" this indicates that the command continues on the next line and you should treat this as a single line.
- References to "Y" represent your group number.

---

## **Install RANCID**

In this exercise you will install rancid and its dependencies.

**Log in to your shared workstation virtual machine as "vmX-gY" user.** (Replace X with vm no and Y with group no)

Now we create new ansible-playbook file named **_rancid.yml_**

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi rancid.yml
~~~

~~~yaml
- hosts: rancid_hosts
  become: true
  tasks:
    - name: ensure package cache is up to date
      apt: update_cache=yes cache_valid_time=3600
      tags: install

    - name: Set RANCID options
      debconf:
        name: "{{ item.name }}"
        question: "{{ item.question }}"
        value: "{{ item.value }}"
        vtype: "string"
      with_items:
        - { name: "rancid", question: "rancid/warning", value: "" }
        - { name: "rancid", question: "rancid/go_on", value: "true" }
      tags: install

    - name: install rancid and dependencies
      package:
        name: "{{ item }}"
        state: present
      with_items:
        - subversion
        - telnet
        - mutt
        - rancid
      tags: install
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

[rancid_hosts]
vmX-gY.lab.workalaya.net
~~~

Now run ansible playbook to install _RANCID_

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ ansible-playbook rancid.yml

PLAY [rancid_hosts] *******************************************************************************************

TASK [Gathering Facts] ****************************************************************************************
ok: [vmX-gY.lab.workalaya.com]

TASK [ensure package cache is up to date] *********************************************************************
[WARNING]: Could not find aptitude. Using apt-get instead

changed: [vmX-gY.lab.workalaya.com]

TASK [Set RANCID options] *************************************************************************************
changed: [vmX-gY.lab.workalaya.com] => (item={'name': 'rancid', 'question': 'rancid/warning', 'value': ''})
changed: [vmX-gY.lab.workalaya.com] => (item={'name': 'rancid', 'question': 'rancid/go_on', 'value': 'true'})

TASK [install rancid and dependencies] ************************************************************************
ok: [vmX-gY.lab.workalaya.com] => (item=subversion)
ok: [vmX-gY.lab.workalaya.com] => (item=telnet)
ok: [vmX-gY.lab.workalaya.com] => (item=mutt)
changed: [vmX-gY.lab.workalaya.com] => (item=rancid)

PLAY RECAP ****************************************************************************************************
vmX-gY.lab.workalaya.com   : ok=4    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
~~~

### **Add alias**

Add an alias for the rancid user in _/etc/aliases_ file

RANCID by default sends emails to the users rancid-groupname and rancid-admin-groupname. We want them to be sent to the lab user instead and use the alias function for this.

update ansible playbook named **_rancid.yml_** to do this as

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi rancid.yml
~~~

~~~yaml
- hosts: rancid_hosts
  become: true
  tasks:
    - name: ensure package cache is up to date
      apt: update_cache=yes cache_valid_time=3600
      tags: install

    - name: Set RANCID options
      debconf:
        name: "{{ item.name }}"
        question: "{{ item.question }}"
        value: "{{ item.value }}"
        vtype: "string"
      with_items:
        - { name: "rancid", question: "rancid/warning", value: "" }
        - { name: "rancid", question: "rancid/go_on", value: "true" }
      tags: install

    - name: install rancid and dependencies
      package:
        name: "{{ item }}"
        state: present
      with_items:
        - subversion
        - telnet
        - mutt
        - rancid
      tags: install

    - name: Add rancid mail alias
      lineinfile:
        dest: "/etc/aliases"
        line: "{{ item }}: lab"
      with_items:
        - randic-routers
        - rancid-admin-routers
      register: mailalias
      tags: mail_alias

    - name: Update mail alias
      shell: newaliases
      when: mailalias.changed
      tags: mail_alias
~~~

Now run ansible playbook to update _RANCID_ mail alias

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ ansible-playbook rancid.yml -t mail_alias

PLAY [rancid_hosts] *******************************************************************************************

TASK [Gathering Facts] ****************************************************************************************
ok: [vmX-gY.lab.workalaya.com]

TASK [Add rancid mail alias] **********************************************************************************
changed: [vmX-gY.lab.workalaya.com] => (item=randic-routers)
changed: [vmX-gY.lab.workalaya.com] => (item=rancid-admin-routers)

TASK [Update mail alias] **************************************************************************************
changed: [vmX-gY.lab.workalaya.com]

PLAY RECAP ****************************************************************************************************
vmX-gY.lab.workalaya.com   : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
~~~

### **Configure rancid**

We will define randic config group named _routers_ and We want to use Subversion for our Version Control System, and not CVS, so edit ansible playbook named **_rancid.yml_** to do this as

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi rancid.yml
~~~

~~~yaml
- hosts: rancid_hosts
  become: true
  tasks:
    - name: ensure package cache is up to date
      apt: update_cache=yes cache_valid_time=3600
      tags: install

    - name: Set RANCID options
      debconf:
        name: "{{ item.name }}"
        question: "{{ item.question }}"
        value: "{{ item.value }}"
        vtype: "string"
      with_items:
        - { name: "rancid", question: "rancid/warning", value: "" }
        - { name: "rancid", question: "rancid/go_on", value: "true" }
      tags: install

    - name: install rancid and dependencies
      package:
        name: "{{ item }}"
        state: present
      with_items:
        - subversion
        - telnet
        - mutt
        - rancid
      tags: install

    - name: Add rancid mail alias
      lineinfile:
        dest: "/etc/aliases"
        line: "{{ item }}: lab"
      with_items:
        - randic-routers
        - rancid-admin-routers
      register: mailalias
      tags: mail_alias

    - name: Update mail alias
      shell: newaliases
      when: mailalias.changed
      tags: mail_alias

    - name: Configure rancid
      lineinfile:
        dest: "/etc/rancid/rancid.conf"
        line: "{{ item.line }}"
        regexp: "{{ item.regexp }}"
      with_items:
        - { line: "CVSROOT=$BASEDIR/svn; export CVSROOT", regexp: "^CVSROOT" }
        - { line: "RCSSYS=svn; export RCSSYS", regexp: "^RCSSYS" }
      tags: config
  
    - name: Configure rancid groups
      block:
        - lineinfile:
            path: "/etc/rancid/rancid.conf"
            regexp: "^LIST_OF_GROUPS="
            state: absent
          check_mode: yes
          changed_when: false
          register: rancidgroups
        - lineinfile:
            dest: "/etc/rancid/rancid.conf"
            line: "LIST_OF_GROUPS="
          when: rancidgroups is not defined or not rancidgroups.found
        - lineinfile:
            dest: "/etc/rancid/rancid.conf"
            line: "LIST_OF_GROUPS=\"{{ rancid_groups|join(' ') }}\""
            regexp: "^LIST_OF_GROUPS"
          vars:
            rancid_groups:
              - routers
      tags: config
~~~

Now run ansible playbook to update _RANCID_ configuration

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ ansible-playbook rancid.yml -t config

PLAY [rancid_hosts] *******************************************************************************************

TASK [Gathering Facts] ****************************************************************************************
ok: [vmX-gY.lab.workalaya.com]

TASK [Configure rancid] ***************************************************************************************
changed: [vmX-gY.lab.workalaya.com] => (item={'line': 'CVSROOT=$BASEDIR/svn; export CVSROOT', 'regexp': '^CVSROOT'})
changed: [vmX-gY.lab.workalaya.com] => (item={'line': 'RCSSYS=svn; export RCSSYS', 'regexp': '^RCSSYS'})

TASK [lineinfile] *********************************************************************************************
ok: [vmX-gY.lab.workalaya.com]

TASK [lineinfile] *********************************************************************************************
changed: [vmX-gY.lab.workalaya.com]

TASK [lineinfile] *********************************************************************************************
changed: [vmX-gY.lab.workalaya.com]

PLAY RECAP ****************************************************************************************************
vmX-gY.lab.workalaya.com   : ok=5    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
~~~

### **Create /var/lib/rancid/.cloginrc**

Now create template file for _.cloginrc_ as

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ mkdir -p templates/rancid

(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi templates/rancid/.cloginrc
~~~

Add the following lines in the file:

~~~txt
add method * {ssh}
add user *.lab.workalaya.net lab
add password *.lab.workalaya.net {{ class_password }} {{ class_en_password }}
add cyphertype *.lab.workalaya.net {aes256-cbc}
~~~

(The first 'lab' is the username, the first 'class_password' is login password and second 'class_en_password' is enable password used to login to your router. The star in the name means that it will try to use this username and password for all routers whose names end .lab.workalaya.net)

now update **_all.yml_** file on _inventory/group_vars/_ as

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi inventory/group_vars/all.yml
~~~

~~~txt
ansible_ssh_user: lab
ansible_become_password: lab

class_password: lab
class_group: Y
class_en_password: lab
~~~

edit ansible playbook named **_rancid.yml_** to do this as

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi rancid.yml
~~~

~~~yaml
- hosts: rancid_hosts
  become: true
  tasks:
    - name: ensure package cache is up to date
      apt: update_cache=yes cache_valid_time=3600
      tags: install

    - name: Set RANCID options
      debconf:
        name: "{{ item.name }}"
        question: "{{ item.question }}"
        value: "{{ item.value }}"
        vtype: "string"
      with_items:
        - { name: "rancid", question: "rancid/warning", value: "" }
        - { name: "rancid", question: "rancid/go_on", value: "true" }
      tags: install

    - name: install rancid and dependencies
      package:
        name: "{{ item }}"
        state: present
      with_items:
        - subversion
        - telnet
        - mutt
        - rancid
      tags: install

    - name: Add rancid mail alias
      lineinfile:
        dest: "/etc/aliases"
        line: "{{ item }}: lab"
      with_items:
        - randic-routers
        - rancid-admin-routers
      register: mailalias
      tags: mail_alias

    - name: Update mail alias
      shell: newaliases
      when: mailalias.changed
      tags: mail_alias

    - name: Configure rancid
      lineinfile:
        dest: "/etc/rancid/rancid.conf"
        line: "{{ item.line }}"
        regex: "{{ item.regex }}"
      with_items:
        - { line: "CVSROOT=$BASEDIR/svn; export CVSROOT", regex: "^CVSROOT" }
        - { line: "RCSSYS=svn; export RCSSYS", regex: "^RCSSYS" }
      tags: config
  
    - name: Configure rancid groups
      block:
        - lineinfile:
            path: "/etc/rancid/rancid.conf"
            regexp: "^LIST_OF_GROUPS="
            state: absent
          check_mode: yes
          changed_when: false
          register: rancidgroups
        - lineinfile:
            dest: "/etc/rancid/rancid.conf"
            line: "LIST_OF_GROUPS="
          when: rancidgroups is not defined or not rancidgroups.found
        - lineinfile:
            dest: "/etc/rancid/rancid.conf"
            line: "LIST_OF_GROUPS=\"{{ rancid_groups|join(' ') }}\""
            regex: "^LIST_OF_GROUPS"
          vars:
            rancid_groups:
              - routers
      tags: config

    - name: /var/lib/rancid/.cloginrc
      template:
        src: templates/rancid/.cloginrc
        dest: /var/lib/rancid/.cloginrc
        backup: yes
        owner: rancid
        group: rancid
        mode: 0600
      tags: cloginrc
~~~

Now run ansible playbook to update _RANCID_ configuration

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ ansible-playbook rancid.yml -t cloginrc

PLAY [rancid_hosts] *******************************************************************************************

TASK [Gathering Facts] ****************************************************************************************
ok: [vmX-gY.lab.workalaya.com]

TASK [/var/lib/rancid/.cloginrc] ******************************************************************************
changed: [vmX-gY.lab.workalaya.com]

PLAY RECAP ****************************************************************************************************
vmX-gY.lab.workalaya.com   : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
~~~

## **Test login to the router of your group**

Now login back to your VM for perform rest of the tasks.

Login to your router with clogin. You might have to type yes to the first warning, but should not need to enter a password, this should be automatic.

~~~bash
root@vmX-gY:~# su - rancid
rancid@vmX-gY:~$ /var/lib/rancid/bin/clogin rtr1-gY.lab.workalaya.net
~~~

(replace Y with your group number. So, group 1 is rtr1-g1.lab.workalaya.net)

You should get something like:

~~~txt
rtr1-g1.lab.workalaya.net
spawn ssh -c aes256-cbc -x -l lab rtr1-g1.lab.workalaya.net
The authenticity of host 'rtr1-g1.lab.workalaya.net (100.68.100.1)' can't be established.
RSA key fingerprint is SHA256:9HYY8A9aEJtQz7+Vn8MzFlomLCkUNtboEcQ8ms/BygM.
Are you sure you want to continue connecting (yes/no)?
Host rtr1-g1.lab.workalaya.net added to the list of known hosts.
yes
Warning: Permanently added 'rtr1-g1.lab.workalaya.net,100.68.100.1' (RSA) to the list of known hosts.
Password:
rtr1-g1>enable
Password:
rtr1-g1#
~~~

Exit the from the router login:

~~~cisco
rtr1-g1#exit
Connection to rtr1-g1.lab.workalaya.net closed.
~~~

## **Initialize the SVN repository for rancid**

Make sure you are the rancid user before doing this:

~~~bash
rancid@vmX-gY:~$ id
~~~

If you do not see something like

~~~bash
uid=111(rancid) gid=116(rancid) groups=116(rancid)
~~~

then _DO NOT CONTINUE_ until you have become the _rancid_ user. See earlier section for details.

Now initialize the Version Control repository (it will use Subversion):

~~~bash
rancid@vmX-gY:~$ /usr/lib/rancid/bin/rancid-cvs
~~~

You should see something similar to this:

~~~txt
Committing transaction...
Committed revision 1.
Checked out revision 1.
Updating '.':
At revision 1.
A         configs
Adding         configs
Committing transaction...
Committed revision 2.
A         router.db
Adding         router.db
Transmitting file data .done
Committing transaction...
Committed revision 3.
Committing transaction...
Committed revision 4.
Checked out revision 4.
Updating '.':
At revision 4.
A         configs
Adding         configs
Committing transaction...
Committed revision 5.
A         router.db
Adding         router.db
Transmitting file data .done
Committing transaction...
Committed revision 6.
Committing transaction...
Committed revision 7.
Checked out revision 7.
Updating '.':
At revision 7.
A         configs
Adding         configs
Committing transaction...
Committed revision 8.
A         router.db
Adding         router.db
Transmitting file data .done
Committing transaction...
Committed revision 9.
~~~

---

### **Do the following ONLY if you have problems**

If this does not work, then either you are missing the subversion package, or something was not properly configured during the previous steps. You should verify that subversion is installed and then before running the rancid-cvs command again do the following:

~~~bash
rancid@vmX-gY:~$ exit
root@vmX-gY:~# apt install subversion
root@vmX-gY:~# su - rancid
rancid@vmX-gY:~$ cd /var/lib/rancid
rancid@vmX-gY:~$ rm -rf routers
rancid@vmX-gY:~$ rm -rf svn
~~~

Now try running the rancid-cvs command again:

~~~bash
rancid@vmX-gY:~$ /usr/lib/rancid/bin/rancid-cvs
~~~

---

## **Create the router.db file**

~~~bash
rancid@vmX-gY:~$ vi /var/lib/rancid/routers/router.db
~~~

Add this line (NO spaces at the beginning please):

~~~txt
rtr1-gY.lab.workalaya.net;cisco;up
~~~

(remember to replace Y with your group number as appropriate)

Exit and save the file.

## **Let's run rancid!**

Still as the rancid user:

~~~bash
rancid@vmX-gY:~$ /usr/lib/rancid/bin/rancid-run
~~~

This may take some time so be patient.

Run it again, since the first time it might not commit correctly:

~~~bash
rancid@vmX-gY:~$ /usr/lib/rancid/bin/rancid-run
~~~

### **Check the rancid log files:**

~~~bash
rancid@vmX-gY:~$ cd /var/lib/rancid/logs
rancid@vmX-gY:~$ ls -l
~~~

... View the contents of the file(s):

~~~bash
rancid@vmX-gY:~ less router*
~~~

**_NOTE!_** Using "less" - to see the next file press ":n". To see the Previous file press ":p". To exit from less press "q".

### **Look at the configs**

~~~bash
rancid@vmX-gY:~$ cd /var/lib/rancid/routers/configs
rancid@vmX-gY:~$ less rtr1-gY.lab.workalaya.net
~~~

Where you should replace "Y" with your group number.

If all went well, you can see the config of the router.

### **Tracking changes**

Let's change an interface Description on the router

~~~bash
rancid@vmX-gY:~$ /usr/lib/rancid/bin/clogin rtr1-gY.lab.workalaya.net
~~~

Where you should replace "Y" with your group number.

At the "rtr1-gY#" prompt, enter the command:

~~~cisco
rtr1-gY# conf term
~~~

You should see:

~~~cisco
Enter configuration commands, one per line.  End with CNTL/Z.
rtr1-gY(config)#
~~~

Enter:

~~~cisco
rtr1-gY(config)# interface LoopbackXX      (replace XX with your server number)
~~~

You should get this prompt:

~~~cisco
rtr1-gY(config-if)#
~~~

Enter:

~~~cisco
rtr1-gY(config-if)# description <put your name here>
rtr1-gY(config-if)# end
~~~

You should now have this prompt:

~~~cisco
rtr1-gY#
~~~

To save the config to memory:

~~~cisco
rtr1-gY# write memory
~~~

You should see:

~~~cisco
Building configuration...
[OK]
~~~

To exit type:

~~~cisco
rtrX# exit
~~~

Now you should be back at your rancid user prompt on your system.

### **Let's run rancid again**

~~~bash
rancid@vmX-gY:~$ /usr/lib/rancid/bin/rancid-run
~~~

It will take some time to pull the latest router config file. Look at the rancid logs after it's completed.

~~~bash
rancid@vmX-gY:~$ ls /var/lib/rancid/logs/
~~~

You should see the latest rancid execution as a new log file with the date and time in the name.

### **Let's see the differences**

~~~bash
rancid@vmX-gY:~$ cd /var/lib/rancid/routers/configs
rancid@vmX-gY:~$ ls -l
~~~

You should see the router config file for your group:

~~~bash
rancid@vmX-gY:~$ svn log rtr1-gY.lab.workalaya.net
~~~

(where Y is the number of your group)

Notice the revisions. You should see different revision numbers such as r6, r9 and r8. Choose the lowest and the highest one.

~~~txt
------------------------------------------------------------------------
r15 | rancid | 2019-11-07 14:45:24 +0000 (Thu, 07 Nov 2019) | 1 line

updates
------------------------------------------------------------------------
r12 | rancid | 2019-11-07 14:43:12 +0000 (Thu, 07 Nov 2019) | 1 line

updates
------------------------------------------------------------------------
r11 | rancid | 2019-11-07 14:42:24 +0000 (Thu, 07 Nov 2019) | 1 line

new router
------------------------------------------------------------------------
~~~

Let's view the difference between two versions:

~~~bash
rancid@vmX-gY:~$ svn diff -r11:15 rtr1-gY.lab.workalaya.net | less
rancid@vmX-gY:~$ svn diff -r12:15 rtr1-gY.lab.workalaya.net | less
~~~

... can you find your changes?

Notice that svn is the Subversion Version Control system command line tool for viewing Subversion repositories of information. If you type:

~~~bash
rancid@vmX-gY:~$ cd /var/lib/rancid/routers
rancid@vmX-gY:~$ ls -lah
~~~

You will see a hidden directory called **_.svn_** - this actually contains all the information about the changes between router configurations from each time you run rancid using _/usr/lib/rancid/bin/rancid-run_.

Whatever you do, DO NOT EDIT or touch the **_.svn_** directory by hand!

### **Check your mail**

Now we will exit from the rancid user shell and the root user shell to go back to being the "lab" user. Then we'll use the "mutt" email client to see if rancid has been sending emails to the lab user.

~~~bash
rancid@vmX-gY:~$ exit               (takes your from rancid to root user)
root@vmX-gY:~# exit                 (take you from root to lab user)
lab@vmX-gY:~$ id
~~~

... check that you are now the 'lab' user again;

... if not, log out and in again as lab to your VM

~~~bash
lab@vmX-gY:~$ mutt
~~~

(When asked to create the Mail directory, say Yes)

If everything goes as planned, you should be able to read the mails sent by Rancid. You can select an email sent by "rancid@rtrX-gY.lab.workalaya.net" and see what it looks like.

Notice that it is your router description and any differences from the last time it was obtained using the rancid-run command.

Now exit from mutt.

(use 'q' return to mail index, and 'q' again to quit mutt)

## **Cron configuration**

Let's make rancid run automatically every 30 minutes from using cron

cron is a system available in Linux to automate the running of jobs. First we need to become the root user again:

~~~bash
lab@vmX-gY:~$ sudo -s
root@vmX-gY:~#
~~~

Now create or edit the file /etc/cron.d/rancid:

~~~bash
root@vmX-gY:~# vi /etc/cron.d/rancid
~~~

and add the following line to the bottom:

~~~txt
*/30 * * * * rancid /usr/lib/rancid/bin/rancid-run
~~~

If this file already exists then add this line and leave the rest commented out.

That's it. The command "rancid-run" will execute automatically from now on every 30 minutes all the time (every day, week and month).

## **More devices**

Become the rancid user and update the router.db file:

~~~bash
root@vmX-gY:~# su -s /bin/bash - rancid
rancid@vmX-gY:~$ vi /var/lib/rancid/routers/router.db
~~~

Add the two remaining devices in your campus so that the file ends up looking like this where "Y" is your campus number.

~~~txt
rtr1-g1.lab.workalaya.net;cisco;up
rtr1-g2.lab.workalaya.net;cisco;up
rtr1-g3.lab.workalaya.net;cisco;up
rtr1-g4.lab.workalaya.net;cisco;up
rtr1-g5.lab.workalaya.net;cisco;up
rtr1-g6.lab.workalaya.net;cisco;up
rtr1-g7.lab.workalaya.net;cisco;up
rtr1-g8.lab.workalaya.net;cisco;up
rtr1-g9.lab.workalaya.net;cisco;up
rtr1-g10.lab.workalaya.net;cisco;up
rtr1-g11.lab.workalaya.net;cisco;up
~~~

(Note that "cisco" means this is Cisco equipment -- it tells Rancid that we are expecting to talk to a Cisco device here. You can also talk to Juniper, HP, ...).

Be sure the entries are aligned to the left of the file.

Run rancid again (still as the 'rancid' user)

~~~bash
rancid@vmX-gY:~$ /usr/lib/rancid/bin/rancid-run
~~~

This should take a minute or more now, be patient.

Check out the logs:

~~~bash
rancid@vmX-gY:~$ cd /var/lib/rancid/logs
rancid@vmX-gY:~$ ls -l
~~~

... Pick the latest file and view it

~~~bash
rancid@vmX-gY:~$ less routers.YYYYMMDD.HHMMSS
~~~

This should be the last file listed in the output from "ls -l"

You should notice a bunch of statements indicating that routers have been added to the Subversion version control repository, and much more.

Look at the configs

~~~bash
rancid@vmX-gY:~$ cd /var/lib/rancid/routers/configs
rancid@vmX-gY:~$ less *.lab.workalaya.net
~~~

Press the SPACE bar to scroll through each file and then press ":n" to view the next file. Press "q" to quit at any time.

If all went well, you can see the configs of ALL routers

Re-run rancid
Run RANCID again just in case someone changed some configuration on the router

~~~bash
rancid@vmX-gY:~$ /usr/lib/rancid/bin/rancid-run
~~~

This could take a few moments, so be patient....

Play with clogin

~~~bash
rancid@vmX-gY:~$ /usr/lib/rancid/bin/clogin -c "show clock" rtr1-gY.lab.workalaya.net
~~~

Where "Y" is the number of your group.

What do you notice ?

Even better, we can show the power of using a simple script to make changes to multiple devices quickly:

~~~bash
rancid@vmX-gY:~$ vi /tmp/newuser
~~~

... in this file, add the following commands (COPY and PASTE):

~~~txt
configure terminal
username nocgY secret 0 NewPassword
end
write
~~~

Save the file, exit, and run the following commands from the command line:

~~~bash
rancid@vmX-gY:~$ for group in `seq 1 11`
~~~

Your prompt will now change to be ">". Continue by typing:

~~~bash
> do
> /var/lib/rancid/bin/clogin -x /tmp/newuser rtr1-g$group.lab.workalaya.net
> done
~~~

Now your prompt will go back to "$" and rancid clogin command will run and execute the commands you just typed above on all of your network devices. This is simple shell scripting in Linux, but it's very powerful.

Q. How would you verify that this has executed correctly ? Hint: "show run | inc"

A. Connect to rtr1-g1 and rtr-gY's. Type "enable" and then type "show run | inc username" to verify that the NewUser username now exists. Type exit to leave each router. Naturally you could automate this like we just did above.

---

## **Install ViewVC**

Now we will add the RANCID SVN (Subversion) repository into ViewVC so that you can browse configurations via the web.

Now we will install ViewVC and configure it using ansible.

**Log in to your shared workstation virtual machine as "vmXgY" user.** (Replace X with vm no and Y with group no)

Now we create new ansible-playbook file named **_rancid_viewvc.yml_**

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi rancid_viewvc.yml
~~~

~~~yaml
- hosts: rancid_hosts
  become: true
  tasks:
    - name: ensure package cache is up to date
      apt: update_cache=yes cache_valid_time=3600
      tags: install

    - name: install ViewVC and dependencies
      package:
        name: "{{ item }}"
        state: present
      with_items:
        - viewvc
        - apache2
      tags: install

    - name: update /etc/viewvc/viewvc.conf for svn root
      lineinfile:
        path: /etc/viewvc/viewvc.conf
        regexp: '^svn_roots'
        insertafter: '#svn_roots'
        line: "svn_roots = rancid: /var/lib/rancid/svn"
      tags: config
~~~

Now run ansible playbook to install _ViewVC_

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ ansible-playbook rancid_viewvc.yml

PLAY [rancid_hosts] *******************************************************************************************

TASK [Gathering Facts] ****************************************************************************************
ok: [vmX-gY.lab.workalaya.com]

TASK [ensure package cache is up to date] *********************************************************************
[WARNING]: Could not find aptitude. Using apt-get instead

changed: [vmX-gY.lab.workalaya.com]

TASK [install ViewVC and dependencies] ************************************************************************
changed: [vmX-gY.lab.workalaya.com] => (item=viewvc)
ok: [vmX-gY.lab.workalaya.com] => (item=apache2)

TASK [update /etc/viewvc/viewvc.conf for svn root] ************************************************************
changed: [vmX-gY.lab.workalaya.com]

PLAY RECAP ****************************************************************************************************
vmX-gY.lab.workalaya.com   : ok=4    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
~~~

Next, we need to add apache web server user (www-data) into rancid group in order to grant access for apache webserver to view rancid's SVN repo and update apache config.

update ansible-playbook file named **_rancid_viewvc.yml_**

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi rancid_viewvc.yml
~~~

~~~yaml
- hosts: rancid_hosts
  become: true
  tasks:
    - name: ensure package cache is up to date
      apt: update_cache=yes cache_valid_time=3600
      tags: install

    - name: install ViewVC and dependencies
      package:
        name: "{{ item }}"
        state: present
      with_items:
        - viewvc
        - apache2
      tags: install

    - name: update /etc/viewvc/viewvc.conf for svn root
      lineinfile:
        path: /etc/viewvc/viewvc.conf
        regexp: '^svn_roots'
        insertafter: '#svn_roots'
        line: "svn_roots = rancid: /var/lib/rancid/svn"
      tags: config

    - name: add www-data into rancid group
      user:
        name: www-data
        groups: rancid
        append: yes
      tags: apache_config

    - name: copy ViewVC apache config
      copy:
        src: files/apache2/viewvc.conf
        dest: /etc/apache2/conf-available/
      tags: apache_config

    - name: enable ViewVC with apache
      command: a2enconf viewvc.conf
      args:
        creates: /etc/apache2/sites-enabled/viewvc.conf
      notify: restart apache2
      tags: apache_config

  handlers:
    - name: restart apache2
      service:
        name: apache2
        state: restarted
~~~

Add ViewVC configuration into the new config file viewvc.conf

~~~bash
(venv) Chaturs-MacBook-Pro:ansible-playbooks chatur$ mkdir -p files/apache2
(venv) Chaturs-MacBook-Pro:ansible-playbooks chatur$ vi files/apache2/viewvc.conf
~~~

~~~txt
Alias       /viewvc-static /etc/viewvc/templates/docroot
ScriptAlias /viewvc /usr/lib/cgi-bin/viewvc.cgi
~~~

Now run ansible playbook to configure apache to enable _ViewVC_

~~~bash
(venv) Chaturs-MacBook-Pro:ansible-playbooks chatur$ ansible-playbook rancid_viewvc.yml -t apache_config

PLAY [rancid_hosts] *******************************************************************************************

TASK [Gathering Facts] ****************************************************************************************
ok: [vmX-gY.lab.workalaya.com]

TASK [add www-data into rancid group] *************************************************************************
changed: [vmX-gY.lab.workalaya.com]

TASK [copy ViewVC apache config] ******************************************************************************
changed: [vmX-gY.lab.workalaya.com]

TASK [enable ViewVC with apache] ******************************************************************************
changed: [vmX-gY.lab.workalaya.com]

RUNNING HANDLER [restart apache2] *****************************************************************************
changed: [vmX-gY.lab.workalaya.com]

PLAY RECAP ****************************************************************************************************
vmX-gY.lab.workalaya.com   : ok=5    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
~~~

Browse the rancid files from your Web browser!

~~~url
http://vmX-gY.lab.workalaya.net/viewvc/rancid/
~~~

Browse the files under the 'routers/configs' directory. You can see all your router configuration files here.

## **Securing ViewVC**

You would not want the entire Internet to be able to browse your configuration files. Here are some steps you can take to secure WebSVN access. One step not included is to enforce the use of https (ssl) access. We recommend this for all your web sites wherever possible.

Edit Apache configuration file for ViewVC

~~~bash
(venv) Chaturs-MacBook-Pro:ansible-playbooks chatur$ vi files/apache2/viewvc.conf
~~~

Add the configuration at the end of the file.

~~~txt
Alias       /viewvc-static /etc/viewvc/templates/docroot
ScriptAlias /viewvc /usr/lib/cgi-bin/viewvc.cgi

<DirectoryMatch (/viewvc)>
    AuthName "ViewVC Access"
    AuthType Basic
    AuthUserFile /etc/viewvc/.htpasswd
    require valid-user
</DirectoryMatch>
~~~

next update ansible-playbook file named **_rancid_viewvc.yml_** as

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi rancid_viewvc.yml
~~~

~~~yaml
- hosts: rancid_hosts
  become: true
  tasks:
    - name: ensure package cache is up to date
      apt: update_cache=yes cache_valid_time=3600
      tags: install

    - name: install ViewVC and dependencies
      package:
        name: "{{ item }}"
        state: present
      with_items:
        - viewvc
        - apache2
      tags: install

    - name: update /etc/viewvc/viewvc.conf for svn root
      lineinfile:
        path: /etc/viewvc/viewvc.conf
        regexp: '^svn_roots'
        insertafter: '#svn_roots'
        line: "svn_roots = rancid: /var/lib/rancid/svn"
      tags: config

    - name: add www-data into rancid group
      user:
        name: www-data
        groups: rancid
        append: yes
      tags: apache_config

    - name: copy ViewVC apache config
      copy:
        src: files/apache2/viewvc.conf
        dest: /etc/apache2/conf-available/
      tags: apache_config, secure_viewvc
      notify: restart apache2

    - name: enable ViewVC with apache
      command: a2enconf viewvc.conf
      args:
        creates: /etc/apache2/sites-enabled/viewvc.conf
      notify: restart apache2
      tags: apache_config

    - name: check viewvc .htpasswd dile
      stat:
        path: /etc/viewvc/.htpasswd
      ignore_errors: true
      register: viewvc_pwfile_exists
      tags: secure_viewvc

    - name: Create empty password file
      command: touch /etc/viewvc/.htpasswd
      args:
        creates: /etc/viewvc/.htpasswd
      when: not viewvc_pwfile_exists
      tags: secure_viewvc

    - name: Create nagios admin user
      htpasswd:
        path: /etc/viewvc/.htpasswd
        name: lab
        password: "{{ class_password }}"
        state: present
      ignore_errors: true
      tags: secure_viewvc

  handlers:
    - name: restart apache2
      service:
        name: apache2
        state: restarted
~~~

Now run ansible playbook to secure _ViewVC_ web access

~~~bash
(venv) Chaturs-MacBook-Pro:ansible-playbooks chatur$ ansible-playbook rancid_viewvc.yml -t secure_viewvc

PLAY [rancid_hosts] *******************************************************************************************

TASK [Gathering Facts] ****************************************************************************************
ok: [vmX-gY.lab.workalaya.com]

TASK [copy ViewVC apache config] ******************************************************************************
changed: [vmX-gY.lab.workalaya.com]

TASK [check viewvc .htpasswd dile] ****************************************************************************
ok: [vmX-gY.lab.workalaya.com]

TASK [Create empty password file] *****************************************************************************
skipping: [vmX-gY.lab.workalaya.com]

TASK [Create nagios admin user] *******************************************************************************
changed: [vmX-gY.lab.workalaya.com]

RUNNING HANDLER [restart apache2] *****************************************************************************
changed: [vmX-gY.lab.workalaya.com]

PLAY RECAP ****************************************************************************************************
vmX-gY.lab.workalaya.com   : ok=5    changed=3    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0
~~~

Try browsing to the WebSVN pages at

~~~url
http://vmX-gY.lab.workalaya.net/viewvc
~~~

and you should be asked for a username and password to be able to view the pages.

### **Review revisions**

ViewVC lets you see easily the changes between versions.

- Browse to <http://vmX-gY.lab.workalaya.net/viewvc/rancid> again, go to routers/ then configs/
- Click on your router file (rtr1-gY.lab.workalaya.net) name. You will get a new screen with title "Log of /routers/configs/rtr1-g1.lab.workalaya.net"
- Look for "Diffs between" at the bottom of the screen.
- Key in version no. i.e 3 and 5 and click "Get Diffs" 
  - This will show you the differences between two separate router configurations.

ViewVC is a convenient way to quickly see differences via a GUI between multiple configuration files. Note, this is a potential security hole so you should limit access to the URL <http://vmX-gY.lab.workalaya.net/viewvc/> using passwords (and SSL) or appropriate access control lists.

---

### **Note**

On the use of hostnames in RANCID vs. IP Addresses
Note: it is also allowed to use IP addresses, and one could also write:

~~~txt
add user 100.68.* lab
add password 100.68.* lab-PW lab-EN
add user rtr1-gY.lab.workalaya.net lab
add password rtr1-gY.lab.workalaya.net lab-PW lab-EN
~~~

---
