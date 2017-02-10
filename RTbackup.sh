#!/bin/bash

# MySQL INFO
############
USER="root"
PASSWORD="118king"
OUTPUTDIR="/usr/rtbkp"
/bin/rm -f $OUTPUTDIR/*.gz > /dev/null 2>&1

databases=`mysql --user=$USER --password=$PASSWORD -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`

#databases=`mysql -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`

for db in $databases; do
    if [[ "$db" != "information_schema" ]] && [[ "$db" != _* ]] ; then
        echo "Dumping database: $db"
        mysqldump --force --opt --user=$USER --password=$PASSWORD --databases $db > $OUTPUTDIR/`date +%Y%m%d`.$db.sql
#         mysqldump --force --opt --databases $db > $OUTPUTDIR/`date +%Y%m%d`.$db.sql
        gzip $OUTPUTDIR/`date +%Y%m%d`.$db.sql
    fi
done

# RSYNC INFO
############
BKPSRV="nasoftware"
DST="RT"

rsync -av $OUTPUTDIR $BKPSRV::$DST >> $0.log 2>&1


echo "TRANSFER FINISHED"
