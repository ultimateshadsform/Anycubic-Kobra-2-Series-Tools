#!/bin/bash

# global definitions:
RED='\033[0;31m'
NC='\033[0m'

# check the input folder
if [ ! -d "./unpacked/squashfs-root" ]; then
  echo -e "${RED}ERROR: Cannot find the input folder './unpacked/squashfs-root' ${NC}"
  exit 2
fi

# check the input folder
if [ ! -d "RESOURCES/KEYS" ]; then
  echo -e "${RED}ERROR: Cannot find the input folder 'RESOURCES/KEYS' ${NC}"
  exit 3
fi

# check the input folder
if [ ! -d "RESOURCES/OPTIONS" ]; then
  echo -e "${RED}ERROR: Cannot find the input folder 'RESOURCES/OPTIONS' ${NC}"
  exit 4
fi

# check the private key file
if [ ! -f "RESOURCES/KEYS/swupdate_private.pem" ]; then
  echo -e "${RED}ERROR: Cannot find the input file 'RESOURCES/KEYS/swupdate_private.pem' ${NC}"
  echo -e "Use 'openssl genrsa -out swupdate_private.pem' to generate a private key"
  echo -e "Use 'openssl rsa -in swupdate_private.pem -out swupdate_public.pem -outform PEM -pubout' to export the public key"
  exit 5
fi

# check the public key file
if [ ! -f "RESOURCES/KEYS/swupdate_public.pem" ]; then
  echo -e "${RED}ERROR: Cannot find the input file 'RESOURCES/KEYS/swupdate_public.pem' ${NC}"
  echo -e "Use 'openssl rsa -in swupdate_private.pem -out swupdate_public.pem -outform PEM -pubout' to export the public key"
  exit 6
fi

# enable the UART
if [ ! -f "RESOURCES/OPTIONS/uart/uboot" ]; then
  echo -e "${RED}ERROR: Cannot find the input file 'RESOURCES/OPTIONS/uart/uboot' ${NC}"
  echo -e "Use the file uboot from version 2.3.9"
  exit 7
else
  /bin/cp -rf RESOURCES/OPTIONS/uart/* unpacked
fi

# enable root access
if [ ! -d "RESOURCES/OPTIONS/root_access" ]; then
  echo -e "${RED}ERROR: Cannot find the input folder 'RESOURCES/OPTIONS/root_access' ${NC}"
  echo -e "Use the file 'unpacked/squashfs-root/etc/shadow' and set a known root password hash"
  echo -e "Then placed the modified file in 'RESOURCES/OPTIONS/root_access/etc/shadow'"
  exit 8
else
  /bin/cp -rf RESOURCES/OPTIONS/root_access/* unpacked/squashfs-root
fi

# enable custom updates
if [ ! -d "RESOURCES/OPTIONS/custom_update" ]; then
  echo -e "${RED}ERROR: Cannot find the input folder 'RESOURCES/OPTIONS/custom_update' ${NC}"
  echo -e "Place the file 'RESOURCES/KEYS/swupdate_public.pem' in the folder 'RESOURCES/OPTIONS/custom_update/etc/'"
  exit 9
else
  /bin/cp -rf RESOURCES/OPTIONS/custom_update/* unpacked/squashfs-root
fi

# enable ssh
if [ ! -d "RESOURCES/OPTIONS/ssh" ]; then
  echo -e "${RED}ERROR: Cannot find the input folder 'RESOURCES/OPTIONS/ssh' ${NC}"
  exit 9
else
  /bin/cp -rf RESOURCES/OPTIONS/ssh/* unpacked/squashfs-root
fi

# boot resource

# If files exist in RESOURCES/OPTIONS/boot_resource, copy them to the boot partition. Open it with: mount -t vfat file folder

# If files exists inside the folder RESOURCES/OPTIONS/boot_resource, copy them to the boot partition
if [ "$(ls -A RESOURCES/OPTIONS/boot_resource)" ]; then
  # copy the files to the boot partition: Mount it first: mount -t vfat unpacked/boot-resource ./temp
  sudo mount -t vfat unpacked/boot-resource ./temp
  sudo /bin/cp -rf RESOURCES/OPTIONS/boot_resource/* ./temp
  sudo umount ./temp
fi

# If files exists inside the folder RESOURCES/OPTIONS/app_images, copy them to unpacked/squashfs-root/app/resources/images
if [ "$(ls -A RESOURCES/OPTIONS/app_images)" ]; then
  /bin/cp -rf RESOURCES/OPTIONS/app_images/* unpacked/squashfs-root/app/resources/images
fi

echo "DONE! THE STANDARD OPTIONS ARE IMPLEMENTED. IF NEEDED, ADD MORE OPTIONS MANUALLY."

exit 0
