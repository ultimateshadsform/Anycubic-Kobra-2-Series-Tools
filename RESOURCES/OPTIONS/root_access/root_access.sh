#!/bin/bash

# check the parameters
if [ $# != 2 ]; then
  echo "usage : $0 <project_root> <password_hash>"
  exit 1
fi

project_root="$1"
password_hash="$2"

# check the required tools
check_tools "awk"

# check the project root folder
if [ ! -d "$project_root" ]; then
  echo -e "${RED}ERROR: Cannot find the folder '$project_root' ${NC}"
  exit 2
fi

# check the target file
target_file="$ROOTFS_DIR/etc/shadow"
if [ ! -f "$target_file" ]; then
  echo -e "${RED}ERROR: Cannot find the target file '$target_file' ${NC}"
  exit 3
fi

# enable root access by providing known root password hash
shadow_temp="${target_file}_temp"
awk "BEGIN{FS=\":\"; OFS=FS} \$1==\"root\"{\$2=\"$password_hash\"} {print}" "$target_file" >"$shadow_temp" && mv "$shadow_temp" "$target_file"

echo -e "${GREEN}Root access enabled${NC}"

exit 0
