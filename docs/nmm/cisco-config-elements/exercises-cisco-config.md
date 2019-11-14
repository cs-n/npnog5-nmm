# Cisco Config Elements

## **Introduction**

### **Goals**

* Learn the basic set of IOS commands required to enable SSH on your Cisco Switch or Router

### **Notes**

* Commands preceded with "$" imply that you should be working as a regular user.
* Commands preceded with "#" imply that you should be working as root.
* Commands with more specific command lines (e.g. "rtrX>" or "mysql>") imply that you are executing commands on remote equipment, or within another program.
* If a command line ends with "\\" this indicates that the command continues on the next line and you should treat this as a single line.
* References to "N" represent your group number.

---

## **Exercises Part I**

### **Work as a group**

Each group has 2 network devices:

* **rtr1-gY.lab.workalaya.net**

Each of these devices has the user **_lab_** configured with both a log in password and and enable password. At this time telnet is enabled on these devices and ssh is not yet configured.

As a group you need to update all network devices so that when you finish this lab you can log in as the user **_lab_** only using ssh and with the password given in class.

### **Connect to your router**

First, log in to your virtual machine (**vmX-gY.lab.workalaya.net**).

Next, connect to the network device on which you will be working:

~~~bash
lab@vmX-gY:~$ telnet rtr1-gY.lab.workalaya.net

username: lab
password: <GIVEN IN CLASS>
~~~

Display information about your network device

~~~cisco
rtr1-gY> enable
Password:                                 (password given in class)
rtr1-gY# show run                         (space to continue)
rtr1-gY# show int FastEthernet0/0         (or any other interface that is up)
rtr1-gY# show ?                           (lists all options)
~~~

**Note:** Press "q" to exit from information screen before reaching the end if you wish, otherwise press the `<SPACE BAR>` to move scroll through the information until the end.

### **Configure your router to only use SSH**

These steps will do the following:

* Create an ssh key for your router
* Create an encrypted password for the user lab
* Encrypt the enable password
* Turn off telnet (unencrypted) access to your router
* Turn on SSH (version 2) access to your router

You should be connected to your router and at the enable prompt. The prompt will look something like:

~~~cisco
rtr1-gY#
~~~

At this prompt do the following:

~~~cisco
rtr1-gY# configure terminal
rtr1-gY(config)# aaa new-model
rtr1-gY(config)# ip domain-name lab.workalaya.net
rtr1-gY(config)# crypto key generate rsa

Choose the size of the key modulus in the range of 360 to 4096 for your
  General Purpose Keys. Choosing a key modulus greater than 512 may take
  a few minutes.

How many bits in the modulus [512]: 2048
% Generating 2048 bit RSA keys, keys will be non-exportable...
[OK] (elapsed time was 11 seconds)
~~~

Wait for the key to generate. You can now specify passwords and they will be encrypted. First let's remove our lab user temporarily, then we'll recreate the user.

**CRITICAL! CRITICAL! CRITICAL!**

PLEASE DO NOT USE ANYTHING OTHER THAN THE CLASS PASSWORD AND THE USER "_**lab**_"

If you use other usernames or passwords you will break exercises for other participants of the class during the week. Thank you!

~~~cisco
rtr1-gY(config)# no username lab
rtr1-gY(config)# username lab secret 0 <CLASS PASSWORD>
~~~

(First password used to log in on the router).

The **_lab_** user's password (of `<CLASS PASSWORD>`) is encrypted. Next let's encrypt the enable password as well:

~~~cisco
rtr1-g1(config)#no enable password
rtr1-gY(config)# enable secret 0 <CLASS ENABLE PASSWORD>
~~~

(Password used after you type `enable` on the router command line.)

Now we'll tell our router to only allow SSH connections on the 5 defined consoles (vty 0 through 4):

~~~cisco
rtr1-gY(config)# line vty 0 4
rtr1-gY(config-line)# transport input ssh
rtr1-gY(config-line)# exit
~~~

This drops us out of the "line" configuration mode and back in to the general configuration mode. Now we'll tell the router to log SSH-related events and to only allow SSH version 2 connections:

~~~cisco
rtr1-gY(config)# ip ssh logging events
rtr1-gY(config)# ip ssh version 2
~~~

