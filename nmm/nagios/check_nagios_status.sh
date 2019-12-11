#!/bin/bash

for i in `seq 1 10` ; 
do 
    echo "Group - $i" ;
    echo "----------" ;
    for j in `seq 1 4`; 
    do 
        echo "vm$j-g$i"; 
        echo "----------" ;
        curl -su nagiosadmin:lab http://vm$j-g$i.lab.workalaya.net/cgi-bin/nagios3/status.cgi?host=all | grep "SSH OK" | sed "s/<td class='statusEven' valign='center'>//g" | sed "s/<td class='statusOdd' valign='center'>//g" | sed "s/&nbsp;<\/td>//g" ; 
        echo "----------" ;
    done;
    echo;
done
