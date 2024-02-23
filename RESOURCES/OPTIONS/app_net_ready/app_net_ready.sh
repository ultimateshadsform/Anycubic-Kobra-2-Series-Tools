#!/bin/bash

# check the parameters
if [ $# != 2 ]; then
  echo "usage : $0 <project_root> <settings>"
  exit 1
fi

project_root="$1"
settings="$2"

# check the required tools
app_version_tool=$(which app_version.sh)
app_model_tool=$(which app_model.sh)

check_tools "app_version.sh app_model.sh cut dd"

# check the project root folder
if [ ! -d "$project_root" ]; then
  echo -e "${RED}ERROR: Cannot find the folder '$project_root' ${NC}"
  exit 3
fi

# check the target folder
target_folder="$ROOTFS_DIR"
if [ ! -d "$target_folder" ]; then
  echo -e "${RED}ERROR: Cannot find the target folder '$target_folder' ${NC}"
  exit 4
fi

# try to find out the app version (like app_ver="309")
def_target="$ROOTFS_DIR/app/app"
app_ver=$("$app_version_tool" "$def_target")
if [ $? != 0 ]; then
  echo -e "${RED}ERROR: Cannot find the app version ${NC}"
  exit 5
fi

# try to find out the model
app_model=$("$app_model_tool" "$def_target")
if [ $? != 0 ]; then
  echo -e "${RED}ERROR: Cannot find the app model ${NC}"
  exit 6
fi

# find if the selected setting file exists
settings_file="$OPTIONS_DIR/app_net_ready/$settings/${app_ver}.${app_model}"
if [ ! -f "$settings_file" ]; then
  echo -e "${RED}ERROR: Unsupported model and version! Cannot find the settings file '$settings_file' ${NC}"
  exit 7
fi

# patch the app based on the model and the version
while read -r line; do
  settings_data=$(echo -n "$line" | cut -d "@" -f 1)
  settings_addr=$(echo -n "$line" | cut -d "@" -f 2)
  printf "$settings_data" | dd of="$def_target" bs=1 seek="$settings_addr" conv=notrunc
done <"$settings_file"

echo -e "${GREEN}SUCCESS: The 'app_net_ready' settings have been applied ${NC}"

exit 0