Now exit from configuration mode:

~~~cisco
rtr1-gY(config)# exit
~~~

And, write these changes to the routers permament configuration:

~~~cisco
rtr1-gY# write memory
~~~

Ok. That's it. You can no longer use telnet to connect to your router. You must connect using SSH with the user **_lab_** and password `<CLASS PASSWORD>`. The enable password is `<CLASS ENABLE PASSWORD>`

Naturally in a real-world situation you would use much more secure passwords.

Before you exit your Telnet session be sure to test ssh connectivity from another PC in your group (or, open another terminal window). Do this in case you made a mistake to avoid locking yourself out of your router.

First, try connection again with telnet from your virtual machine:

~~~bash
lab@vmX-gY:~$ telnet rtr1-gY.lab.workalaya.net
~~~

What happens? You should see something like:

~~~bash
Trying 100.68.100.1...  (for example only)
telnet: Unable to connect to remote host: Connection refused
~~~

Now try connecting with SSH:

~~~bash
lab@vmX-gY:~$ ssh lab@rtr1-gY.lab.workalaya.net
~~~

You should see something looks similar to this:

~~~bash
The authenticity of host 'rtr1-g1.lab.workalaya.net (100.68.100.1)' can't be established.
RSA key fingerprint is SHA256:9HYY8A9aEJtQz7+Vn8MzFlomLCkUNtboEcQ8ms/BygM.
Are you sure you want to continue connecting (yes/no)?
~~~

Enter in "yes" and press ENTER to continue...

Now you'll see the follwoing:

~~~bash
Warning: Permanently added 'rtr1-g1.lab.workalaya.net,100.68.100.1' (RSA) to the list of known hosts.
password:
~~~

Enter in the `<CLASS PASSWORD>`

You will end up on a prompt like:

~~~cisco
rtr1-gY>
~~~

(If you receive an error while trying to connect see the _Troubleshooting_ Section below)

Type "enable" to allow us to execute privileged commands:

~~~cisco
rtr1-gY> enable
Password: <CLASS ENABLE PASSWORD>
rtr1-gY#
~~~

Now let's view the current router configuration:

~~~cisco
rtr1-gY# show running
~~~

Press the space bar to continue. Note some of the entries like:

~~~cisco
enable secret 5 $1$wGtR$bKZqFAPXYjmV6OrLCC3hP.
.
.
.
username lab secret 5 $1$DQAd$qB0su4clCXPaSE7miLVcB0
.
.           (lots of lines down)
.
line vty 0 4
 exec-timeout 0 0
 transport preferred none
 transport input ssh
~~~

You can see that both the enable password and the password for the user **_lab_** have been encrypted. This is a good thing.

Now you should exit the router interface to complete this exercise:

~~~cisco
rtr1-gY# exit
~~~

And, if you still have your older Telnet session in another window running be sure to exit from that as well.

### **Troubleshooting**

#### **"no matching key exchange method found"**

If you attempted to log in and received a message like this:

~~~bash
lab@vm1-g1:~$ ssh rtr1-g1.lab.workalaya.net
Unable to negotiate with 100.68.100.1 port 22: no matching key exchange method found. Their offer: diffie-hellman-group1-sha1
~~~

The version of software on your network device is using older, weaker encryption ciphers. In order to support this there are a couple of options we can consider:

You can override ssh refusing to connect to older, vulnerable encrption key exchange algorithm by running the ssh comand like this

~~~bash
lab@vmX-gY:~$ ssh -oKexAlgorithms=+diffie-hellman-group1-sha1 lab@rtr1-gY.lab.workalaya.net
~~~

...but that is painful. Let's update your virtual machine's ssh client configuration to allow for this older key exchange. We'll do this by updating your machine's system-wide ssh-client configuration file. Follow these steps:

~~~bash
lab@vmX-gY:~$ sudo vi /etc/ssh/ssh_config
~~~

At the very end of the file add the following line:

~~~bash
KexAlgorithms +diffie-hellman-group1-sha1
~~~

Save the file and exit.

Now try connecting to your network device again:

~~~bash
lab@vmX-gY:~$ ssh lab@rtr1-gY.lab.workalaya.net
~~~

#### **"no matching cipher found"**

With newer versions of Ubuntu ssh you may get another error:

