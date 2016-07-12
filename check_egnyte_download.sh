#!/bin/bash
PROGNAME=`basename $0`
VERSION="Version 1.0"
AUTHOR="2010.11.17,www.nginxs.com"

ST_OK=0
ST_WR=1
ST_CR=2
ST_UK=3

interval=5

url="https://akqa.egnyte.com/dd/OWC0RH1Q9Z/testDN_"

print_version() {
        echo "$VERSION $AUTHOR"
}

print_help() {
        print_version $PROGNAME $VERSION
        echo "$PROGNAME is a Nagios plugin to monitor download speed"
        echo "Use of curl download url file"
        echo "When using optional warning/critical thresholds all values except"
        echo "Usage parameters:"
        echo ""
        echo "$PROGNAME [-i/--interval] [-u|--url] [-w/--warning] [-c/--critical]"
        echo ""
        echo "Options:"
                echo "  --interval|-i)"
                echo "    Defines the download file times"
                echo "          propose set < 5 second and  > 10 second"
                echo "    Default is: 5 second"
                echo ""
                echo "  --url|-u)"
                echo "    Sets url page"
                echo "    Defautl is :http://mirrors.163.com/centos/5.5/isos/x86_64/CentOS-5.5-x86_64-LiveCD.iso"
                echo "          Please set Fastest url"
                echo ""
                echo "  --warning|-w)"
                echo "          Sets a warning level for download speed. Defautl is: off"
                echo ""
                echo "  --critical|-c)"
                echo "          Sets a critical level for download speed. Defautl is: off"
        exit $ST_UK
}

while test -n "$1";do
        case "$1" in
                --help|-h)
                        print_help
                        exit $ST_UK
                        ;;
                --url|-u)
                        url=$2
                        shift
                        ;;
                --interval|-i)
                        interval=$2
                        shift
                        ;;
                --warning|-w)
                        warn=$2
                        shift
                        ;;
                --critical|-c)
                        crit=$2
                        shift
                        ;;
                *)
                        echo "Unknown argument: $1"
                        print_help
                        exit $ST_UK
                        ;;
        esac
        shift
done

val_wcdiff() {
    if [ ${warn} -lt ${crit} ]
    then
        wcdiff=1
    fi
}

get_dspeed() {

        STATS=$(curl -w '%{speed_download}\t%{time_total}\n' -s $url -o /dev/null)
        sleep $interval
        dspeed=`echo $STATS | awk '{print $1}' | sed 's/\..*//'`
        let speed="$dspeed/1024 | bc"
        time=`echo $STATS | awk '{print $2}' | sed 's/\..*//'`
}

do_output() {

        output="download speed: ${speed} KB/s  download time: ${time} sec"

}

do_perfdata() {

        perfdata="'speed'=${dspeed}"
}

if [ -n "$warn" -a -n "$crit" ]
then
    val_wcdiff
    if [ "$wcdiff" = 1 ];then
        echo "Please adjust your warning/critical thresholds. The critical must be lower than the warning level!"
        exit $ST_UK
    fi
fi

get_dspeed
do_output
do_perfdata

if [ -n "$warn" -a -n "$crit" ];then
        if [ $speed -le $warn -a $speed -gt $crit ];then
                echo  "WARNING - $output |$perfdata"
                exit $ST_WR
        elif [ $speed -lt $crit ];then
                echo  "CRITICAL - $output|$perfdata"
                exit $ST_CR
        else
                echo  "OK - $output|$perfdata"
                exit $ST_OK
        fi
else
        echo "OK - $output | $perfdata"
        exit $ST_OK
fi
