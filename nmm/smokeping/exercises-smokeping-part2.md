# **Network Management & Monitoring - Smokeping**

## **Introduction**

### **Goals**

- Configure more Targets and Probes

### **Notes**

- Commands preceded with "$" imply that you should execute the command as a general user - not as root.
- Commands preceded with "#" imply that you should be working as root.
- Commands with more specific command lines (e.g. "rtrX>" or "mysql>") imply that you are executing commands on remote equipment, or within another program.
- If a command line ends with "\\" this indicates that the command continues on the next line and you should treat this as a single line.
- References to "Y" represent your group number.

---

## **Exercise - Part II**

### **Add new probes to Smokeping**

The current entry in the Probes file is fine, but if you wish to use additional Smokeping checks you can add them in here and you can specify their default behavior. You can do this, as well, in the Targets file if you wish.

To add a probe to check for HTTP latency as well as DNS lookup latency, create the _Probes_ file and put the following content in that file:

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi files/smokeping/Probes
~~~

~~~txt
*** Probes ***

+ FPing

binary = /usr/bin/fping

+ EchoPingHttp

+ EchoPingHttps

+ DNS
binary = /usr/bin/dig
pings = 5
step = 180
lookup = www.workalaya.net
~~~

The DNS probe will look up the IP address of www.workalaya.net using any other open DNS server (resolver) you specify in the Targets file. You will see this a bit further on in the exercises.

update ansible playbook named **_smokeping.yml_** and run it

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
        - Probes
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

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ ansible-playbook smokeping.yml -t base_config

PLAY [smokeping_hosts] ****************************************************************************************

TASK [Gathering Facts] ****************************************************************************************
ok: [vmX-gY.lab.workalaya.com]

TASK [Smokeping General config] *******************************************************************************
ok: [vmX-gY.lab.workalaya.com] => (item=General)
ok: [vmX-gY.lab.workalaya.com] => (item=Alerts)
changed: [vmX-gY.lab.workalaya.com] => (item=Probes)

RUNNING HANDLER [restart smokeping] ***************************************************************************
changed: [vmX-gY.lab.workalaya.com]

PLAY RECAP ****************************************************************************************************
vmX-gY.lab.workalaya.com   : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
~~~

### **Add HTTP latency checks for the VMs**

Edit the _Targets_ template file again and go to the end of the file:

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi templates/smokeping/Targets
~~~

~~~txt
#
# Local Web server response
#

+HTTP

menu = Local HTTP Response
title = HTTP Response of VMs

{% for host in range(1,4) %}
++vm{{host}}

menu = vm{{host}}
title = vm{{host}}-g{{class_group}} HTTP response time
probe = EchoPingHttp
host = vm{{host}}-g{{class_group}}.lab.workalaya.net

{% endfor %}
~~~

You could also use the "probe = EchoPingHttp" statement once for vm1, and then this would be the default probe until another "probe = " statement is seen in the Targets file.

You can add more host entries if you wish, or you could consider checking the latency on remote machines - these are likely to be more interesting. Machines such as your own publicly accessible servers are a good choice, or, perhaps other web servers you use often (Google, Yahoo, Government pages, stores, etc.?).

For example, consider adding something like this at the bottom of the Targets file:

~~~txt
#
# Remote Web server response
#

+HTTPSRemote

menu = Remote HTTPS Response
title = HTTPS Response Remote Machines

++google

menu = Google
title = Google.com HTTPS response time
probe = EchoPingHttps
host = www.google.org

++workalaya

menu = Workalaya R and D
title = workalaya.net HTTPS response time
probe = EchoPingHttps
host = workalaya.net

++facebook

menu = Facebook
title = Facebook HTTPS response time
probe = EchoPingHttps
host = www.facebook.com
~~~

Add your own hosts that you use at your organization to the list of Remote Web Servers.

Now run ansible playbook to update _Smokeping_ configuration

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

you can view the results of your changes by going to:

~~~url
http://vmX-gY.lab.workalaya.net/smokeping/smokeping.cgi
~~~

### **Add DNS latency checks**

At the end of the Targets file we are going to add some entries to verify the latency from our location to remote recursive DNS servers to look up an entry for workalaya.net.

You would likely substitute an important address for your institution in the Probes file instead. In addition, you can change the address you are looking up inside the Targets file as well. For more information see:

<http://oss.oetiker.ch/smokeping/probe/DNS.en.html> and <http://oss.oetiker.ch/smokeping/probe/index.en.html>

Now edit the Targets file again. Be sure to go to the end of the file:

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi templates/smokeping/Targets
~~~

~~~txt
#
# Sample DNS probe
#

+DNS

probe = DNS
menu = DNS Latency
title = DNS Latency Probes

++LocalDNS1
menu = ns1.lab.workalaya.net
title =  DNS Delay for local DNS Server on ns1.lab.workalaya.net
host = ns1.lab.workalaya.net

++Quad9
menu = 9.9.9.9
title = DNS Latency for dns.quad9.net
host = dns.quad9.net

++CloudflareDNS
menu = 1.1.1.1
title = DNS Latency for one.one.one.one
host = one.one.one.one

