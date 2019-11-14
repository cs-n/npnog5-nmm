# **Monitoring Netflow with NFsen**

## **Introduction**

### **Goals**

- Learn how to install the nfdump and NfSen tools

### **Notes**

- Commands preceded with "$" imply that you should execute the command as a general user - not as root.
- Commands preceded with "#" imply that you should be working as root.
- Commands with more specific command lines (e.g. "rtr1-gY>" or "mysql>") imply that you are executing commands on remote equipment, or within another program.

---

## **Configure Your Collector**

### **Install NFDump and associated software**

NFdump is part of the Netflow flow collector tools, which includes:

nfcapd, nfdump, nfreplay, nfexpire, nftest, nfgen

There is a package in Ubuntu, but it's too old - so we're going to build it from source. First, check you have the build tools and dependencies:
