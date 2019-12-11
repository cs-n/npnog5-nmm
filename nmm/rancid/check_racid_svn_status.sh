#!/bin/bash

for i in `seq 1 10` ; 
do 
    echo "Group - $i" ;
    echo "----------" ;
    for j in `seq 1 4`; 
    do 
        echo "vm$j-g$i"; 
        echo "----------" ;
        curl -su lab:lab http://vm$j-g$i.lab.workalaya.net/viewvc/rancid/routers/configs/ | grep "<title>" | sed "s/<title>//g" | sed "s/<\/title>//g" ; 
        #curl -s http://vm$j-g$i.lab.workalaya.net/viewvc/rancid/routers/configs/ | grep "<title>" | sed "s/<title>//g" | sed "s/<\/title>//g" ; 
        echo "----------" ;
    done;
    echo;
done
