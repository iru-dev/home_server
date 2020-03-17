#!/bin/sh
#Zabbix custom.vfs.dev.discovery implementation
DEVS=`ls -1 /sys/class/block/ | grep -E -v '(ram|sr|loop|sd[a-z][0-9])'`

POSITION=1
echo "{"
echo " \"data\":["
for DEV in $DEVS
do
   if [ $POSITION -gt 1 ]
     then
       echo ","
   fi
  echo  " { \"{#DEVICENAME}\": \"$DEV\" }"
# echo  " { \"{#DEVICENAME}\": \"$DEV\","
# echo -n "  \"{#DEVMOUNT}\": \"`lsblk |grep $DEV|awk '{print $8}'`\"}"
 POSITION=$[POSITION+1]
done
echo ""
echo " ]"
echo "}"
