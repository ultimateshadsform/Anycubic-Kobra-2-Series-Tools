#!/bin/bash

# Part    Start LBA       End LBA         Name
#         Attributes
#         Type GUID
#         Partition GUID
#   1     0x0000a1f8      0x0000d32f      "boot-resource"
#         attrs:  0x8000000000000000
#         type:   ebd0a0a2-b9e5-4433-87c0-68b6b72699c7
#         guid:   a0085546-4166-744a-a353-fca9272b8e45
#   2     0x0000d330      0x0000d527      "env"
#         attrs:  0x8000000000000000
#         type:   ebd0a0a2-b9e5-4433-87c0-68b6b72699c7
#         guid:   a0085546-4166-744a-a353-fca9272b8e46
#   3     0x0000d528      0x0000d71f      "env-redund"
#         attrs:  0x8000000000000000
#         type:   ebd0a0a2-b9e5-4433-87c0-68b6b72699c7
#         guid:   a0085546-4166-744a-a353-fca9272b8e47
#   4     0x0000d720      0x00010857      "bootA"
#         attrs:  0x8000000000000000
#         type:   ebd0a0a2-b9e5-4433-87c0-68b6b72699c7
#         guid:   a0085546-4166-744a-a353-fca9272b8e48
#   5     0x00010858      0x00050913      "rootfsA"
#         attrs:  0x8000000000000000
#         type:   ebd0a0a2-b9e5-4433-87c0-68b6b72699c7
#         guid:   a0085546-4166-744a-a353-fca9272b8e49
#   6     0x00050914      0x000510f3      "dsp0A"
#         attrs:  0x8000000000000000
#         type:   ebd0a0a2-b9e5-4433-87c0-68b6b72699c7
#         guid:   a0085546-4166-744a-a353-fca9272b8e4a
#   7     0x000510f4      0x0005422b      "bootB"
#         attrs:  0x8000000000000000
#         type:   ebd0a0a2-b9e5-4433-87c0-68b6b72699c7
#         guid:   a0085546-4166-744a-a353-fca9272b8e4b
#   8     0x0005422c      0x000942e7      "rootfsB"
#         attrs:  0x8000000000000000
#         type:   ebd0a0a2-b9e5-4433-87c0-68b6b72699c7
#         guid:   a0085546-4166-744a-a353-fca9272b8e4c
#   9     0x000942e8      0x00094ac7      "dsp0B"
#         attrs:  0x8000000000000000
#         type:   ebd0a0a2-b9e5-4433-87c0-68b6b72699c7
#         guid:   a0085546-4166-744a-a353-fca9272b8e4d
#  10     0x00094ac8      0x000d4b83      "rootfs_data"
#         attrs:  0x8000000000000000
#         type:   ebd0a0a2-b9e5-4433-87c0-68b6b72699c7
#         guid:   a0085546-4166-744a-a353-fca9272b8e4e
#  11     0x000d4b84      0x00114c3f      "user"
#         attrs:  0x8000000000000000
#         type:   ebd0a0a2-b9e5-4433-87c0-68b6b72699c7
#         guid:   a0085546-4166-744a-a353-fca9272b8e4f
#  12     0x00114c40      0x0011541f      "private"
#         attrs:  0x8000000000000000
#         type:   ebd0a0a2-b9e5-4433-87c0-68b6b72699c7
#         guid:   a0085546-4166-744a-a353-fca9272b8e50
#  13     0x00115420      0x00e8ffde      "UDISK"
#         attrs:  0x8000000000000000
#         type:   ebd0a0a2-b9e5-4433-87c0-68b6b72699c7
#         guid:   a0085546-4166-744a-a353-fca9272b8e51

project_root="$PWD"

# Source the utils.sh file
source "$project_root/TOOLS/helpers/utils.sh" "$project_root"

# Check if .bin file was passed as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <firmware.bin>"
    exit 1
fi

# Check if the file exists and is a .bin file
if [ ! -f "$1" ]; then
    echo "File not found"
    exit 1
fi

if [[ "$1" != *.bin ]]; then
    echo "File is not a .bin file"
    exit 1
fi

check_tools "dd"

block_size=512

boot_resource_start=0x0000a1f8
boot_resource_end=0x0000d32f

env_start=0x0000d330
env_end=0x0000d527

env_redund_start=0x0000d528
env_redund_end=0x0000d71f

bootA_start=0x0000d720
bootA_end=0x00010857

rootfsA_start=0x00010858
rootfsA_end=0x00050913

dsp0A_start=0x00050914
dsp0A_end=0x000510f3

bootB_start=0x000510f4
bootB_end=0x0005422b

rootfsB_start=0x0005422c
rootfsB_end=0x000942e7

dsp0B_start=0x000942e8
dsp0B_end=0x00094ac7

rootfs_data_start=0x00094ac8
rootfs_data_end=0x000d4b83

