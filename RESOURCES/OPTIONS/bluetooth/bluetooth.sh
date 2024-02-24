#!/bin/bash

# check the parameters
if [ $# != 2 ]; then
    echo "usage : $0 <project_root>"
    exit 1
fi

project_root="$1"

# check the required tools
check_tools "rm"

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
    "lib/upgrade/keep.d/bluez-daemon"
    "usr/bin/bccmd"
    "usr/bin/bdaddr"
    "usr/bin/blue*"
    "usr/bin/bt*"
    "usr/share/alsa/alsa.conf.d/20-bluealsa.conf"
)

# Remove everything in the array using -rf
for folder in "${folders[@]}"; do
    echo -e "${YELLOW}INFO: Removing the $ROOTFS_DIR/$folder ...${NC}"
    rm -rf $ROOTFS_DIR/$folder
done

echo -e "${GREEN}INFO: The bluetooth option has been removed${NC}"
