#!/bin/bash

# global definitions:
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# check the parameters
if [ $# != 2 ]; then
  echo "usage : $0 <project_root> <public_key>"
  exit 1
fi

project_root="$1"
public_key="$2"

# check the project root folder
if [ ! -d "$project_root" ]; then
  echo -e "${RED}ERROR: Cannot find the folder '$project_root' ${NC}"
  exit 2
fi

# check the public key file
if [ ! -f "$public_key" ]; then
  echo -e "${RED}ERROR: Cannot find the file '$public_key' ${NC}"
  exit 3
fi

# check the target folder
target_folder="$project_root/unpacked/squashfs-root/etc"
if [ ! -d "$target_folder" ]; then
  echo -e "${RED}ERROR: Cannot find the output folder '$target_folder' ${NC}"
  exit 4
fi

# enable custom updates by providing a custom public key
cp "$public_key" "$target_folder"

echo -e "${GREEN}SUCCESS: The custom public key has been copied to the target folder ${NC}"

exit 0
