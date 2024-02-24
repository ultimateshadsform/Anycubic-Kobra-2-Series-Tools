#!/bin/bash

# check the parameters
if [ $# != 2 ]; then
  echo "usage : $0 <project_root> <uart_package>"
  exit 1
fi

check_tools "cp"

project_root="$1"
uart_package="$2"

# check the project root folder
if [ ! -d "$project_root" ]; then
  echo -e "${RED}ERROR: Cannot find the folder '$project_root' ${NC}"
  exit 3
fi

# check the uart package folder
uart_package_folder="${OPTIONS_DIR}/uart/${uart_package}"
if [ ! -d "$uart_package_folder" ]; then
  echo -e "${RED}ERROR: Cannot find the folder '$uart_package_folder' ${NC}"
  exit 4
fi

# check the uart files uboot and boot0
uboot_file="${uart_package_folder}/uboot"
if [ ! -f "$uboot_file" ]; then
  echo -e "${RED}ERROR: Cannot find the file '$uboot_file' ${NC}"
  exit 5
fi

boot0_file="${uart_package_folder}/boot0"
if [ ! -f "$boot0_file" ]; then
  echo -e "${RED}ERROR: Cannot find the file '$boot0_file' ${NC}"
  exit 6
fi

# check the target folder
target_folder="$project_root/unpacked"
if [ ! -d "$target_folder" ]; then
  echo -e "${RED}ERROR: Cannot find the target folder '$target_folder' ${NC}"
  exit 7
fi

echo -e "${YELLOW}INFO: Copying the uart files ...${NC}"

echo -e "${YELLOW}INFO: Copying the uart files to $target_folder ...${NC}"

# Copy the uart files to the target folder
cp -f "$uboot_file" "$target_folder"

if [ $? != 0 ]; then
  echo -e "${RED}ERROR: Failed to copy the uboot file ${NC}"
  exit 8
fi

echo -e "${GREEN}INFO: The uboot file has been copied${NC}"

cp -f "$boot0_file" "$target_folder"

if [ $? != 0 ]; then
  echo -e "${RED}ERROR: Failed to copy the boot0 file ${NC}"
  exit 9
fi

echo -e "${GREEN}INFO: The boot0 file has been copied${NC}"

# Overwrite the inittab file
echo -e "${YELLOW}INFO: Overwriting the inittab file ...${NC}"

cat <<EOF >"$target_folder/etc/inittab"
::sysinit:/etc/init.d/rcS S boot
::shutdown:/etc/init.d/rcS K shutdown
::askconsole:/bin/ash --login
EOF

echo -e "${GREEN}INFO: The UART package has been installed. Version: $uart_package ${NC}"

exit 0
