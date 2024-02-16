#!/bin/bash

# global definitions:
RED='\033[0;31m'
NC='\033[0m'

# check the parameters
if [ $# != 2 ]; then
  echo "usage : $0 <project_root> <webcam_package>"
  exit 1
fi

project_root="$1"
webcam_package="$2"

# check the required tools
TOOL_LIST=("unzip")
i=0
part_num=${#TOOL_LIST[*]}
while [ $i -lt $((part_num)) ]; do
  echo "Checking tool: ${TOOL_LIST[$i]}"
  t=$(which "${TOOL_LIST[$i]}")
  if [ -z "$t" ]; then
    if [ ! -f "TOOLS/${TOOL_LIST[$i]}" ]; then
      echo -e "${RED}ERROR: Missing tool '${TOOL_LIST[$i]}' ${NC}"
      exit 2
    fi
  fi
  i=$(($i + 1))
done

# check the project root folder
if [ ! -d "$project_root" ]; then
  echo -e "${RED}ERROR: Cannot find the folder '$project_root' ${NC}"
  exit 3
fi

# check the webcam package folder
webcam_package_folder="${project_root}/RESOURCES/OPTIONS/webcam/${webcam_package}"
if [ ! -d "$webcam_package_folder" ]; then
  echo -e "${RED}ERROR: Cannot find the folder '$webcam_package_folder' ${NC}"
  exit 4
fi

# check the webcam package file
webcam_package_file="${webcam_package_folder}/webcam.zip"
if [ ! -f "$webcam_package_file" ]; then
  echo -e "${RED}ERROR: Cannot find the file '$webcam_package_file' ${NC}"
  exit 5
fi

# check the target folder
target_folder="$project_root/unpacked/squashfs-root"
if [ ! -d "$target_folder" ]; then
  echo -e "${RED}ERROR: Cannot find the target folder '$target_folder' ${NC}"
  exit 6
fi

# enable the selected webcam package
current_folder="$PWD"
cd "$target_folder" || exit 7
unzip -o "$webcam_package_file"
cd "$current_folder" || exit 8

# try to find out the app version (like app_ver="309")
def_target="$project_root/unpacked/squashfs-root/app/app"
def_target_ver="${def_target}_ver"
offset=$(grep --binary-files=text -m1 -b -o "__FILE__" "$def_target" | awk -F: '{print $1}')
offset20=$((offset + 20))
dd if="$def_target" of="$def_target_ver" bs=1 skip="$offset20" count=8 &>>/dev/null
ver=$(hexdump -C "$def_target_ver" | awk '{print $10}' | head -n 1)
rm -f "$def_target_ver"
ver="${ver//./}"
app_ver="${ver//|/}"

# try to find out the model
offset_max=$(grep --binary-files=text -m1 -b -o "unmodifiable_max.cfg" "$def_target" | awk -F: '{print $1}')
offset_plus=$(grep --binary-files=text -m1 -b -o "unmodifiable_plus.cfg" "$def_target" | awk -F: '{print $1}')
app_model="K2Pro"
if [ -n "$offset_plus" ]; then
  app_model="K2Plus"
fi
if [ -n "$offset_max" ]; then
  app_model="K2Max"
fi

echo "DETECTED PRINTER MODEL:    $app_model"
echo "DETECTED FIRMWARE VERSION: $app_ver"
sleep 1

# patch the app based on the model and the version

if [ "$app_ver" == "309" ]; then
  # stop the app for looking for inserted webcam
  sed -i 's/video4linux/videoXlinux/g' "$def_target"
  if [ "$app_model" == "K2Pro" ]; then
    # stop the app to log the message 'cannot open video'
    printf "\x00\xf0\x20\xe3" | dd of="$def_target" bs=1 seek=2339112 conv=notrunc &>>/dev/null
    exit 0
  fi
  if [ "$app_model" == "K2Plus" ]; then
    # stop the app to log the message 'cannot open video'
    printf "\x00\xf0\x20\xe3" | dd of="$def_target" bs=1 seek=2339152 conv=notrunc &>>/dev/null
    exit 0
  fi
  if [ "$app_model" == "K2Max" ]; then
    # stop the app to log the message 'cannot open video'
    printf "\x00\xf0\x20\xe3" | dd of="$def_target" bs=1 seek=2339152 conv=notrunc &>>/dev/null
    exit 0
  fi
fi

echo -e "${RED}ERROR: Unsupported model and version! It requires K2Pro/K2Plus/K2Max with version 3.0.9+ ${NC}"

exit 9
