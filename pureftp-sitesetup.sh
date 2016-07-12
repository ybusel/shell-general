#!/usr/local/bin/bash

#########################################
# Script creates new pure-ftp site for  #
# AKQA users, clients and vendors.      #
# created by Yevgeniy Busel             #
# october 25, 2012                      #
#
# Modified on january 11, 2013          #
#########################################

dirD2=/d2box   # Main FTP directory
dirSF=/sfdata  # Secondary FTP directory
THRESHOLD=90
admin=yevgeniy.busel@akqa.com

# If there is enough space in the directory before creating site
# First look into /d2box directory

spaceD2=$(df -H $dirD2 | grep $dirD2 | awk '{ print $5 }' | sed 's/%//g')

if [[ $spaceD2 -le $THRESHOLD ]];
then

clear

printf "%10s **** NOTE ****\n"


dir=/d2box/akqasfo/client

read -p "Please enter new ftpsite name/username : " sitename

newsite="${dir}/${sitename}"

   if [ ! -d "${newsite}" ]
   then

  pure-pw useradd $sitename -u ftpuser -g ftpgroup -d $newsite -m &&

  mkdir -p $newsite &&

  chmod -R 775 $newsite
  else
        echo "$0: $sitename already exists. Please re-run script with the new sitename.";

  exit 1;

        fi

else

        echo "Looking if there is enough space on all storage devices...Please wait."
        mail -s 'DROPBOX Disk Space Alert' $admin << EOF
        DROPBOX $dirD2 partition is critically low. Used: $spaceD2%
EOF


# If there is NOT enough space in /d2box directory, look into /sfdata one.

sleep 5

spaceSF=$(df -H $dirSF | grep $dirSF | awk '{ print $5 }' | sed 's/%//g')

if [[ $spaceSF -le $THRESHOLD ]];
then

clear

printf "%10s **** NOTE ****\n"


dir=/sfdata/ftp

read -p "Please enter new ftpsite name/username : " sitename

newsite="${dir}/${sitename}"

   if [ ! -d "${newsite}" ]
   then

  pure-pw useradd $sitename -u ftpuser -g ftpgroup -d $newsite -m &&

  mkdir -p $newsite &&

  chown -R ftpuser:ftpgroup $newsite
  else
        echo "$0: $sitename already exists. Please re-run script with the new sitename.";

  exit 1;

        fi
else
        mail -s 'DROPBOX Disk Space Alert' $admin << EOF
        DROPBOX $dirSF partition is critically low. Used: $spaceSF%
EOF
        echo "There is not enough space on the server, please contact $admin regarding this issue."

exit 2;
        fi
fi

printf "$sitename ftp site has been created."