user_start=0x000d4b84
user_end=0x00114c3f

private_start=0x00114c40
private_end=0x0011541f

UDISK_start=0x00115420
UDISK_end=0x00e8ffde

# Boot resource
# start - end + 1
boot_resource_size=$(($boot_resource_end - $boot_resource_start + 1))
# Skip is start converted to decimal
boot_resource_skip=$(printf "%d" $boot_resource_start)

# env
env_size=$(($env_end - $env_start + 1))
env_skip=$(printf "%d" $env_start)

# env-redund
env_redund_size=$(($env_redund_end - $env_redund_start + 1))
env_redund_skip=$(printf "%d" $env_redund_start)

# bootA
bootA_size=$(($bootA_end - $bootA_start + 1))
bootA_skip=$(printf "%d" $bootA_start)

# rootfsA
rootfsA_size=$(($rootfsA_end - $rootfsA_start + 1))
rootfsA_skip=$(printf "%d" $rootfsA_start)

# dsp0A
dsp0A_size=$(($dsp0A_end - $dsp0A_start + 1))
dsp0A_skip=$(printf "%d" $dsp0A_start)

# bootB
bootB_size=$(($bootB_end - $bootB_start + 1))
bootB_skip=$(printf "%d" $bootB_start)

# rootfsB
rootfsB_size=$(($rootfsB_end - $rootfsB_start + 1))
rootfsB_skip=$(printf "%d" $rootfsB_start)

# dsp0B
dsp0B_size=$(($dsp0B_end - $dsp0B_start + 1))
dsp0B_skip=$(printf "%d" $dsp0B_start)

# rootfs_data
rootfs_data_size=$(($rootfs_data_end - $rootfs_data_start + 1))
rootfs_data_skip=$(printf "%d" $rootfs_data_start)

# user
user_size=$(($user_end - $user_start + 1))
user_skip=$(printf "%d" $user_start)

# private
private_size=$(($private_end - $private_start + 1))
private_skip=$(printf "%d" $private_start)

# UDISK
UDISK_size=$(($UDISK_end - $UDISK_start + 1))
UDISK_skip=$(printf "%d" $UDISK_start)

# Count is size
# Start is skip

# Make a folder for the extracted files in $project_root/emmc_dump

mkdir -p "$project_root/emmc_dump"

outdir="$project_root/emmc_dump"

echo -e "${YELLOW}Extracting boot-resource...${NC}"
dd if="$1" of="$outdir/boot-resource.bin" bs=$block_size skip=$boot_resource_skip count=$boot_resource_size

echo -e "${YELLOW}Extracting env...${NC}"
dd if="$1" of="$outdir/env.bin" bs=$block_size skip=$env_skip count=$env_size

echo -e "${YELLOW}Extracting env-redund...${NC}"
dd if="$1" of="$outdir/env-redund.bin" bs=$block_size skip=$env_redund_skip count=$env_redund_size

echo -e "${YELLOW}Extracting bootA...${NC}"
dd if="$1" of="$outdir/bootA.bin" bs=$block_size skip=$bootA_skip count=$bootA_size

echo -e "${YELLOW}Extracting rootfsA...${NC}"
dd if="$1" of="$outdir/rootfsA.bin" bs=$block_size skip=$rootfsA_skip count=$rootfsA_size

echo -e "${YELLOW}Extracting dsp0A...${NC}"
dd if="$1" of="$outdir/dsp0A.bin" bs=$block_size skip=$dsp0A_skip count=$dsp0A_size

echo -e "${YELLOW}Extracting bootB...${NC}"
dd if="$1" of="$outdir/bootB.bin" bs=$block_size skip=$bootB_skip count=$bootB_size

echo -e "${YELLOW}Extracting rootfsB...${NC}"
dd if="$1" of="$outdir/rootfsB.bin" bs=$block_size skip=$rootfsB_skip count=$rootfsB_size

echo -e "${YELLOW}Extracting dsp0B...${NC}"
dd if="$1" of="$outdir/dsp0B.bin" bs=$block_size skip=$dsp0B_skip count=$dsp0B_size

echo -e "${YELLOW}Extracting rootfs_data...${NC}"
dd if="$1" of="$outdir/rootfs_data.bin" bs=$block_size skip=$rootfs_data_skip count=$rootfs_data_size

echo -e "${YELLOW}Extracting user...${NC}"
dd if="$1" of="$outdir/user.bin" bs=$block_size skip=$user_skip count=$user_size

echo -e "${YELLOW}Extracting private...${NC}"
dd if="$1" of="$outdir/private.bin" bs=$block_size skip=$private_skip count=$private_size

echo -e "${YELLOW}Extracting UDISK...${NC}"
dd if="$1" of="$outdir/UDISK.bin" bs=$block_size skip=$UDISK_skip count=$UDISK_size

echo -e "${GREEN}Extraction complete${NC}"

exit 0
