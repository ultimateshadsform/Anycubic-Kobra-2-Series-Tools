#!/bin/bash

# global definitions:
RED='\033[0;31m'
NC='\033[0m'

# check the parameters
if [ $# != 1 ]; then
  echo "usage : $0 <app_file>"
  exit 1
fi

def_target="$1"

# check the app file
if [ ! -f "$def_target" ]; then
  echo -e "${RED}ERROR: Cannot find the file '$def_target' ${NC}"
  exit 2
fi

# try to find out the app version (like app_ver="3.0.9")
def_target_ver="${def_target}_ver"
offset=$(grep --binary-files=text -m1 -b -o "__FILE__" "$def_target" | awk -F: '{print $1}')
offset20=$((offset + 20))
dd if="$def_target" of="$def_target_ver" bs=1 skip="$offset20" count=8 &>>/dev/null
ver=$(hexdump -C "$def_target_ver" | awk '{print $10}' | head -n 1)
rm -f "$def_target_ver"
# remove the leading and ending pipes
app_ver="${ver//|/}"
# remove the trailing dots
while [ "${app_ver: -1}" == "." ]; do
  app_ver=${app_ver::-1}
done

echo -n "$app_ver"

exit 0
