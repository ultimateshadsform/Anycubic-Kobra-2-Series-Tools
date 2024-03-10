#!/bin/bash

# default urls to be replaced
mqtt_urls="mqtt-universe-test.anycubic.com mqtt-universe.anycubic.com mqtt-test.anycubic.com mqtt.anycubic.com"

# server urls to check the message source for app version >= 3.1.0
mqtt_new_urls="myqcloud.com amazonaws.com anycubic.com anycubicloud.com"

project_root="$1"

# check the parameters
if [ $# != 2 ]; then
  echo "usage : $0 <project_root> <mqtt_url>"
  exit 1
fi

def_target="$ROOTFS_DIR/app/app"

def_url="$2"

# check the required tools
check_tools "printf dd grep awk app_version.sh app_model.sh"

# check the project root folder
if [ ! -d "$project_root" ]; then
  echo -e "${RED}ERROR: Cannot find the folder '$project_root' ${NC}"
  exit 2
fi

# check the input file
if [ ! -f "$def_target" ]; then
  echo -e "${RED}ERROR: Cannot find the app file ${NC}"
  exit 3
fi

# try to find out the app version (like app_ver="309")
def_target="$ROOTFS_DIR/app/app"
app_ver=$("$app_version_tool" "$def_target")
if [ $? != 0 ]; then
  echo -e "${RED}ERROR: Cannot find the app version ${NC}"
  exit 4
fi

# check if the target is original or already patched
for url in $mqtt_urls; do
  mqtt_url="mqtts://$url:8883"
  grep "$mqtt_url" "$def_target" &>>/dev/null
  if [ $? -ne 0 ]; then
    echo -e "${RED}ERROR: The 'app' might be already patched. Cannot find the expected URL '$mqtt_url' ${NC}"
    echo -e "${YELLOW}INFO: Will not patch the 'app' file...${NC}"
    exit 0
  fi
done

# patch the target, replace all 4 oem mqtt urls with the provided custom url
for url in $mqtt_urls; do
  mqtt_url="mqtts://$url:8883"
  offset=$(grep --binary-files=text -m1 -b -o "$mqtt_url" "$def_target" | awk -F: '{print $1}')
  if [ -z "$offset" ]; then
    echo -e "${RED}ERROR: The 'app' might be already patched. Cannot find the expected URL '$mqtt_url' ${NC}"
    exit 5
  fi
  printf "mqtts://%s:8883\x00" "$def_url" | dd of="$def_target" bs=1 seek="$offset" conv=notrunc &>>/dev/null
done

ver_int=${app_ver//./}
if [ "$ver_int" -ge 310 ]; then
  # for version >= 3.1.0 patch the server url check, replace all 4 oem mqtt server urls with
  # empty string to trick the check condition

  # try to find out the model
  app_model=$("$app_model_tool" "$def_target")
  if [ $? != 0 ]; then
    echo -e "${RED}ERROR: Cannot find the app model ${NC}"
    exit 6
  fi

  # find if the selected setting file exists
  settings_file="$OPTIONS_DIR/modify_mqtt/${app_ver}/${app_model}"
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
fi

echo -e "${GREEN}INFO: The 'app' file has been successfully patched with the custom MQTT URL ${NC}"

exit 0
