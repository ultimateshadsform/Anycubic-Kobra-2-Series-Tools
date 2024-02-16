#!/bin/bash

RED='\033[0;31m'
NC='\033[0m'

# default urls to be replaced
mqtt_urls="mqtt-universe-test.anycubic.com mqtt-universe.anycubic.com mqtt-test.anycubic.com mqtt.anycubic.com"

# check the parameters
if [ $# != 2 ]; then
  echo "usage : $0 <project_root> <mqtt_url>"
  exit 1
fi

def_target="$1/unpacked/squashfs-root/app/app"
def_url="$2"

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
    exit 3
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

exit 0
