#!/bin/bash

# global definitions:
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# check the parameters
if [ $# != 2 ]; then
    echo "usage : $0 <project_root>"
    exit 1
fi

project_root="$1"

# check the required tools
TOOL_LIST="rm"
for tool_name in $TOOL_LIST; do
    echo "Checking tool: $tool_name"
    tool_path=$(which "$tool_name")
    if [ -z "$tool_path" ]; then
        echo -e "${RED}ERROR: Missing tool '$tool_name' ${NC}"
        exit 1
    fi
done

# check the project root folder
if [ ! -d "$project_root" ]; then
    echo -e "${RED}ERROR: Cannot find the folder '$project_root' ${NC}"
    exit 2
fi

# Check the bluetooth folder and if exist then remove it

# A list of folders to remove
# Create an array of folders to remove
folders=(
    "etc/bluetooth"
    "etc/dbus-1/system.d/bluetooth*.conf"
    "lib/bluetooth"
    "lib/upgrade/keep.d/bluez-daemon"
    "usr/bin/bccmd"
    "usr/bin/bdaddr"
    "usr/bin/blue*"
    "usr/bin/bt*"
    "usr/lib/alsa-lib"
    "usr/lib/libbluetooth*"
    "usr/share/alsa/alsa.conf.d/20-bluealsa.conf"
)

# Remove the folders and files
# Check if folder or file and remove it
for folder in "${folders[@]}"; do
    if [ -d "$project_root/unpacked/squashfs-root/$folder" ]; then
        echo "Removing folder: $project_root/unpacked/squashfs-root/$folder"
        rm -rf "$project_root/unpacked/squashfs-root/$folder"
        if [ $? -ne 0 ]; then
            echo -e "${RED}ERROR: Failed to remove folder: $project_root/unpacked/squashfs-root/$folder ${NC}"
            exit 3
        fi
    elif [ -f "$project_root/unpacked/squashfs-root/$folder" ]; then
        echo "Removing file: $project_root/unpacked/squashfs-root/$folder"
        rm -f "$project_root/unpacked/squashfs-root/$folder"
        if [ $? -ne 0 ]; then
            echo -e "${RED}ERROR: Failed to remove file: $project_root/unpacked/squashfs-root/$folder ${NC}"
            exit 3
        fi
    fi
done

echo -e "${GREEN}SUCCESS: The 'bluetooth' has been removed ${NC}"
