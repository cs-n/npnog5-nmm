# **Basic Linux Setup of Virtual Server**

## **Introduction**

### **Goals**

- Initial VM Configuration
- We could do this for you, but it's important to understand how some of this software work with the tools you will be installing this week.

### **Notes**

- Commands preceded with "\$" imply that you should execute the command as a general user - not as root.
- Commands preceded with "#" imply that you should be working as root.
- Commands with more specific command lines (e.g. "rtrX>" or "mysql>") imply that you are executing commands on remote equipment, or within another program.
- If a command line ends with "\\" this indicates that the command continues on the next line and you should treat this as a single line.

---

## **Exercises**

### **Update your software package repository**

Connect to your virtual machine (**vmX-gY.lab.workalaya.net**) as the user **_lab_** and then from the command line:

~~~bash
lab@vmX-gY:~$ sudo apt update
~~~

This might take a few moments if everyone in class is doing this at the same moment.

### **Install the "nano" editor package:**

**NOTE:** Some packages may already be installed. This is OK. Just continue to the next step in the exercises.

~~~bash
lab@vmX-gY:~$ sudo apt install nano
~~~

The _nano_ editor package is simpler to use than _vi_. Try using the editor to create a new file in your **_lab_** home directory:

~~~bash
lab@vmX-gY:~$ cd
lab@vmX-gY:~$ nano newfile.txt
~~~

Type in some text for practice. You can type "ctrl-g" to see a list of nano editor commands, that is "press the ctrl key and the g key. You need to press 'ctrl-x' to exit the help screen.

You can save and exit from the file by typing "ctrl-x, then y" and `<ENTER>` to accept the file name..

### **Setting time to UTC, Updating time and install Network Time Protocol service**

In order to manage and monitor your network it is _critical_ that all devices and servers maintain the same, consistent time. To achieve this you can, for example, select a single time zone, use the _ntpdate_ command to set your server's clock exactly and install the NTP (Network Time Protocol) service to maintain your server's clock with precise time.

First, let's set your server's clock to use UTC time (Coordinated Universal Time). At the command line type:

~~~bash
lab@vmX-gY:~$ sudo dpkg-reconfigure tzdata
~~~

- Scroll to the bottom of the list and select "None of the above"
- Scroll down the list and select "UTC"
- Use the tab key to select "`<Ok>`" and press `<ENTER>`

Now your server is using UTC time. Next be sure the time is precise by using ntpdate. First install ntpdate:

~~~bash
lab@vmX-gY:~$ sudo apt install ntpdate
~~~

Now we'll update our local time against a remote time server:

~~~bash
lab@vmX-gY:~$ sudo ntpdate -s ntp.lab.workalaya.net
~~~

You can always type:

~~~bash
lab@vmX-gY:~$ date
~~~

to see your server's current timezone (UTC, which is technically a standard), date and time.

Finally, let's install the NTP service to ensure that our server's clock maintains precise time.

~~~bash
lab@vmX-gY:~$ sudo apt install ntp ntpstat
~~~

At this point the default configuration should be acceptable for our case. You may wish to read up on ntp upon returning home and edit the file /etc/ntp.conf to select different time servers, or update settings to your local ntp service configuration.

In addition, ntp has been part of several security warnings the past few years. You should sign up for the Ubuntu Security mailing list at:

<https://lists.ubuntu.com/mailman/listinfo/ubuntu-security-announce>

You should do this whether you run _ntp_ or not. And, as ntp is so critical to proper network instrumentation, this is one service that should be run on any server that will be running network monitoring or management software or that will be monitored and on all your network devices.

If you would like to see the status of your local ntp service you can type:

~~~bash
lab@vmX-gY:~$ sudo ntpq -p
~~~

and you should see something like:

~~~bash
     remote           refid      st t when poll reach   delay   offset  jitter
==============================================================================
 0.ubuntu.pool.n .POOL.          16 p    -   64    0    0.000    0.000   0.000
 1.ubuntu.pool.n .POOL.          16 p    -   64    0    0.000    0.000   0.000
 2.ubuntu.pool.n .POOL.          16 p    -   64    0    0.000    0.000   0.000
 3.ubuntu.pool.n .POOL.          16 p    -   64    0    0.000    0.000   0.000
 ntp.ubuntu.com  .POOL.          16 p    -   64    0    0.000    0.000   0.000
*gw.lab.workalay 130.54.208.201   4 u   51   64    1   11.351   -4.360   3.053
~~~

For a reasonable discussion of what this output means see:

<http://tech.kulish.com/2007/10/30/ntp-ntpq-output-explained/>

To see the status of your time synchronization process type:

~~~bash
lab@vmX-gY:~$ ntpstat
~~~

If your clock is properly synchronized you sould see something like:

