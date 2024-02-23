#!/bin/bash

# check the parameters
if [ $# != 2 ]; then
    echo "usage : $0 <project_root> <banner_file>"
    exit 1
fi

project_root="$1"
banner_file="$2"

# Echo the banner into $project_root/unpacked/etc/banner

# Check the required tools
check_tools "cat"

# Check the project root folder
if [ ! -d "$project_root" ]; then
    echo -e "${RED}ERROR: Cannot find the folder '$project_root' ${NC}"
    exit 2
fi

# Check the banner exists
if [ ! -f "$OPTIONS_DIR/$banner_file/$banner_file" ]; then
    echo -e "${RED}ERROR: Cannot find the file '$banner_file' ${NC}"
    exit 3
fi

# Overwrite the banner file with ./banner if error then exit
cat "$OPTIONS_DIR/$banner_file/$banner_file" >"$ROOTFS_DIR/etc/banner"
if [ $? != 0 ]; then
    echo -e "${RED}ERROR: Cannot overwrite the banner file ${NC}"
    exit 4
fi

echo -e "${GREEN}SUCCESS: The 'banner' file has been overwritten ${NC}"

exit 0
