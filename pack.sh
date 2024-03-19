#!/bin/bash

project_root="$PWD"

# Source the utils.sh file
source "$project_root/TOOLS/helpers/utils.sh" "$project_root"

# files needed
FILES="sw-description sw-description.sig boot-resource uboot boot0 kernel rootfs dsp0 cpio_item_md5"

# check the required tools
check_tools "grep md5sum openssl wc awk sha256sum mksquashfs"

# remove the last created update
rm -rf update
mkdir update

# pack the squashfs-root folder
cd unpacked || exit 2

echo -e "${YELLOW}Deleting the existing rootfs${NC}"
rm -rf rootfs
mksquashfs squashfs-root rootfs -comp xz -all-root

# check if the updated rootfs can fit in the partitions rootfsA/B
file_size=$(wc -c rootfs | awk '{print $1}')
if [ "$file_size" -ge 134217729 ]; then
  echo -e "${RED}ERROR: The size of the file 'unpacked/rootfs' is larger than the max 128MB allowed.\Please disable some of the less important options and try again! ${NC}"
  cd ..
  exit 3
fi

# check the input files
for i in $FILES; do
  if [ "$i" != "cpio_item_md5" ] && [ ! -f "$i" ]; then
    echo -e "${RED}ERROR: Cannot find the input file '$i' ${NC}"
    cd ..
    exit 4
  fi
done

# update sw-description
rm -f cpio_item_md5
for i in $FILES; do
  if [ "$i" != "cpio_item_md5" ] && [ "$i" != "sw-description" ] && [ "$i" != "sw-description.sig" ]; then
    hash_new=$(sha256sum "$i" | awk '{print $1}')
    hash_old=$(awk -F= 'BEGIN{v=""} $1~"filename"{v=$2} $1~"sha256"{gsub(/"| |;/,"",v); gsub(/"| |;/,"",$2); print v " " $2}' sw-description | grep "$i" | head -1 | awk '{print $2}')
    if [ -n "$hash_old" ]; then
      sed -i -e "s/$hash_old/$hash_new/g" sw-description
    else
      echo -e "${RED}ERROR: Cannot find the hash for: '$i' ${NC}"
      cd ..
      exit 5
    fi
  fi
done

# create cpio_item_md5
rm -f cpio_item_md5
for i in $FILES; do
  if [ "$i" != "cpio_item_md5" ]; then
    hash=$(md5sum "$i")
    echo "$hash" >>cpio_item_md5
  fi
done

# sign the file sw-description
rm -f sw-description.sig
openssl dgst -sha256 -sign ../RESOURCES/KEYS/swupdate_private.pem sw-description >sw-description.sig

# pack the input files as update.swu
for i in $FILES; do echo "$i"; done | cpio -ov -H crc >../update/update.swu

cd ..

echo ""
echo -e "${GREEN}Packing done: Use the file update/update.swu to do USB update${NC}"
echo ""

# select a config file
selected_config_file="options.cfg"
if [ $# -eq 1 ]; then
  cfg_file="$project_root/$1"
  if [ -f "$cfg_file" ]; then
    # it is a configuration file with ext
    selected_config_file="$cfg_file"
  elif [ -f "${cfg_file}.cfg" ]; then
    echo "${cfg_file}.cfg"
    # it is a configuration file without ext
    selected_config_file="${cfg_file}.cfg"
  fi
fi

# check if the auto update is enabled and get the selected tool
auto_install_tool=""
if [ -f "$selected_config_file" ]; then

  # parse the enabled options that have a set value
  options=$(awk -F '=' '{if (! ($0 ~ /^;/) && ! ($0 ~ /^#/) && ! ($0 ~ /^$/) && ! ($2 == "")) print $1}' "$selected_config_file")

  # for each enabled option
  for option in $options; do
    parameters=$(awk -F '=' "{if (! (substr(\$0,1,1) == \"#\") && ! (substr(\$0,1,1) == \";\") && ! (\$1 == \"\") && ! (\$2 == \"\") && (\$1 ~ /$option/ ) ) print \$2}" "$selected_config_file" | head -n 1)
    # replace the project root requests
    parameter="${parameters/@/"$project_root"}"
    # remove the leading and ending double quotes
    parameter=$(echo "$parameter" | sed -e 's/^"//' -e 's/"$//')
    # remove the leading and ending single quotes
    parameter=$(echo "$parameter" | sed -e 's/^'\''//' -e 's/'\''$//')
    if [ "$option" = "auto_install" ]; then
      auto_install_tool="$parameter"
    fi
  done
fi

# use the auto install tool if present
if [ -f "$auto_install_tool" ]; then
  # Ask if the user wants to attempt to auto install the update now. If yes then run the auto install script
  read -r -p "Do you want to attempt to auto install the update? [y/N] " response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    # Run the auto update tool
    if [[ "$auto_install_tool" == *.py ]]; then
      python3 "$auto_install_tool"
    else
      "$auto_install_tool"
    fi
  fi
fi

exit 0
