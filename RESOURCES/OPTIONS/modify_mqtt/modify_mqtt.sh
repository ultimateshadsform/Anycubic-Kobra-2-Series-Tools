#!/bin/bash

# default urls to be replaced
mqtt_urls="mqtt-universe-test.anycubic.com mqtt-universe.anycubic.com mqtt-test.anycubic.com mqtt.anycubic.com"

project_root="$1"

# check the parameters
if [ $# != 2 ]; then
  echo "usage : $0 <project_root> <mqtt_url>"
  exit 1
fi

def_target="$ROOTFS_DIR/app/app"

def_url="$2"

# check the required tools
check_tools "printf dd grep awk"

# check the project root folder
if [ ! -d "$project_root" ]; then
  echo -e "${RED}ERROR: Cannot find the folder '$project_root' ${NC}"
  exit 3
fi

# check the input file
if [ ! -f "$def_target" ]; then
  echo -e "${RED}ERROR: Cannot find the app file ${NC}"
  exit 2
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
    exit 4
  fi
  printf "mqtts://%s:8883\x00" "$def_url" | dd of="$def_target" bs=1 seek="$offset" conv=notrunc &>>/dev/null
done

echo -e "${GREEN}INFO: The 'app' file has been successfully patched with the custom MQTT URL ${NC}"

exit 0
