#!/bin/bash

# check the parameters
if [ $# != 2 ]; then
  echo "usage : $0 <project_root> <opkg_package>"
  exit 1
fi

project_root="$1"
opkg_package="$2"

# check the required tools
check_tools "unzip grep sed"

# check the project root folder
if [ ! -d "$project_root" ]; then
  echo -e "${RED}ERROR: Cannot find the folder '$project_root' ${NC}"
  exit 3
fi

# check the opkg package folder
opkg_package_folder="${OPTIONS_DIR}/opkg/${opkg_package}"
if [ ! -d "$opkg_package_folder" ]; then
  echo -e "${RED}ERROR: Cannot find the folder '$opkg_package_folder' ${NC}"
  exit 4
fi

# check the opkg package file
opkg_package_file="${opkg_package_folder}/opkg.zip"
if [ ! -f "$opkg_package_file" ]; then
  echo -e "${RED}ERROR: Cannot find the file '$opkg_package_file' ${NC}"
  exit 5
fi

# check the target folder
target_folder="$ROOTFS_DIR"
if [ ! -d "$target_folder" ]; then
  echo -e "${RED}ERROR: Cannot find the target folder '$target_folder' ${NC}"
  exit 6
fi

# enable the selected opkg package
current_folder="$PWD"
cd "$target_folder" || exit 7
echo -e "${YELLOW}INFO: Unzipping the opkg package ...${NC}"
unzip -oqq "$opkg_package_file"
# add "/opt/etc/init.d/rc.unslung start" to $project_root/unpacked/squashfs-root/etc/rc.local before the exit 0 line
result=$(grep "/opt/etc/init.d/rc.unslung start" "$ROOTFS_DIR/etc/rc.local")
if [ -z "$result" ]; then
  # add it only if not already done
  sed -i '/exit 0/i /opt/etc/init.d/rc.unslung start' "$ROOTFS_DIR/etc/rc.local"
fi
# extend the PATH to $project_root/unpacked/squashfs-root/etc/profile
sed -i 's#export PATH="/usr/sbin:/usr/bin:/sbin:/bin"#export PATH="/usr/sbin:/usr/bin:/sbin:/bin:/opt/sbin:/opt/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin"#' "$ROOTFS_DIR/etc/profile"
cd "$current_folder" || exit 8

echo -e "${GREEN}SUCCESS: The '$opkg_package' opkg package has been installed ${NC}"

exit 0