~~~bash
synchronised to NTP server (100.68.100.254) at stratum 5
   time correct to within 342 ms
   polling server every 64 s
~~~

Your machine will now update it's time against a known good source on a regular basis.

### **Install the postfix mailerver software and some mail utilities**

At the command line type:

~~~bash
lab@vmX-gY:~$ sudo apt install postfix mutt mailutils
~~~

This might take a moment to complete.

Now you will be prompted for set of details. choose the following values and replace **vmX-gY** with your group and vm no.

~~~txt
1. press <OK>
2. Internet Site
3. vmX-gY or default as seen on screen
4. root or leave blank
5. vmX-gY.lab.workalaya.net, vmX-gY, localhost.localdomain, localhost
6. select <No>
7. 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 100.68.Y.0/24
8. 0
9. +
10. all
~~~

Several tools will use the postfix mailserver during the week. In addition, we will use a number of the mail utilities (such as _mail_) and you will use the _mutt_ email reader later in the week.

For fun you can practice restarting a service by restarting the _postfix_ mailserver. Note that the service was started as soon as installation was completed:

~~~bash
lab@vmX-gY:~$ sudo systemctl restart postfix
~~~

You might do this if you changed a _postfix_ configuration file.

To see the status of the running postfix service do:

~~~bash
lab@vmX-gY:~$ sudo systemctl status postfix
~~~

You should see something like this:

~~~bash
● postfix.service - Postfix Mail Transport Agent
   Loaded: loaded (/lib/systemd/system/postfix.service; enabled; vendor preset: enabled)
   Active: active (exited) since Fri 2019-10-25 06:27:26 UTC; 48s ago
  Process: 1953 ExecStart=/bin/true (code=exited, status=0/SUCCESS)
 Main PID: 1953 (code=exited, status=0/SUCCESS)
~~~

With the last few lines that are log file notices for the postfix mail service.

Press 'q' to exit from the status screen.

### **Deliver an Email to Yourself**

To verify that your mail server is working (at least locally) you can do the following:

~~~bash
lab@vmX-gY:~$ echo "My first email" | mail -s "First email" lab@vmX-gY.lab.workalaya.net
~~~

(Replace 'X' and 'Y' with your specific virtual machine information).

And, then to view your email type:

~~~bash
lab@vmX-gY:~$ mutt
~~~

You may see the following:

~~~bash
/home/lab/Mail does not exist. Create it? ([yes]/no):
~~~

Type "yes" and press `<ENTER>` to continue.

Press `<ENTER>` to view the email. To exit type "q" two times to quit.

If for some reason you do not see the mail you can try to do the following and then send the mail message again:

~~~bash
lab@vmX-gY:~$ sudo touch /var/mail/lab
lab@vmX-gY:~$ sudo chown lab:mail /var/mail/lab
~~~

It's important that mail is working on your system as this will be used throughout the week by the network monitoring and management software that you install. If you did not get mail to work please let your instructor know so that the issue can be resolved right away.

### **Viewing log files in real time**

Log files are critical to solve problems. They reside (largely) in the /var/log/ directory.

Some popular log files include:

- /var/log/syslog
- /var/log/apache2/access.log
- /var/log/mail.log

and many more.

To view the last entry in a log file, such as the system log file, type:

~~~bash
lab@vmX-gY:~$ tail /var/log/syslog
~~~

Some log files may require that you use "sudo tail logfilename" to view their contents.

What's more effective is to watch a log file as you perform some action on your system. To do this open another ssh session to your server now, log in as user **_lab_** and in that other window type:

~~~bash
lab@vmX-gY:~$ tail -f /var/log/syslog
~~~

Now in your other window try restarting the ntp service you recently installed:

~~~bash
lab@vmX-gY:~$ sudo systemctl restart ntp
~~~

You should see quite a few log messages appear in your other _ssh_ window. These are real-time messages coming from the ntp service. We'll talk about logging more later in the week, but viewing your log files to debug issues is often the only way to solve a problem.

In the window where you typed "sudo tail -f /var/log/syslog" you can press ctrl-c to exit from the tail command.

### **Practice using the man command**

to get help on command you can use the _man_ command ("man" is short for manual). For instance, to learn more about the _ssh_ command you could do:

~~~bash
lab@vmX-gY:~$ man ssh
~~~

Now you can move around the help screen quickly by using some editing tricks. Note that these tricks work if you are using the _less_ command as well.

Try doing the following:

- Search for “ports” by typing “/ports” – press `<ENTER>`
- Press “n” to go to the next occurrence of “ports” – do this several times.
- Press “N” to search backwards.
- Press “p” to go to the start.
- Search on “/-p” and see what you find.
- Press “h” for all the keyboard shortcuts.
- Press “q” (twice in this case) to quit from the man page.

---
