#!/bin/bash

#script will automate the installation process of a container
# lxd installation
which lxd > /dev/null
if [ $? -ne 0 ]; then
# Need to install lxd
	echo "Installing lxd"
	sudo snap install lxd
	if [ $? -ne 0 ]; then
	# Failed to install lxd
	echo "Failed to installation of lxd."
	exit 1
	fi
fi

# sudo init installation
ifconfig | grep -w "lxdbr0" > /dev/null
if [ $? -ne 0 ]; then
#creating interface
	echo "Creating the lxdbr0 interface"
	echo
	lxd init --auto 
	if [ $? -ne 0 ]; then
	# Failed to install the lxdbr0 interface
		exit 1
	fi
fi

#containers to determine if COMP2101-F22 exists and is running
lxc list | grep -w "COMP2101-F22" > /dev/null
if [ $? -ne 0 ]; then
# Need to install COMP2101-F22
lxc launch ubuntu:20.04 COMP2101-F22
	if [ $? -ne 0 ]; then
	# Failed to launch container
		exit 1
	fi
fi


 ##updating the entry 
# Store IP address and container hostname as variables
containerIaddrP=$(lxc list | grep -w "COMP2101-F22" | awk '{print $6}')
containerHostname=$(lxc list | grep -w "COMP2101-F22" | awk '{print $2}')

# Combine the variables into a single variable
containerInfo="$containerIPaddr 	$containerHostname"

grep "$containerInfo" /etc/hosts > /dev/null
if [ $? -ne 0 ]; then
# Need to create
	echo "Updating the entry in container"
	sudo sed -i "1i$containerInfo" /etc/hosts
	if [ $? -ne 0 ]; then
	# Adding the entry to /etc/hosts failed
		exit  1
	fi
fi
lxc exec COMP2101-F22 which apache2 > /dev/null
if [ $? -ne 0 ]; then
# Need to install Apache2
	echo "Installing Apache2"
	lxc exec COMP2101-F22 -- apt-get -y install apache2 &> /dev/null
	if [ $? -ne 0 ]; then
	# Failed to install apache2 
	echo "Failed to install apache2"
	exit 1
	fi
else
	echo "Apache2 already installed"
fi

# Installing the curl
which curl > /dev/null
if [ $? -ne 0 ]; then
# Need to install curl
	echo "Installing curl"
	sudo snap install curl > /dev/null
	if [ $? -ne 0 ]; then
	# Failed to install curl
	exit 1
	fi
fi

echo "Attempting to retrieve the default web page from the Apache2 Server"
curl http://COMP2101-F22 &> /dev/null

if [ $? -ne 0 ]; then
#web page could not be retrieved
	echo "problem retrieving the default web page from container's web service."
	echo
	echo "Script FAILURE"
	exit 1
else
#web page was successfully retrieved
	echo  "web page was successfully retrieved from the container web service"
	echo
	echo "Script SUCCESS"
fi
