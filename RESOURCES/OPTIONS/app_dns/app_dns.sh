#!/bin/bash

# global definitions:
RED='\033[0;31m'
NC='\033[0m'

# check the parameters
if [ $# != 2 ]; then
  echo "usage : $0 <project_root> <dns_replacement>"
  exit 1
fi

project_root="$1"
dns_replacement="$2"

# check the required tools
TOOL_LIST="printf dd grep cut xargs"
for tool_name in $TOOL_LIST; do
  echo "Checking tool: $tool_name"
  tool_path=$(which "$tool_name")
  if [ -z "$tool_path" ]; then
    echo -e "${RED}ERROR: Missing tool '$tool_name' ${NC}"
    exit 1
  fi
done

# check the project root folder
if [ ! -d "$project_root" ]; then
  echo -e "${RED}ERROR: Cannot find the folder '$project_root' ${NC}"
  exit 2
fi

# check the target file
def_target="$project_root/unpacked/squashfs-root/app/app"
if [ ! -f "$def_target" ]; then
  echo -e "${RED}ERROR: Cannot find the target file '$def_target' ${NC}"
  exit 3
fi

# patch the app
old_dns=$(echo -n "$dns_replacement" | cut -d "|" -f 1)
new_dns=$(echo -n "$dns_replacement" | cut -d "|" -f 2)
if [ -z "$old_dns" ] || [ -z "$new_dns" ]; then
  echo -e "${RED}ERROR: The requested DNS replacement is not valid: '$dns_replacement' ${NC}"
  exit 4
fi
dns_url="udp://$old_dns:53"
# find all records with offsets that match the requested old DNS
results=$(grep --binary-files=text -b -o "$dns_url" "$def_target" | xargs echo -n)
if [ -z "$results" ]; then
  echo -e "${RED}ERROR: The 'app' might be already patched. Cannot find the expected DNS '$dns_url' ${NC}"
  exit 5
fi
# replace all found old DNS with the new one
for result in $results; do
  offset=$(echo -n "$result" | awk -F: '{print $1}')
  printf "udp://%s:53\x00" "$new_dns" | dd of="$def_target" bs=1 seek="$offset" conv=notrunc &>>/dev/null
done

exit 0
