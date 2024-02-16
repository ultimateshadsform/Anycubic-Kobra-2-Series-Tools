#!/bin/bash

# global definitions:
RED='\033[0;31m'
NC='\033[0m'

# check the parameters
if [ $# != 2 ]; then
    echo "usage : $0 <project_root> <startup_script>"
    exit 1
fi

project_root="$1"
startup_script="$2"

# Check if $startup_script is available
if [ ! -f "$project_root/RESOURCES/OPTIONS/startup_script/$startup_script" ]; then
    echo -e "${RED}ERROR: Cannot find the file '$startup_script' ${NC}"
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

# Move $startup_script to project root/unpacked/squashfs-root/etc
cp -rf "$project_root/RESOURCES/OPTIONS/startup_script/$startup_script" "$project_root/unpacked/squashfs-root/etc"

# Add /etc/$startup_script to $project_root/unpacked/squashfs-root/etc/rc.local before the exit 0 line
sed -i "/exit 0/i /etc/$startup_script" "$project_root/unpacked/squashfs-root/etc/rc.local"

exit 0
