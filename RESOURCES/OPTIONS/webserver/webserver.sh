#!/bin/bash

# check the parameters
if [ $# != 2 ]; then
  echo "usage : $0 <project_root> <webserver_package>"
  exit 1
fi

project_root="$1"
webserver_package="$2"

package_name="${webserver_package%:*}"
package_port="${webserver_package##*:}"
if [ -z "$package_port" ]; then
  package_port="8000"
fi

check_tools "unzip app_version.sh app_model.sh dd printf"

# check the project root folder
if [ ! -d "$project_root" ]; then
  echo -e "${RED}ERROR: Cannot find the folder '$project_root' ${NC}"
  exit 2
fi

# check the webserver package folder
webserver_package_folder="$OPTIONS_DIR/webserver/$package_name"
if [ ! -d "$webserver_package_folder" ]; then
  echo -e "${RED}ERROR: Cannot find the folder '$webserver_package_folder' ${NC}"
  exit 3
fi

# check the webserver package file
webserver_package_file="${webserver_package_folder}/webserver.zip"
if [ ! -f "$webserver_package_file" ]; then
  echo -e "${RED}ERROR: Cannot find the file '$webserver_package_file' ${NC}"
  exit 4
fi

# check the target folder
target_folder="$ROOTFS_DIR"
if [ ! -d "$target_folder" ]; then
  echo -e "${RED}ERROR: Cannot find the target folder '$target_folder' ${NC}"
  exit 5
fi

# enable the selected webserver package
current_folder="$PWD"
cd "$target_folder" || exit 7
unzip -oqq "$webserver_package_file"
cd "$current_folder" || exit 8

# add "/opt/bin/webfsd -p port" to $project_root/unpacked/squashfs-root/etc/rc.local before the exit 0 line
result=$(grep "/opt/bin/webfsd" "$target_folder/etc/rc.local")
if [ -z "$result" ]; then
  # add it only if not already done
  sed -i "/exit 0/i /opt/bin/webfsd -p $package_port" "$target_folder/etc/rc.local"
fi
# extend the PATH to $project_root/unpacked/squashfs-root/etc/profile
sed -i 's#export PATH="/usr/sbin:/usr/bin:/sbin:/bin"#export PATH="/usr/sbin:/usr/bin:/sbin:/bin:/opt/sbin:/opt/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin"#' "$ROOTFS_DIR/etc/profile"

echo -e "${GREEN}SUCCESS: The selected webserver package has been successfully added ${NC}"
exit 0
