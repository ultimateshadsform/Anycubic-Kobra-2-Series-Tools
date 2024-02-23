#!/bin/bash

# check the parameters
if [ $# != 2 ]; then
  echo "usage : $0 <project_root> <fswebcam_package>"
  exit 1
fi

project_root="$1"
fswebcam_package="$2"

check_tools "unzip sed"

# check the project root folder
if [ ! -d "$project_root" ]; then
  echo -e "${RED}ERROR: Cannot find the folder '$project_root' ${NC}"
  exit 3
fi

# check the fswebcam package folder
fswebcam_package_folder="${OPTIONS_DIR}/fswebcam/${fswebcam_package}"
if [ ! -d "$fswebcam_package_folder" ]; then
  echo -e "${RED}ERROR: Cannot find the folder '$fswebcam_package_folder' ${NC}"
  exit 4
fi

# check the fswebcam package file
fswebcam_package_file="${fswebcam_package_folder}/fswebcam.zip"
if [ ! -f "$fswebcam_package_file" ]; then
  echo -e "${RED}ERROR: Cannot find the file '$fswebcam_package_file' ${NC}"
  exit 5
fi

# check the target folder
target_folder="$ROOTFS_DIR"
if [ ! -d "$target_folder" ]; then
  echo -e "${RED}ERROR: Cannot find the target folder '$target_folder' ${NC}"
  exit 6
fi

# enable the selected fswebcam package
current_folder="$PWD"
cd "$target_folder" || exit 7
unzip -o "$fswebcam_package_file"
# extend the PATH to $project_root/unpacked/squashfs-root/etc/profile
sed -i 's#export PATH="/usr/sbin:/usr/bin:/sbin:/bin"#export PATH="/usr/sbin:/usr/bin:/sbin:/bin:/opt/sbin:/opt/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin"#' "$project_root/unpacked/squashfs-root/etc/profile"
cd "$current_folder" || exit 8

echo -e "${GREEN}SUCCESS: The '$fswebcam_package' fswebcam package has been enabled ${NC}"

exit 0
