# **Ansible Install and Setup** #

## **1. Objective** ##

This exercise will get ansible up and running, to the point where it is able to run commands on all the remote systems you are managing.

---

## **2. Initial setup** ##

### **2. 1. Conect** ###

Login to _**ansible-gY.lab.workalaya.net**_

Make sure you connect to this as your normal ("vmX-gY") user. You will use "sudo" where specific commands need to be run as root. It is good practice to do this.

### **2. 2. Upload SSH key of control machine user to our virtual machine** ###

Upload SSH key

~~~bash
vmX-gY@ansible-gY:~$ ssh-copy-id lab@vmX-gY.lab.workalaya.net
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/vmX-gY/.ssh/id_rsa.pub"
The authenticity of host 'vmX-gY.lab.workalaya.net (100.68.Y.21)' can't be established.
ECDSA key fingerprint is SHA256:joFwxYalAr4kaS5RbHi1m8tqd0LlmVocWYeBJvpnb2I.
Are you sure you want to continue connecting (yes/no)? yes
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
lab@vmX-gY.lab.workalaya.net's password:

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'lab@vmX-gY.lab.workalaya.net'"
and check to make sure that only the key(s) you wanted were added.

~~~

Check if we can login without using password

~~~bash
vmX-gY@ansible-gY:~$ ssh lab@vmX-gY.lab.workalaya.net
~~~

### **2. 2. Install ansible package** ###

~~~bash
vmX-gY@ansible-gY$ cd
vmX-gY@ansible-gY$ mkdir ansible-playbook
vmX-gY@ansible-gY$ cd ansible-playbook
vmX-gY@ansible-gY:~/ansible-playbook$ python3 -m venv venv
vmX-gY@ansible-gY:~/ansible-playbook$ source venv/bin/activate
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ pip install ansible
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ echo "venv" > .gitignore
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ git init
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ git add .
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ git commit -am "Initial Commit"
~~~

### **2. 3. Create new GitHub repository** ###

From now on everything we do anythig related to ansible we will track that using git

