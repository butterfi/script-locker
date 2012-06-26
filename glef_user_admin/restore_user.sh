#!/bin/bash

# Author: Dan Shumaker
# Date: 3/22/2011
#
# example usage:   
#    >>   restore_user.sh username
#
#  This will restore user with username = blablausername 
#  They will have a password of blablausername1234 and be added to the glefweb group.
#

p=`./crypt_it.pl $1`

echo "Initial Password settings:"

# Expire the password already by making it 366 days old.
# BSD date command takes the -v parameter different.
# expire=`date -v-1y -v-1d +%Y-%m-%d`
expire=`date -d "-1 year -1 day" +%Y-%m-%d`
chage -l $1
usermod -p$p $1
chage -d $expire $1
echo "Modified Password settings:"
chage -l $1
