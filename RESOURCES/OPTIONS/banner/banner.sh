#!/bin/bash

# global definitions:
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# check the parameters
if [ $# != 2 ]; then
    echo "usage : $0 <project_root> <banner_file>"
    exit 1
fi

project_root="$1"
banner_file="$2"

# Echo the banner into $project_root/unpacked/etc/banner

# Check the required tools
TOOL_LIST="cat"
for tool_name in $TOOL_LIST; do
    echo "Checking tool: $tool_name"
    tool_path=$(which "$tool_name")
    if [ -z "$tool_path" ]; then
        echo -e "${RED}ERROR: Missing tool '$tool_name' ${NC}"
        exit 1
    fi
done

# Check the project root folder
if [ ! -d "$project_root" ]; then
    echo -e "${RED}ERROR: Cannot find the folder '$project_root' ${NC}"
    exit 2
fi

# Check the banner exists
if [ ! -f "$project_root/RESOURCES/OPTIONS/$banner_file/$banner_file" ]; then
    echo -e "${RED}ERROR: Cannot find the file '$banner_file' ${NC}"
    exit 3
fi

# Overwrite the banner file with ./banner if error then exit
cat "$project_root/RESOURCES/OPTIONS/$banner_file/$banner_file" >"$project_root/unpacked/squashfs-root/etc/banner"
if [ $? != 0 ]; then
    echo -e "${RED}ERROR: Cannot overwrite the banner file ${NC}"
    exit 4
fi

echo -e "${GREEN}SUCCESS: The 'banner' file has been overwritten ${NC}"

exit 0
