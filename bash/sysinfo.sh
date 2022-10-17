#!/bin/bash

# Name

FQDN=$(hostname)

# The operating system name and all other info

OS_NAME=$(hostnamectl)

# Ip address

IP_ADDRESSES=$(hostname -I | grep -v "127.")

# amount of space available

ROOT_SPACE=$(df -h /dev/sda3)

# Output
#=============================


echo "FQDN: $FQDN"

echo "Operating System: $OS_NAME"

echo "IP Addresses: $IP_ADDRESSES"

echo "Root Filesystem Space: $ROOT_SPACE"

#==============================
exit 0

