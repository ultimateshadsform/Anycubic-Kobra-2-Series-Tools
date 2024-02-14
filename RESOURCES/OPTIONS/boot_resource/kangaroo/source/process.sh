#!/bin/bash

# global definitions:
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# check for root user
if [[ "$EUID" -ne 0 ]]; then
  echo -e "${RED}ERROR: This script needs to be run with superuser privileges (use sudo)${NC}"
  exit 1
fi

# check the source file
if [ ! -f "boot-resource-src" ]; then
  echo -e "${RED}ERROR: Cannot find the file 'boot-resource-src' ${NC}"
  exit 2
fi

# create a temp folder
rm -rf temp
mkdir temp

# create a copy of the source
rm -f boot-resource
cp boot-resource-src boot-resource
chmod 664 boot-resource

# replace all images in the copy of the source
mount -t vfat boot-resource ./temp
/bin/cp -f ./*.bmp ./temp
umount ./temp
rm -rf temp

# setup the result boot-resource
rm -f ../boot-resource
mv boot-resource ../boot-resource

echo -e "${GREEN}DONE!${NC}"

exit 0
