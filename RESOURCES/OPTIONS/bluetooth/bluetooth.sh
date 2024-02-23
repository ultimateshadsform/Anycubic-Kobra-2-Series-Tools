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
    if [ -d "$ROOTFS_DIR/$folder" ]; then
        echo "Removing folder: $ROOTFS_DIR/$folder"
        rm -rf "$ROOTFS_DIR/$folder"
        if [ $? -ne 0 ]; then
            echo -e "${RED}ERROR: Failed to remove folder: $ROOTFS_DIR/$folder ${NC}"
            exit 3
        fi
    elif [ -f "$ROOTFS_DIR/$folder" ]; then
        echo "Removing file: $ROOTFS_DIR/$folder"
        rm -f "$ROOTFS_DIR/$folder"
        if [ $? -ne 0 ]; then
            echo -e "${RED}ERROR: Failed to remove file: $ROOTFS_DIR/$folder ${NC}"
            exit 3
        fi
    fi
done

echo -e "${GREEN}SUCCESS: The 'bluetooth' has been removed ${NC}"
