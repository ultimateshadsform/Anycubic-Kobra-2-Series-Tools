#!/bin/bash

project_root="$PWD"

# Source the utils.sh file
source "$project_root/TOOLS/helpers/utils.sh" "$project_root"

# the result of installed options log
installed_options="installed_options.log"

# files needed
FILES="sw-description sw-description.sig boot-resource uboot boot0 kernel rootfs dsp0 cpio_item_md5"

# check the required tools
check_tools "grep md5sum openssl wc awk sha256sum mksquashfs python3 auto_install.py"

# set the custom auto update tool
AUTO_UPDATE_TOOL=$(which "auto_install.py")
if [ -z "$AUTO_UPDATE_TOOL" ]; then
  # if not installed use the local copy
  AUTO_UPDATE_TOOL="TOOLS/auto_install.py"
fi

# remove the last created update
rm -rf update
mkdir update

# pack the squashfs-root folder
cd unpacked || exit 2

# Ask if the user wants to keep existing rootfs
read -r -p "Do you want to keep the existing rootfs? (Only for dev testing. Answer NO.) [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
  echo -e "${YELLOW}Keeping the existing rootfs${NC}"
else
  echo -e "${YELLOW}Deleting the existing rootfs${NC}"
  rm -rf rootfs
  mksquashfs squashfs-root rootfs -comp xz -all-root
fi

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

# check if the auto update is possible
if [ -f "$installed_options" ]; then
  root_pw=$(grep "root_access=" "$installed_options")
  ssh_option=$(grep "ssh=" "$installed_options")
  if [ -z "$root_pw" ] || [ "$root_pw" == 'root_access=""' ] || [ -z "$ssh_option" ]; then
    echo -e "Root access option is not installed, the root password is empty or the ssh is disabled.\nThe auto update is not possible. Please use the USB update procedure."
  else
    # Ask if the user wants to attempt to auto install the update. If yes then run the auto install script
    read -r -p "Do you want to attempt to auto install the update? [y/N] " response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
      # Run the auto update tool
      python3 "$AUTO_UPDATE_TOOL"
    fi
  fi
fi

exit 0
