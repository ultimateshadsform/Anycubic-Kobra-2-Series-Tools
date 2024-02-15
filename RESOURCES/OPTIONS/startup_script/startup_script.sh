#!/bin/bash

# global definitions:
RED='\033[0;31m'
NC='\033[0m'

# check the parameters
if [ $# != 2 ]; then
    echo "usage : $0 <project_root> <startup_script_package>"
    exit 1
fi

project_root="$1"
startup_script_package=$(echo "$2" | sed -e 's/^"//' -e 's/"$//')

# Check if startup.sh is available
if [ ! -f "$project_root/RESOURCES/OPTIONS/startup_script/startup.sh" ]; then
    echo -e "${RED}ERROR: Cannot find the file 'startup.sh' ${NC}"
    exit 2
fi

# Check if project root folder exists
if [ ! -d "$project_root" ]; then
    echo -e "${RED}ERROR: Cannot find the folder '$project_root' ${NC}"
    exit 3
fi

# Check if $project_root/RESOURCES/KEYS/mosquitto exists
if [ ! -d "$project_root/RESOURCES/KEYS/mosquitto" ]; then
    echo -e "${RED}ERROR: Cannot find the folder '$project_root/RESOURCES/KEYS/mosquitto' ${NC}"
    exit 4
fi

# Copy everything from $project_root/RESOURCES/KEYS/mosquitto to $project_root/unpacked/squashfs-root/etc/ssl/certs
mkdir -p "$project_root/unpacked/squashfs-root/etc/ssl/certs"
cp -rf "$project_root/RESOURCES/KEYS/mosquitto"/* "$project_root/unpacked/squashfs-root/etc/ssl/certs"

# Move startup.sh to project root/unpacked/squashfs-root/etc
cp -rf "$project_root/RESOURCES/OPTIONS/startup_script/startup.sh" "$project_root/unpacked/squashfs-root/etc"

# Add /etc/startup.sh to $project_root/unpacked/squashfs-root/etc/rc.local before the exit 0 line
sed -i '/exit 0/i /etc/startup.sh' "$project_root/unpacked/squashfs-root/etc/rc.local"

exit 0
