#!/bin/bash

# global definitions:
RED='\033[0;31m'
NC='\033[0m'

# check the parameters
if [ $# != 2 ]; then
  echo "usage : $0 <project_root> <boot_resource>"
  exit 1
fi

project_root="$1"
boot_resource=$(echo "$2" | sed -e 's/^"//' -e 's/"$//')

# check the project root folder
if [ ! -d "$project_root" ]; then
  echo -e "${RED}ERROR: Cannot find the folder '$project_root' ${NC}"
  exit 2
fi

# check the selected boot resource folder
boot_resource_folder="$project_root/RESOURCES/OPTIONS/boot_resource/$boot_resource"
if [ ! -d "$boot_resource_folder" ]; then
  echo -e "${RED}ERROR: Cannot find the folder '$boot_resource_folder' ${NC}"
  exit 3
fi

# check the selected boot resource file
boot_resource_file="$project_root/RESOURCES/OPTIONS/boot_resource/$boot_resource/boot-resource"
if [ ! -f "$boot_resource_file" ]; then
  echo -e "${RED}ERROR: Cannot find the folder '$boot_resource_file'\nPlease use 'sudo ./process.sh' to create the 'boot_resource' file from the source folder ${NC}"
  exit 3
fi

# check the target folder
target_folder="$project_root/unpacked"
if [ ! -d "$target_folder" ]; then
  echo -e "${RED}ERROR: Cannot find the target folder '$target_folder' ${NC}"
  exit 4
fi

# copy the selected boot resource to the target
/bin/cp -f "$boot_resource_file" "$target_folder"

exit 0
