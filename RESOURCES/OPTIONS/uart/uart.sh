#!/bin/bash

# global definitions:
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# check the parameters
if [ $# != 2 ]; then
  echo "usage : $0 <project_root> <uart_package>"
  exit 1
fi

project_root="$1"
uart_package="$2"

# check the required tools
TOOL_LIST="unzip"
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

# check the uart package folder
uart_package_folder="${project_root}/RESOURCES/OPTIONS/uart/${uart_package}"
if [ ! -d "$uart_package_folder" ]; then
  echo -e "${RED}ERROR: Cannot find the folder '$uart_package_folder' ${NC}"
  exit 4
fi

# check the uart package file
uart_package_file="${uart_package_folder}/uboot.zip"
if [ ! -f "$uart_package_file" ]; then
  echo -e "${RED}ERROR: Cannot find the file '$uart_package_file' ${NC}"
  exit 5
fi

# check the target folder
target_folder="$project_root/unpacked"
if [ ! -d "$target_folder" ]; then
  echo -e "${RED}ERROR: Cannot find the target folder '$target_folder' ${NC}"
  exit 6
fi

# enable the selected ssh package
current_folder="$PWD"
cd "$target_folder" || exit 7
unzip -o "$uart_package_file"
cd "$current_folder" || exit 8

echo -e "${GREEN}INFO: The UART package has been installed. Version: $uart_package ${NC}"

exit 0
