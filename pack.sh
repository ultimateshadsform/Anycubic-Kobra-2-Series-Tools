#!/bin/bash

# global definitions:
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# files needed
FILES="sw-description sw-description.sig boot-resource uboot boot0 kernel rootfs dsp0 cpio_item_md5"

# check the required tools
TOOL_LIST="md5sum openssl sha256sum mksquashfs"
for tool_name in $TOOL_LIST; do
  echo "Checking tool: $tool_name"
  tool_path=$(which "$tool_name")
  if [ -z "$tool_path" ]; then
    echo -e "${RED}ERROR: Missing tool '$tool_name' ${NC}"
    exit 1
  fi
done

# remove the last created update
rm -rf update
mkdir update

# pack the squashfs-root folder
cd unpacked || exit 2
rm -rf rootfs
mksquashfs squashfs-root rootfs -comp xz -all-root

# check the input files
for i in $FILES; do
  if [ "$i" != "cpio_item_md5" ] && [ ! -f "$i" ]; then
    echo -e "${RED}ERROR: Cannot find the input file '$i' ${NC}"
    cd ..
    exit 3
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
      exit 4
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
# Check if md5sum is available
if [ -z "$(which md5sum)" ]; then
  echo -e "${RED}ERROR: Cannot find the tool 'md5sum' You will need to calculate the md5sum manually${NC}"
  exit 0
else
  echo -e "md5sum: $(md5sum update/update.swu)"
fi
echo ""

# Ask if the user wants to attempt to auto install the update. If yes then run the auto install script
read -r -p "Do you want to attempt to auto install the update? [y/N] " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
  # Run TOOLS/auto_install.py
  python3 TOOLS/auto_install.py
fi

exit 0