- Go to [github](https://github.com/).
- Log in to your account.
- Click the [new repository](https://github.com/new) button in the top-right.
  - give repository name as `npnog5-nmm-ansible-playbook`
  - select `private` as repository type
  - there is an option to initialize the repository with a README file, but don’t check this option.
- Click the “Create repository” button.
- Click `SSH` button

Now, follow the second set of instructions, “Push an existing repository from the command line”

~~~bash
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ git remote add origin git@github.com:username/npnog5-nmm-first.git
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ git push -u origin master
~~~

### **2. 4. Configure ansible** ###

Cerate ansible config file "**ansible.cfg**"

~~~bash
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ vi ansible.cfg
~~~

Add following content in "**ansible.cfg**"

~~~txt
[defaults]
inventory = inventory

retry_files_save_path = ./retry/

host_key_checking = False

local_tmp = ./tmp/
~~~

Save and exit for vi editor

~~~bash
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ git add .
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ git commit -am "add ansible.cfg"
~~~

### **2. 5. Create inventory** ###

Now you need to list all your other hosts in the inventory: that is, the machines you are going to manage using ansible.

You need to edit the file **~/ansible-playbook/inventory/hosts**, for example:

~~~bash
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ mkdir inventory
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ vi inventory/hosts
~~~

Add the full hostnames of the other hosts you have, not including the master host where you are running ansible.

~~~txt
vmX-gY.lab.workalaya.net ansible_ssh_user=lab
~~~

~~~bash
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ git add .
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ git commit -am "add inventory/host"
~~~

---

## **3. Getting ansible to connect** ##

Probably the hardest part of working with ansible is getting it to connect to your hosts. After that it's plain sailing :-)

There is a module called "**ping**" which you can use to test the connections. It does nothing but respond with a "**pong**".

So now try the following command:

~~~bash
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ ansible all -m ping
~~~

What this means is:

- Connect to all hosts listed in your inventory
- Run the module (-m) called "**ping**" on those hosts

If you see output similar to following your host is ready to manage using ansible.

~~~txt
vmX-gY.lab.workalaya.net | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
~~~

Very likely you are going to see an error like this:

~~~txt
vmX-gY.lab.workalaya.net | UNREACHABLE! => {
    "changed": false,
    "msg": "Failed to connect to the host via ssh: Warning: Permanently added 'vmX-gY.lab.workalaya.net,100.68.Y.21' (ECDSA) to the list of known hosts.\r\nlab@vmX-gY.lab.workalaya.net: Permission denied (publickey,password).",
    "unreachable": true
}
~~~

or

~~~txt
vmX-gY.lab.workalaya.net | FAILED => SSH encountered an unknown error during the
connection. We recommend you re-run the command using -vvvv, which will
enable SSH debugging output to help diagnose the issue
~~~

So let's do as it suggests, and see if that gives some more information. To make the output easier to read, you can tell ansible to connect to only a single host instead of "all".

~~~bash
ansible vmX-gY.lab.workalaya.net -m ping -vvvv
~~~

### **3.1 Key problems** ###

Do you see an error like this?

~~~txt
...
debug1: No more authentication methods to try.
Permission denied (publickey,password).
~~~

Then it means that it tried to use public key authentication, but failed.

Are you able to use ssh directly at the command line to login to the other host?

~~~bash
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ ssh vmX-gY.lab.workalaya.net
~~~

If not, then you need to debug this problem.

- Did you have Agent Forwarding enabled when you connected to your master ansible host? If not, you will need to disconnect and reconnect with agent forwarding.
- Does your public key exist in /home/lab/.ssh/authorized_keys on the host you are connecting to?
- Do that file and the enclosing .ssh directory have the correct permissions? (Must not be world-writeable or group-writeable)

### **3.2 The shell module** ###

The "shell" module gives you a simple way to run commands on a remote host or hosts. Try it:

~~~bash
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ ansible all -m shell -a 'ls /'
~~~

Did it connect to all hosts? Did it give a directory listing from each host?

Don't move on until the "ping" and "shell" modules are working. Ask for help from an instructor if you need it.

---

## **4. Running commands as root** ##

The commands you have tried so far don't need to run with root privileges on the target system, but most system adminstration commands do.

Try the following command, which shows the content of a protected file containing password hashes:

~~~bash
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ ansible all -m shell -a 'cat /etc/shadow'
~~~

You should get responses like this (in red, if your terminal supports it):

~~~bash
vmX-gY.lab.workalaya.net | FAILED | rc=1 >>
cat: /etc/shadow: Permission denied non-zero return code

~~~

So really, we want to run this command as the "root" user. Try it:

~~~bash
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ ansible all -m shell -a 'cat /etc/shadow' -u root
~~~

Did it work? If so, great! You can skip to the next section.

If not: there is a workaround, because you can get ansible to use "sudo" on the remote system to get root. Try this:

~~~bash
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ ansible all -m shell -a 'cat /etc/shadow' -bK
~~~

Be careful of letter case in the flags: small "b" means use sudo, large "K" means prompt for the password which sudo requires.

Did that work? If not, again ask for help.
<!--
However this is still pretty inconvenient because we don't want to be prompted for a password every time we connect. Really we want to put our ssh public key in /root/.ssh/authorized_keys on every target system, so that we can login directly as the "root" user, bypassing sudo.

You can do this by hand, but this is the sort of system administration task which ansible is perfectly suited for, so let's get ansible to make the change for us!

First, we need to ensure the /root/.ssh directory exists, and create it if not. Run the following:

ansible all -m file -a 'path=/root/.ssh state=directory owner=root group=root mode=700' -bK
This means:

Connect to all hosts in the inventory module
Run the file module
With the given arguments: /root/.ssh should exist and should be a directory with the given permissions
-sK (small s, large K) means to use sudo and prompt for password
Did it complete successfully? This is an idempotent operation, so you can run it more than once and the subsequent runs won't change anything.

Now we need to copy your public key across:

ansible all -m copy -a 'src=/home/sysadm/.ssh/authorized_keys dest=/root/.ssh/authorized_keys owner=root group=root mode=644' -sK
You are using a new module: the copy module copies a file from the local system (the one running ansible) to the remote system(s).

Finally, check you can login directly as "root":

ansible all -m shell -a 'cat /etc/shadow' -u root
If this works, you have sorted out all your ansible authentication and are good to continue.
-->

---

## **5. Further steps** ##

### **5. 1. Inventory variables** ###

It's still a bit inconvenient to have to type sudo password every time we connect, so let's make ansible remember that.

Here's one way to do it. Edit the inventory file (remember it's **~/ansible-playbook/inventory/hosts**) and add a setting to every host like this:

~~~txt
vmX-gY ansible_ssh_user=lab ansible_become_pass=npNOG5nmm
~~~

Now see that you can run commands as root without the sudo password prompt:

~~~bash
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ ansible all -m shell -a 'cat /etc/shadow' -b
~~~

~~~bash
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ git add .
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ git commit -am "updated inventory/host"
~~~

### **5. 2. Ansible documentation** ###

It's important to be able to locate the ansible documentation. You can find it at docs.ansible.com;

Find your way to the Module Index and look for documentation for the "file" and "copy" modules which you have already used.

You have now completed this exercise!

---

## **6 Additional information** ##

THIS SECTION IS FOR INFORMATION ONLY - you don't need to do the following.

### **6. 1. Newer versions of ansible** ###

If you need upgrade or install newer version of ansilbe, do as follows:

~~~bash
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ pip install --upgrade ansible
~~~

### **6. 2. Password authentication** ###

It is possible to use ansible without ssh keys. This may be useful if you are unable to use keys in your environment for some reason.

You need the -k flag to prompt for the password, and to install the sshpass helper program.

~~~bash
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ ansible all -m ping -k
SSH password: <type the password here>
vmX-gY.lab.workalaya.net | FAILED! => {
    "msg": "to use the 'ssh' connection type with passwords, you must install the sshpass program"
}

(venv) vmX-gY@ansible-gY:~/ansible-playbook$ sudo apt-get install sshpass
...
(venv) vmX-gY@ansible-gY:~/ansible-playbook$ ansible all -m ping -k
SSH password: <type the password here>
vmX-gY.lab.workalaya.net | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
~~~

You can also combine the sudo flags (so you get -bkK), and give -u `<username>` to give the username to login as, if this is not the same as the local user name.

However this is inconvenient because every time you run ansible you need to provide the flags and the passwords. It is much better to set up SSH key authentication with agent forwarding, so that your user is able to login directly as "root" on the target systems.

---
