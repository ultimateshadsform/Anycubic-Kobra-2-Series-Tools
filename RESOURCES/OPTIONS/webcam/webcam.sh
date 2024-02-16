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
app_version_tool=$(which app_version.sh)
app_model_tool=$(which app_model.sh)
TOOL_LIST=("unzip" "app_version.sh" "app_model.sh")
i=0
part_num=${#TOOL_LIST[*]}
while [ $i -lt $((part_num)) ]; do
  toolname=${TOOL_LIST[$i]}
  echo "Checking tool: $toolname"
  tpath=$(which "$toolname")
  if [ -z "$tpath" ]; then
    local_tool_path="$project_root/TOOLS/$toolname"
    if [ ! -f "$local_tool_path" ]; then
      echo -e "${RED}ERROR: Missing tool '$toolname' ${NC}"
      exit 2
    else
      if [ "$toolname" == "app_version.sh" ]; then
        app_version_tool="$local_tool_path"
      fi
      if [ "$toolname" == "app_model.sh" ]; then
        app_model_tool="$local_tool_path"
      fi
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
app_ver=$("$app_version_tool" "$def_target")
if [ $? != 0 ]; then
  echo -e "${RED}ERROR: Cannot find the app version ${NC}"
  exit 9
fi

# try to find out the model
app_model=$("$app_model_tool" "$def_target")
if [ $? != 0 ]; then
  echo -e "${RED}ERROR: Cannot find the app model ${NC}"
  exit 10
fi

# patch the app based on the model and the version

if [ "$app_ver" == "3.0.9" ]; then
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

exit 11
