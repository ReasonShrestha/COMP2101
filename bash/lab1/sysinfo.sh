#!/bin/bash

#username
echo "name? $(hostname)"

#information about user's comp
echo " full information "
hostnamectl
echo "full information"


# name and version of operating system
hostnamectl | grep -h "Opera"

# ip addresses
echo "ip address"
hostname -I


# free storage
echo " storage "
df -h | grep -h "/dev/"
