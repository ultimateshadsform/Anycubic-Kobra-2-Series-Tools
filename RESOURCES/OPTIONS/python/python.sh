#!/bin/bash

# check the parameters
if [ $# != 2 ]; then
  echo "usage : $0 <project_root> <python_package>"
  exit 1
fi

project_root="$1"
python_package="$2"

# check the required tools
check_tools "unzip sed"

# check the project root folder
if [ ! -d "$project_root" ]; then
  echo -e "${RED}ERROR: Cannot find the folder '$project_root' ${NC}"
  exit 3
fi

# check the python package folder
python_package_folder="${OPTIONS_DIR}/python/${python_package}"
if [ ! -d "$python_package_folder" ]; then
  echo -e "${RED}ERROR: Cannot find the folder '$python_package_folder' ${NC}"
  exit 4
fi

# check the python package file
python_package_file="${python_package_folder}/python.zip"
if [ ! -f "$python_package_file" ]; then
  echo -e "${RED}ERROR: Cannot find the file '$python_package_file' ${NC}"
  exit 5
fi

# check the target folder
target_folder="$ROOTFS_DIR"
if [ ! -d "$target_folder" ]; then
  echo -e "${RED}ERROR: Cannot find the target folder '$target_folder' ${NC}"
  exit 6
fi

# enable the selected python package
current_folder="$PWD"
cd "$target_folder" || exit 7
echo -e "${YELLOW}INFO: Unzipping the python package ...${NC}"
unzip -oqq "$python_package_file"
# extend the PATH to $project_root/unpacked/squashfs-root/etc/profile
sed -i 's#export PATH="/usr/sbin:/usr/bin:/sbin:/bin"#export PATH="/usr/sbin:/usr/bin:/sbin:/bin:/opt/sbin:/opt/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin"#' "$ROOTFS_DIR/etc/profile"
cd "$current_folder" || exit 8

echo -e "${GREEN}The python package has been successfully installed ${NC}"

exit 0
