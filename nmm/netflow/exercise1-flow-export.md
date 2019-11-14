
# **Monitoring Netflow with NfSen**

## **Introduction**

### **Goals**

- Learn how to export flows from your rtr1-gY router

### **Notes**

- Commands preceded with "$" imply that you should execute the command as a general user - not as root.
- Commands preceded with "#" imply that you should be working as root.
- Commands with more specific command lines (e.g. "rtr1-gY>" or "mysql>") imply that you are executing commands on remote equipment, or within another program.

---

## **Export flows from rtr1-gY**

You will configure your router to export flows to the database (srv1-gY) server in your group.

~~~bash
lab@srv1-gY:~$ ssh lab@rtr1-gY.lab.workalaya.net
rtr1-gY> enable
~~~

Now do the following:

~~~cisco
rtr1-gY# configure terminal
rtr1-gY(config)#

flow exporter EXPORTER-1
 description Export to srv1-gY
 destination 100.68.Y.254
 transport udp 9996
 template data timeout 60

flow monitor FLOW-MONITOR-V4
 exporter EXPORTER-1
 record netflow ipv4 original-input
 cache timeout active 300

interface FastEthernet 0/0
 ip flow monitor FLOW-MONITOR-V4 input
 ip flow monitor FLOW-MONITOR-V4 output

snmp-server ifindex persist
~~~

Since you have not specified a protocol version for the exported flow records, you get the default which is Netflow v9.

Netflow v9 packets cannot be decoded by the receiver until it has received a template packet. The command _template data timeout 60_ tells the router to send it every 60 seconds, to make the lab exercises work more quickly. (In production a value of 300 is fine).

The _cache timeout active 300_ command breaks up long-lived flows into 5-minute fragments. If you leave it at the default of 30 minutes your traffic graphs will have spikes.

**Aside**: if you want to monitor IPv6 flows you would have to create a new flow monitor for IPv6 and attach it to the interface and the existing exporters.

~~~txt
flow monitor FLOW-MONITOR-V6
  exporter EXPORTER-1
  record netflow ipv6 original-input
  cache timeout active 300
 interface FastEthernet 0/0
  ipv6 flow monitor FLOW-MONITOR-V6 input
  ipv6 flow monitor FLOW-MONITOR-V6 output
~~~

The command _snmp-server ifindex persist_ enables ifIndex persistence globally. This ensures that the ifIndex values are retained during router reboots - also if you add or remove interface modules to your network devices.

Now we'll verify what we've done.

First exit from the configuration session:

~~~cisco
rtr1-gY(config)# end
~~~

~~~cisco
rtr1-gY# show flow exporter EXPORTER-1
rtr1-gY# show flow monitor FLOW-MONITOR-V4
~~~

It's possible to see the individual flows that are active in the router:

~~~cisco
rtr1-gY# show flow monitor FLOW-MONITOR-V4 cache
~~~

But on a busy router there will be thousands of individual flows, so that's not useful. Press '_q_' to escape from the screen output if necessary.

Instead, group the flows so you can see your "top talkers" (traffic destinations and sources). This is one very long command line:

~~~cisco
rtr1-gY# show flow monitor FLOW-MONITOR-V4 cache aggregate ipv4 source address ipv4 destination address sort counter bytes top 20
~~~

If it all looks good then write your running-config to non-volatile RAM (i.e. the startup-config):

~~~cisco
rtr1-gY# wr mem
~~~

You can exit from the router now:

~~~cisco
rtr1-gY# exit
~~~

To check flow packets are arriving at your VM you can use tcpdump:
Have one person in your group connect to your srv1-gY server and then do:

~~~bash
lab@srv1-gY:~$ sudo apt install tcpdump
lab@srv1-gY:~$ sudo tcpdump -i eth0 -nn udp port 9996
~~~

Wait a few seconds and you should see packets arriving. These are the UDP packets containing individual flow records. After seeing some packets you can press _ctrl-c_ to exit from tcpdump.
You should see something like:

~~~bash
lab@srv1-gY:~$ sudo tcpdump -i eth0 -nn -c 5 udp port 9996
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 262144 bytes
14:59:59.281887 IP 100.68.12.1.54457 > 100.68.12.254.9996: UDP, length 104
15:00:21.155926 IP 100.68.12.1.54457 > 100.68.12.254.9996: UDP, length 236
15:00:25.217719 IP 100.68.12.1.54457 > 100.68.12.254.9996: UDP, length 130
15:00:48.282375 IP 100.68.12.1.54457 > 100.68.12.254.9996: UDP, length 130
15:00:49.286459 IP 100.68.12.1.54457 > 100.68.12.254.9996: UDP, length 236
5 packets captured
5 packets received by filter
0 packets dropped by kernel
~~~

~~~bash
lab@srv1-gY:~$ sudo tcpdump -i eth0 -nn -c 5 -Tcnfp port 9996
[sudo] password for lab:
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 262144 bytes
14:58:28.284436 IP 100.68.12.1.54457 > 100.68.12.254.9996: NetFlow v9
14:58:29.289145 IP 100.68.12.1.54457 > 100.68.12.254.9996: NetFlow v9
14:58:38.292437 IP 100.68.12.1.54457 > 100.68.12.254.9996: NetFlow v9
14:58:48.261794 IP 100.68.12.1.54457 > 100.68.12.254.9996: NetFlow v9
14:58:59.279264 IP 100.68.12.1.54457 > 100.68.12.254.9996: NetFlow v9
5 packets captured
5 packets received by filter
0 packets dropped by kernel
~~~

Once you see that records are arriving you can log off machines by doing:

~~~bash
lab@srv1-gY:~$ exit
~~~

OPTIONAL: you can use tshark (the text version of wireshark), which is able to fully decode Netflow v9 packets:

~~~bash
lab@srv1-gY:~$ sudo apt install tshark
lab@srv1-gY:~$ sudo tshark -i eth0 -nnV -s0 -d udp.port==9996,cflow udp port 9996
~~~

You are now done with this lab.

---
