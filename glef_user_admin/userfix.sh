#!/bin/bash 
# Author:Dan Shumaker
# Created:2/03/2011
# Run this as root.
# Uncomment stuff to setup expiration dates for accounts.

#groupadd glef
notused=""

for user in `ls -1 /home`; do
	usermod -s /bin/bash $user
	grep $user /etc/passwd
	#groups $user
	#delgroup $user
	#chgrp -R glef /home/$user
	#chage -W 30 $user
	#chage -M 365 $user
	#chage -I 10 $user
	#chage -E -1 $user
	#chage -l $user
	#passwd -S $user
	#newuser=`passwd -S $user | grep "01/01/1970" | awk '{ print $1 }'`
	#notused="$notused $newuser"
done

#echo "People who are not using their accounts"
#echo $notused
#for user in $notused; do
#	echo $user
#	#chage -d 2010-02-30 $user
#	chage -l $user
#done
#chown -R geoff /var/www
#chgrp -R glef /var/www
#echo "You should reboot the server"
