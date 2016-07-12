#!/bin/bash

echo "Please enter new device ip address:"
read ip

echo "Please enter the name of new device:"
read name

########################################################
f1="$(echo $ip | cut -d "." -f 1)"
f2="$(echo $ip | cut -d "." -f 2)"
f3="$(echo $ip | cut -d "." -f 3)"
f4="$(echo $ip | cut -d "." -f 4)"

file=hosts.cfg
dupip=`cat $file | grep -e $ip | awk '{ print $1 }'`
dupname=`cat $file | grep -e $name | awk '{ print $2 }'`
#########################################################

sfo_net ()
{
cat $file | while read line
do
        echo $line
        echo $line | grep -q "NETWORK CORE SYSTEMS"
        [ $? -eq 0 ] && echo -e "$ip\t$name #"

done > $file.2

mv $file.2 $file
}

sfo_srvrs ()
{
cat $file | while read line
do
        echo $line
        echo $line | grep -q "ACTIVE DIRECTORY & FILE SERVERS"
        [ $? -eq 0 ] && echo -e "$ip\t$name #"

done > $file.2

mv $file.2 $file
}

sfo_ly_ex ()
{
cat $file | while read line
do
        if [[ "$name" == *SFOWPEXCH* ]]
        then
        echo $line
        echo $line | grep -q "MS EXCHANGE SERVERS"
        [ $? -eq 0 ] && echo -e "$ip\t$name #"

        else
        echo $line
        echo $line | grep -q "FRONT END POOL SERVERS"
        [ $? -eq 0 ] && echo -e "$ip\t$name #"
 fi

done > $file.2

mv $file.2 $file
}

nyc_svrs ()
{
cat $file | while read line
do
        if [[ "$name" == *NYCW* ]] || [[ "$name" == *nycw* ]] || [[ "$name" == *NYCWV* ]]
        then
        echo $line
        echo $line | grep -q "NYC AD Controller DNS and File servers"
        [ $? -eq 0 ] && echo -e "$ip\t$name #"

        elif [[ "$name" == *nycx* ]] || [[ "$name" == *nycwv* ]]
        then
        echo $line
        echo $line | grep -q "NYC TECH VM FARM"
        [ $? -eq 0 ] && echo -e "$ip\t$name #"
 fi

done > $file.3

mv $file.3 $file
}

wdc_srvrs ()
{
cat $file | while read line
do
        if [[ "$name" == *wdcwp* ]] || [[ "$name" == *WDCWP* ]]
        then
        echo $line
        echo $line | grep -q "WDC File/Application Servers"
        [ $? -eq 0 ] && echo -e "$ip\t$name #"

        fi

done > $file.2

mv $file.2 $file
}

####CONDITIONS IF ENTERED VALUES ARE VALID###############

if [[ ! $f1 == 10 ]] && [[ $f2 > 13 ]] && [[ $f3 > 255 ]] && [[ $f4 > 255 ]]
then
        echo "This is not valid AKQA Range...Please enter valid AKQA ip address."
        exit 1

elif [[ "$ip" == "$dupip" ]]
then
        echo "You have entered duplicated ip. Please enter unique one."
        exit 2

elif [[ "$name" == "$dupname" ]]
then
        echo "You have entered duplicated name. Please enter unique one."
        exit 3

else


#########SFO#########

        if [[ $f1 == 10 ]] && [[ $f2 == 1 ]] && [[ $f3 == 1 ]] && [[ $f4 -le 255 ]]
        then

        sfo_net
        echo "The device $name has been succesfully entered."

        elif [[ $f3 == 10 ]]
        then

        sfo_srvrs
        echo "The device $name has been succesfully entered."

        elif [[ $f3 == 11 ]]
        then

        sfo_ly_ex
        echo "The device $name has been succesfully entered."

#########WDC##########

        elif [[ $f1 == 10 ]] && [[ $f2 == 3 ]] && [[ $f3 == 30 ]] && [[ $f4 -le 255 ]]
        then

        wdc_srvrs
        echo "WDC device $name has been succesfully entered."

###NYC###

        elif
        [[ $f1 == 10 ]] && [[ $f2 == 4 ]] && [[ $f3 -le 255 ]] && [[ $f4 -le 255 ]]
        then

        nyc_svrs
        echo "NYC device $name has been succesfully entered."

###SHA###

        elif
        [[ $f1 == 10 ]] && [[ $f2 == 5 ]] && [[ $f3 -le 255 ]] && [[ $f4 -le 255 ]]
        then

                echo "$ip is belong to AKQA SHA office."

        else
                echo "This device needs to be entered manually. Please contact administrator."
        fi
fi
