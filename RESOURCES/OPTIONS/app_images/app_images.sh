#!/bin/bash

# check the parameters
if [ $# != 2 ]; then
  echo "usage : $0 <project_root> <image_set>"
  exit 1
fi

project_root="$1"
image_set="$2"

# check the project root folder
if [ ! -d "$project_root" ]; then
  echo -e "${RED}ERROR: Cannot find the folder '$project_root' ${NC}"
  exit 2
fi

# check the image_set folder
image_set_folder="$OPTIONS_DIR/app_images/$image_set"
if [ ! -d "$image_set_folder" ]; then
  echo -e "${RED}ERROR: Cannot find the folder '$image_set_folder' ${NC}"
  exit 3
fi

# check the target folder
target_folder="$ROOTFS_DIR/app/resources/images"
if [ ! -d "$target_folder" ]; then
  echo -e "${RED}ERROR: Cannot find the target folder '$target_folder' ${NC}"
  exit 4
fi

# copy the selected image set to the target
/bin/cp -rf "$image_set_folder" "$target_folder"

echo -e "${GREEN}SUCCESS: The '$image_set' image set has been copied to the target folder ${NC}"

exit 0
