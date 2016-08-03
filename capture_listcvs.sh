#!/bin/sh

cd /data

/usr/local/bin/tree -fi cvsroot > /tmp/file1

lines=`wc -l /tmp/file1 | cut -c1-8`

lines2=`dc -e "$lines 2 - n"`

head -$lines2 /tmp/file1 > /tmp/file2

for each in `cat /tmp/file2`
do
	echo "$each" | cut -c 9-500 >> /tmp/file3
done

for each in `cat /tmp/file3`
do
	echo "upgrade" $each >> /tmp/file4
done

cd /tmp
cp /tmp/file4 /usr/cvsupd/sup/repl/list.cvs

rm file1 file2 file3 file4
