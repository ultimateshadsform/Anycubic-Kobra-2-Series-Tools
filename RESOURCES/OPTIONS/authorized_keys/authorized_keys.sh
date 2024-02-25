#!/bin/bash

# check the parameters
if [ $# != 2 ]; then
  echo "usage : $0 <project_root> <authorized_keys>"
  exit 1
fi

project_root="$1"
authorized_keys="$2"

# check the project root folder
if [ ! -d "$project_root" ]; then
  echo -e "${RED}ERROR: Cannot find the folder '$project_root' ${NC}"
  exit 2
fi

# check the authorized_keys file
if [ ! -f "$authorized_keys" ]; then
  echo -e "${RED}ERROR: Cannot find the file '$authorized_keys' ${NC}"
  exit 3
fi

# check the target folder
target_folder="$ROOTFS_DIR/opt/etc/dropbear"
if [ ! -d "$target_folder" ]; then
  echo -e "${RED}ERROR: Cannot find the output folder '$target_folder' ${NC}"
  exit 4
fi

# enable remote ssh access by keys instead of a password
cp "$authorized_keys" "$target_folder/authorized_keys"
chmod 600 "$target_folder/authorized_keys"

echo -e "${GREEN}SUCCESS: The authorized_keys file has been copied to the target folder ${NC}"

exit 0
