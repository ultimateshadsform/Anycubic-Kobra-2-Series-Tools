#!/bin/bash

# global definitions:
RED='\033[0;31m'
NC='\033[0m'

# files needed
FILES="sw-description sw-description.sig boot-resource uboot boot0 kernel rootfs dsp0 cpio_item_md5"

# check the required tools
TOOL_LIST=("md5sum" "openssl" "sha256sum" "mksquashfs")
i=0
part_num=${#TOOL_LIST[*]}
while [ $i -lt $((part_num)) ]; do
  echo "Checking tool: ${TOOL_LIST[$i]}"
  t=$(which "${TOOL_LIST[$i]}")
  if [ -z "$t" ]; then
    echo -e "${RED}ERROR: Missing tool '${TOOL_LIST[$i]}' ${NC}"
    exit 1
  fi
  i=$(($i + 1))
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
  if [ "$i" != "cpio_item_md5" ] && [ "$i" != "sw-description" ]; then
    hash_new=$(sha256sum "$i" | awk '{print $1}')
    hash_old=$(awk -F= 'BEGIN{v=""} $1~"filename"{v=$2} $1~"sha256"{gsub(/"| |;/,"",v); gsub(/"| |;/,"",$2); print v " " $2}' sw-description | grep "$i" | head -1 | awk '{print $2}')
    sed -i -e "s/$hash_old/$hash_new/g" sw-description
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
echo "SUCCESS: Use the file update/update.swu to do USB update"
echo ""
echo "DONE!"

exit 0