~~~bash
lab@vm1-g1:~$ ssh rtr1-g1.lab.workalaya.net
Unable to negotiate with 100.68.100.1 port 22: no matching cipher found. Their offer: aes128-cbc,3des-cbc,aes192-cbc,aes256-cbc
~~~

Again, this is because the network device is using older ciphers which are not enabled by default in newer versions of OpenSSH.

You can add `-oCiphers=+aes256-cbc` to the ssh command line, but it is simpler to edit the configuration file as follows:

~~~bash
lab@vmX-gY:~$ sudo vi /etc/ssh/ssh_config
~~~

At the very end of the file add this line:

~~~bash
Ciphers +aes256-cbc
~~~

Save the file and exit, then try connecting to your network device again:

~~~bash
lab@vmX-gY:~$ ssh lab@rtr1-gY.lab.workalaya.net
~~~

### **NOTES**

1. If you are locked out of your router after this exercise let your instructor know and they can reset your network device's configuration back to its original state.
2. Please only do this exercise once. If multiple people do this exercise it's very likely that access to the router will be broken.
3. During the week you will configure items such as SNMP, Netflow and more on your local network devices. From now on you can simply connect to the device directly from your laptop or desktop machine using SSH.

---

## **Exercises - Part 2: NTP Configuration**

### **Configure NTP and Timezone**

Perhaps you can select another person in your group to execute the following steps to allow them to practice.

Your first step is to connect to your router:

~~~bash
lab@vmX-gY:~$ ssh lab@rtr1-gY.lab.workalaya.net
~~~

Now we will enable the Network Time Protocol so that we can synchronize your router's time with your PCs time so that all devices on our local network will have the same time. To do this follow these steps:

~~~cisco
rtr1-gY> enable
Password:
rtr1-gY# configure terminal
rtr1-gY(config)# ip name-server 100.68.100.244 100.68.100.245 100.68.100.254
rtr1-gY(config)# ip domain-lookup
rtr1-gY(config)# ntp server pool.ntp.org
~~~

At this point you may see something like this:

~~~cisco
rtr1-gY(config)#ntp server pool.ntp.org
Translating "pool.ntp.org"...domain server (100.68.100.244) [OK]
~~~

Wait a few moments for this to complete and then you can continue.

~~~cisco
rtr1-gY(config)# no clock timezone
rtr1-gY(config)# exit
rtr1-gY# write memory
~~~

This uses the NTP time servers run by ntp.org and should end up selecting machines that are geographically near to you. This, also, indicates that you wish to use UTC time (same as GMT time) for this router.

To verify NTP status, NTP server associations and the reported time on your router:

~~~cisco
rtr1-gY# show ntp status
~~~

After some time you will see something like (you may see "unsynchronized" for a while):

~~~cisco
rtr1-gY#show ntp status
Clock is synchronized, stratum 5, reference is 100.68.100.254
nominal freq is 250.0000 Hz, actual freq is 250.0000 Hz, precision is 2**18
ntp uptime is 6500 (1/100 of seconds), resolution is 4000
reference time is E15D430E.3382AA55 (09:46:54.201 UTC Fri Oct 25 2019)
clock offset is 42.6024 msec, root delay is 413.38 msec
root dispersion is 4204.22 msec, peer dispersion is 187.56 msec
loopfilter state is 'CTRL' (Normal Controlled Loop), drift is 0.000000000 s/s
system poll interval is 64, last update was 63 sec ago.
~~~

... and to see the NTP server associations:

~~~cisco
rtr1-gY# show ntp associations

  address         ref clock       st   when   poll reach  delay  offset   disp
*~100.68.100.254  130.54.208.201   4     32     64     7  4.000  42.602  1.883
 * sys.peer, # selected, + candidate, - outlyer, x falseticker, ~ configured
~~~

... and, finally, to see your router's current time:

~~~cisco
rtr1-gY# show clock
~~~

You should see something like:

~~~cisco
09:51:10.432 UTC Fri Oct 25 2019
~~~

Now you can exit from your router:

~~~cisco
rtr1-gY# exit
~~~

Make sure your team finishes working on the other devices in your group. If anyone has problems connecting to a device see the **_Troubleshooting_** section above.

---
