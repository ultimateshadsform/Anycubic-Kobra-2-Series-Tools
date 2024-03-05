#!/bin/bash

# check the parameters
if [ $# != 2 ]; then
  echo "usage : $0 <project_root> <package>"
  exit 1
fi

project_root="$1"
package="$2"

package_name="${package%.*}"
package_action="${package##*.}"

check_tools "app_version.sh app_model.sh dd printf"

# check the project root folder
if [ ! -d "$project_root" ]; then
  echo -e "${RED}ERROR: Cannot find the folder '$project_root' ${NC}"
  exit 3
fi

# check the target folder
target_folder="$ROOTFS_DIR"
if [ ! -d "$target_folder" ]; then
  echo -e "${RED}ERROR: Cannot find the target folder '$target_folder' ${NC}"
  exit 6
fi

# try to find out the app version (like app_ver="309")
def_target="$ROOTFS_DIR/app/app"
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

if [ "$app_ver" == "3.0.5" ]; then

  # stop the app for looking for inserted webcam
  sed -i 's/video4linux/videoXlinux/g' "$def_target"
  if [ "$app_model" == "K2Pro" ]; then
    # stop the app to log the message 'cannot open video'
    printf "\x00\xf0\x20\xe3" | dd of="$def_target" bs=1 seek=2338704 conv=notrunc
    echo -e "${GREEN}SUCCESS: The 'app' has been patched to stop supporting cameras (K2Pro) ${NC}"
    exit 0
  fi
  if [ "$app_model" == "K2Plus" ]; then
    # stop the app to log the message 'cannot open video'
    printf "\x00\xf0\x20\xe3" | dd of="$def_target" bs=1 seek=2338744 conv=notrunc
    echo -e "${GREEN}SUCCESS: The 'app' has been patched to stop supporting cameras (K2Plus) ${NC}"
    exit 0
  fi
  if [ "$app_model" == "K2Max" ]; then
    # stop the app to log the message 'cannot open video'
    printf "\x00\xf0\x20\xe3" | dd of="$def_target" bs=1 seek=2338744 conv=notrunc
    echo -e "${GREEN}SUCCESS: The 'app' has been patched to stop supporting cameras (K2Max) ${NC}"
    exit 0
  fi
fi

if [ "$app_ver" == "3.0.9" ]; then

  # stop the app for looking for inserted webcam
  sed -i 's/video4linux/videoXlinux/g' "$def_target"
  if [ "$app_model" == "K2Pro" ]; then
    # stop the app to log the message 'cannot open video'
    printf "\x00\xf0\x20\xe3" | dd of="$def_target" bs=1 seek=2339112 conv=notrunc
    echo -e "${GREEN}SUCCESS: The 'app' has been patched to stop supporting cameras (K2Pro) ${NC}"
    exit 0
  fi
  if [ "$app_model" == "K2Plus" ]; then
    # stop the app to log the message 'cannot open video'
    printf "\x00\xf0\x20\xe3" | dd of="$def_target" bs=1 seek=2339152 conv=notrunc
    echo -e "${GREEN}SUCCESS: The 'app' has been patched to stop supporting cameras (K2Plus) ${NC}"
    exit 0
  fi
  if [ "$app_model" == "K2Max" ]; then
    # stop the app to log the message 'cannot open video'
    printf "\x00\xf0\x20\xe3" | dd of="$def_target" bs=1 seek=2339152 conv=notrunc
    echo -e "${GREEN}SUCCESS: The 'app' has been patched to stop supporting cameras (K2Max) ${NC}"
    exit 0
  fi
fi

if [ "$app_ver" == "3.1.0" ]; then

  # stop the app for looking for inserted webcam
  sed -i 's/video4linux/videoXlinux/g' "$def_target"
  if [ "$app_model" == "K2Pro" ]; then
    # stop the app to log the message 'cannot open video'
    printf "\x00\xf0\x20\xe3" | dd of="$def_target" bs=1 seek=2338512 conv=notrunc
    echo -e "${GREEN}SUCCESS: The 'app' has been patched to stop supporting cameras (K2Pro) ${NC}"
    exit 0
  fi
  if [ "$app_model" == "K2Plus" ]; then
    # stop the app to log the message 'cannot open video'
    printf "\x00\xf0\x20\xe3" | dd of="$def_target" bs=1 seek=2338560 conv=notrunc
    echo -e "${GREEN}SUCCESS: The 'app' has been patched to stop supporting cameras (K2Plus) ${NC}"
    exit 0
  fi
  if [ "$app_model" == "K2Max" ]; then
    # stop the app to log the message 'cannot open video'
    printf "\x00\xf0\x20\xe3" | dd of="$def_target" bs=1 seek=2338560 conv=notrunc
    echo -e "${GREEN}SUCCESS: The 'app' has been patched to stop supporting cameras (K2Max) ${NC}"
    exit 0
  fi
fi

echo -e "${RED}ERROR: Unsupported model and version! It requires K2Pro/K2Plus/K2Max with version 3.0.5+ ${NC}"

exit 11
