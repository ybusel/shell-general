#!/usr/local/bin/bash

###################################
# This scipt is going to count    #
# number of mobile devices        #
# on AKQA-GUEST wireless network  #
# created: 01/30/2013             #
# by:  Yevgeniy Busel             #
###################################

file=/var/db/dhcpd/dhcpd.leases
THRESHOLD=150
n=1

if [ ! -f $file ]
then
        echo "$file not found."
        exit 1
fi

for l in $file
do
        l=$(cat $file | awk '/client-hostname/ { print $2 }' | sort -u | sed -e 's/^"SFP.*$//g;s/^"SFM.*$//g;s/^"PC.*$//g;s/^"WUS.*$//g;s/^"BER.*$//g;s/^"LON.*$//g;s/
^lease.*$//g' | sed '/^$/d' > /tmp/currentlease)

filec=/tmp/currentlease

if [ -f $filec ]
then
        for d in $(cat $filec)
        do
        echo "MD Name #$n = $d"
        n=$((n+1))

        done
fi

done

if [ $n -ge $THRESHOLD ]
then

        cat -n $filec > $filec.1
        awk 'NR==1{ print "There are too many mobile devices on the GUEST NETWORK. Here is the list:\n"}1' $filec.1 > $filec.2
        cat $filec.2 | mail -s 'Mobile Devices on AKQA-GUEST LIST' yevgeniy.busel@akqa.com


fi

rm $filec*


exit $?
