#!/bin/bash

# global definitions:
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# check the parameters
if [ $# != 2 ]; then
  echo "usage : $0 <project_root> <ssh_package>"
  exit 1
fi

project_root="$1"
ssh_package="$2"

# check the required tools
TOOL_LIST="unzip grep sed"
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
  exit 3
fi

# check the ssh package folder
ssh_package_folder="${project_root}/RESOURCES/OPTIONS/ssh/${ssh_package}"
if [ ! -d "$ssh_package_folder" ]; then
  echo -e "${RED}ERROR: Cannot find the folder '$ssh_package_folder' ${NC}"
  exit 4
fi

# check the ssh package file
ssh_package_file="${ssh_package_folder}/ssh.zip"
if [ ! -f "$ssh_package_file" ]; then
  echo -e "${RED}ERROR: Cannot find the file '$ssh_package_file' ${NC}"
  exit 5
fi

# check the target folder
target_folder="$project_root/unpacked/squashfs-root"
if [ ! -d "$target_folder" ]; then
  echo -e "${RED}ERROR: Cannot find the target folder '$target_folder' ${NC}"
  exit 6
fi

# enable the selected ssh package
current_folder="$PWD"
cd "$target_folder" || exit 7
unzip -o "$ssh_package_file"
# add "/opt/etc/init.d/rc.unslung start" to $project_root/unpacked/squashfs-root/etc/rc.local before the exit 0 line
result=$(grep "/opt/etc/init.d/rc.unslung start" "$project_root/unpacked/squashfs-root/etc/rc.local")
if [ -z "$result" ]; then
  # add it only if not already done
  sed -i '/exit 0/i /opt/etc/init.d/rc.unslung start' "$project_root/unpacked/squashfs-root/etc/rc.local"
fi
# extend the PATH to $project_root/unpacked/squashfs-root/etc/profile
sed -i 's#export PATH="/usr/sbin:/usr/bin:/sbin:/bin"#export PATH="/usr/sbin:/usr/bin:/sbin:/bin:/opt/sbin:/opt/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin"#' "$project_root/unpacked/squashfs-root/etc/profile"
cd "$current_folder" || exit 8

echo -e "${GREEN}The ssh package has been successfully installed ${NC}"

exit 0
