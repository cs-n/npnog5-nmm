#!/bin/bash

for i in `seq 1 10` ; 
do 
        echo "srv1-g$i"; 
        echo "----------" ;
        curl -s http://srv1-g$i.lab.workalaya.net/nfsen/nfsen.php | grep "<title>" | sed "s/<title>//g" | sed "s/<\/title>//g" ; 
        echo "----------" ;
    echo;
done
