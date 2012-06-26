#!/bin/bash 
# Author:Dan Shumaker
# Created:8/03/2011
# Run this as root.
# Uncomment stuff to setup expiration dates for accounts.

passwd -l $1 
usermod --expiredate 1 $1

echo "Locked and Expired $1"
