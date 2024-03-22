#!/bin/bash

username="root"
ip="192.168.1.242"
port="22"

# SCP file transfer
echo "Uploading..."
scp -o StrictHostKeyChecking=no -P $port update/update.swu $username@$ip:/mnt/UDISK/update.swu
# MD5 Calculation
md5sum_local=$(md5sum update/update.swu | awk '{ print $1 }')
echo "MD5 Local : $md5sum_local"
md5sum_remote=$(ssh -p $port $username@$ip "md5sum /mnt/UDISK/update.swu" | awk '{ print $1 }')
echo "MD5 Remote: $md5sum_remote"
if [[ "$md5sum_remote" == "$md5sum_local" ]]; then
    # Getting boot partition and updating firmware
    current_boot_partition=$(ssh -p $port $username@$ip "fw_printenv boot_partition" | awk -F= '{ print $2 }' | tr -d '[:space:]')
    boot_partition="now_B_next_A"
    if [[ "$current_boot_partition" == "bootA" ]]; then
        boot_partition="now_A_next_B"
    fi
    # Update
    echo "Updating..."
    ssh -p $port $username@$ip "swupdate_cmd.sh -i /mnt/UDISK/update.swu -e stable,${boot_partition} -k /etc/swupdate_public.pem"
    echo "SUCCESS!"
    exit 0
else
    # If MD5 checksums don't match, delete the file and retry
    ssh -p $port $username@$ip 'rm -f /mnt/UDISK/update.swu'
    echo "FAILED!"
    exit 1
fi
