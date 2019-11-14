# **Git and GitHub** #

## **1. Objective** ##

Get familiar with git and github

---

## **2. Get a GitHub account** ##

Go to [GitHub.com](https://github.com) and create your GitHub account

---

## **3. Git Setup on linux machine** ##

### **3. 1. Conect** ###

Login to _**ansible-gY.lab.workalaya.net**_

Make sure you connect to this as your normal ("vmX-gY") user. You will use "sudo" where specific commands need to be run as root. It is good practice to do this.

### **3. 2. Install git package** ###

you do not need perform this step as _**git**_ package has already been installed

~~~bash
vmX-gY@ansible-gY:~$ sudo apt-get install git
~~~

### **3. 3. Configure git** ###

Set up git with your user name and email.

~~~bash
vmX-gY@ansible-gY:~$ git config --global user.name "Your name here"
vmX-gY@ansible-gY:~$ git config --global user.email "your_email@example.com"
~~~

### **3. 4. Generate SSH key for _vmX-gY_ user** ###

Generate SSH key

~~~bash
vmX-gY@ansible-gY:~$ ssh-keygen -t rsa -C "NMM lab key for npNOG5"
Generating public/private rsa key pair.
Enter file in which to save the key (/home/vmX-gY/.ssh/id_rsa): <Press Enter>
Enter passphrase (empty for no passphrase): <Press Enter>
Enter same passphrase again: <Press Enter>
Your identification has been saved in /home/vmX-gY/.ssh/id_rsa.
Your public key has been saved in /home/vmX-gY/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:UOy7725TVUWeef3ywOdHZMDq8x+yikUKbSR+dSpW+Oo NMM lab key for npNOG5
The key's randomart image is:
+---[RSA 2048]----+
|       ..    ...+|
|       .. .   .o=|
|      .o o o o +*|
|      ..= + +..oo|
|       oSB = .+ +|
|        * = +  B |
|         + o + .+|
|        o =   + o|
|         E+o.. ..|
+----[SHA256]-----+
~~~

### **3. 5. Copy your public key** ###

Copy your public key (the contents of the newly-created id_rsa.pub file) into your clipboard.

~~~bash
vmX-gY@ansible-gY:~$ cat .ssh/id_rsa.pub
~~~

and copy its content to GitHub Account

---

## **4. Paste your ssh public key into your github account settings** ##

- Go to your github [Account Settings](https://github.com/settings/profile)
- Click “[SSH and GPG Keys](https://github.com/settings/ssh)” on the left.
- Click “New SSH Key” on the right.
- Add a label (like “My laptop”) and paste the public key into the big text box.
- In a terminal/shell, type the following to test it:

  ~~~bash
  vmX-gY@ansible-gY:~/$ ssh -T git@github.com
  ~~~

- If it says something like the following, it worked:

  ~~~txt
  Hi username! You've successfully authenticated, but Github does not provide shell access.
  ~~~

---

## **5. Start a new git repository** ##

Your first instinct, when you start to do something new, should be git init. You’re starting to write a new paper, you’re writing a bit of code to do a computer simulation, you’re mucking around with some new data … anything: think git init.

### **5. 1. A new repo from scratch** ###

Say you’ve just got some data from a collaborator and are about to start exploring it.

- Create a directory to contain the project.

  ~~~bash
  vmX-gY@ansible-gY:~/$ mkdir git-exercise1
  ~~~

- Go into the new directory.
  
  ~~~bash
  vmX-gY@ansible-gY:~/$ cd git-exercise1
  ~~~

- Type git init.

  ~~~bash
  vmX-gY@ansible-gY:~/git-exercise1$ git init .
  ~~~

- Create some files.

  ~~~bash
  vmX-gY@ansible-gY:~/git-exercise1$ vi readme

  this is a readme file.
  ~~~

  save and exit

- Type git add to add the files.

  ~~~bash
  vmX-gY@ansible-gY:~/git-exercise1$ git add .
  ~~~

- Type git commit.

  ~~~bash
  vmX-gY@ansible-gY:~/git-exercise1$ git commit
  ~~~

  it prompts for commit message, type commit message
  
  ~~~txt
  Initial Commit
  ~~~

  save and exit, should see similar output

  ~~~git
  [master (root-commit) c362bef] Initial Commit
  1 file changed, 1 insertion(+)
  create mode 100644 readme
  ~~~

### **5. 2. A new repo from an existing project** ###

Say you’ve got an existing project that you want to start tracking with git.

- First we create project directory and some files as

  ~~~bash
  vmX-gY@ansible-gY:~/git-exercise1$ cd
  vmX-gY@ansible-gY:~$ mkdir git-exersise2
  vmX-gY@ansible-gY:~$ cd git-exersise2
  vmX-gY@ansible-gY:~/git-exercise1$ cat > readme << _EOF_
  this is a readme file.
  _EOF_
  ~~~

- Type git init.

  ~~~bash
  vmX-gY@ansible-gY:~/git-exercise2$ git init .
  ~~~

- Type git add to add the files.

  ~~~bash
  vmX-gY@ansible-gY:~/git-exercise2$ git add .
  ~~~

- Type git commit.

  ~~~bash
  vmX-gY@ansible-gY:~/git-exercise2$ git commit
  ~~~

  it prompts for commit message, type commit message
  
  ~~~txt
  Initial Commit
  ~~~

  save and exit, should see similar output

  ~~~git
  [master (root-commit) c362bef] Initial Commit
  1 file changed, 1 insertion(+)
  create mode 100644 readme
  ~~~

---

## **6 Connect it to github** ##

You’ve now got a local git repository. You can use git locally, like that, if you want. But if you want the thing to have a home on github, do the following.

- Go to [github](https://github.com/).
- Log in to your account.
- Click the [new repository](https://github.com/new) button in the top-right.
  - give repository name as `npnog5-nmm-first`
  - select `private` as repository type
  - there is an option to initialize the repository with a README file, but don’t check this option.
- Click the “Create repository” button.
- Click `SSH` button

Now, follow the second set of instructions, “Push an existing repository from the command line”

~~~bash
vmX-gY@ansible-gY:~/git-exercise2$ git remote add origin git@github.com:username/npnog5-nmm-first.git
vmX-gY@ansible-gY:~/git-exercise2$ git push -u origin master
~~~

Now explore your repository on GitHub.

---