++GoogleA
menu = 8.8.8.8
title = DNS Latency for google-public-dns-a.google.com
host = google-public-dns-a.google.com

++GoogleB

menu = 8.8.4.4
title = DNS Latency for google-public-dns-b.google.com
host = google-public-dns-b.google.com

++OpenDNSA

menu = 208.67.222.222
title = DNS Latency for resolver1.opendns.com
host = resolver1.opendns.com

++OpenDNSB

menu = 208.67.220.220
title = DNS Latency for resolver2.opendns.com
host = resolver2.opendns.com
~~~

Now run ansible playbook to update _Smokeping_ configuration

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

you can view the results of your changes by going to:

~~~url
http://vmX-gY.lab.workalaya.net/smokeping/smokeping.cgi
~~~

### **MultiHost graphing**

Once you have defined a group of hosts under a single probe type in your /etc/smokeping/config.d/Targets file, then you can create a single graph that will show you the results of all smokeping tests for all hosts that you define. This has the advantage of letting you quickly compare, for example, a group of hosts that you are monitoring with the FPing probe.

The MultiHost graph function in Smokeping has difficult syntax - pay close attention!

To create a MultiHost graph first edit the file Targets:

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi templates/smokeping/Targets
~~~

We will create a MultiHost graph for the DNS Latency probes we just added. To do this go to the end of the Targets file and add:

~~~txt
#
# Multihost Graph of all DNS latency checks
#

++MultiHostDNS

menu = MultiHost DNS
title = Consolidated DNS Responses
host = /DNS/LocalDNS1 /DNS/Quad9 /DNS/CloudflareDNS /DNS/GoogleA /DNS/GoogleB /DNS/OpenDNSA /DNS/OpenDNSB
~~~

Now run ansible playbook to update _Smokeping_ configuration

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

If this fails you almost certainly have an error in the entries. If you cannot figure out what the error is (remember to try "tail /var/log/syslog" first!) ask your instructor for some help.

you can view the results of your changes by going to:

~~~url
http://vmX-gY.lab.workalaya.net/smokeping/smokeping.cgi
~~~

You can add MultiHost graphs for any other set of probe tests (FPing, EchoPingHttp) that you have configured. You must add the MultiHost entry at the end of a probe section. If you don't understand how this works you can ask your instructors for help.

### **Send Smokeping alerts**

Update your device entries to include a line that reads:

~~~txt
alerts = alertName1, alertName2, etc, etc...
~~~

For instance, the alert named, "someloss" has already been defined in the file Alerts:

To read about Smokeping alerts and what they are detecting, how to create your own, etc. see:

<http://oss.oetiker.ch/smokeping/doc/smokeping_config.en.html>

and at the bottom of the page is a section titled _\*\*\* Alerts \*\*\*_

To place some alert detection on some of your hosts, open the Targets file:

~~~bash
(venv) vmX-gY@ansible-host:~/ansible-playbook$ vi templates/smokeping/Targets
~~~

and go near the start of the file where we defined our hosts. Just under the "host =" line add another line that looks like this:

~~~txt
alerts = someloss
~~~

So, for example, the entry for all VMx on campusY would look like this:

~~~txt
{% for host in range(1,4) %}
++vm{{host}}

menu = vm{{host}}
title = Group {{class_group}} Server {{host}}
host = vm{{host}}-g{{class_group}}.lab.workalaya.net
alerts = someloss

{% endfor %}
~~~

If you want to add an alerts option to other hosts go ahead. Once you are done save and exit from the Targets file and then run ansible playbook:

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

If any of the hosts that have the "alerts = " option set meet the conditions to set off the alert, then an email will arrive to the lab user's mailbox on the Smokeping server machine (localhost). It's not likely that an alert will be set off for most machines. To check you can read the email for the lab user by using an email client like "mutt" -

~~~bash
lab@vmX-gY:~$ mutt
~~~

Say yes to mailbox creation when prompted, then see if you have email from the smokeping-alerts@localhost user. You probably will not. To exit from Mutt press "q".

---

### **Slave instances - Informational Only**

This is a description only for informational purposes in case you wish to attempt this type of configuration once the workshop is over.

The idea behind this is that you can run multiple smokeping instances at multiple locations that are monitoring the same hosts and/or services as your master instance. The slaves will send their results to the master server and you will see these results side-by-side with your local results. This allows you to view how users outside your network see your services and hosts.

This can be a powerful tool for resolving service and host issues that may be difficult to troubleshoot if you only have local data.

Graphically this looks this:

~~~flowchart
          [slave 1]     [slave 2]      [slave 3]
                |             |              |
                +-------+     |     +--------+
                        |     |     |
                        v     v     v
                        +---------------+
                        |    master     |
                        +---------------+
~~~

You can see example of this data here:

<http://oss.oetiker.ch/smokeping-demo/>

Look at the various graph groups and notice that many of the graphs have multiple lines with the color code chart listing items such as "median RTT from freddie" - These are not MultiHost graphs, but rather graphs with data from external smokeping servers.

To configure a smokeping master/slave server you can see the documentation here:

<http://oss.oetiker.ch/smokeping/doc/smokeping_master_slave.en.html>

---
