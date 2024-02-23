#!/bin/bash

# check the parameters
if [ $# != 2 ]; then
  echo "usage : $0 <project_root> <dns_replacement>"
  exit 1
fi

project_root="$1"
dns_replacement="$2"

# check the required tools
check_tools "printf dd grep cut xargs"

# check the project root folder
if [ ! -d "$project_root" ]; then
  echo -e "${RED}ERROR: Cannot find the folder '$project_root' ${NC}"
  exit 2
fi

# check the target file
def_target="$ROOTFS_DIR/app/app"
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
  echo -e "${YELLOW}INFO: Will not patch the 'app' file...${NC}"
  exit 0
fi
# replace all found old DNS with the new one
for result in $results; do
  offset=$(echo -n "$result" | awk -F: '{print $1}')
  printf "udp://%s:53\x00" "$new_dns" | dd of="$def_target" bs=1 seek="$offset" conv=notrunc &>>/dev/null
done

echo -e "${GREEN}SUCCESS: The 'app' has been patched with the new DNS '$new_dns' ${NC}"

exit 0
