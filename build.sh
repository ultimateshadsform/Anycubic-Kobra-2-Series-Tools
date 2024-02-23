#!/bin/bash

project_root="$PWD"

# Source the utils.sh file
source "$project_root/TOOLS/helpers/utils.sh" "$project_root"

# Check if firmware exists in the FW folder else ask the user to download it

# List all files in $FW_DIR and check if there are any files .zip, .bin or .swu
# If there are files, ask the user if they want to use the files in the FW folder else ask the user to download the firmware

# Get all files in the FW folder that are .zip, .bin or .swu
all_files=$(ls $FW_DIR | grep -E ".zip|.bin|.swu")

# If there are no files in the FW folder, ask the user to download the firmware
if [ -z "$all_files" ]; then
    read -p "No firmware files found in the FW folder. Do you want to download the firmware? (y/n) " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo
        echo "Downloading firmware..."
        #  Run fwdl.sh with the model and version as parameters
        $project_root/fwdl.sh $par_model $par_version

    else
        echo
        echo "Please download the firmware and place it in the FW folder"
        exit 1
    fi
fi

# If there are files in the FW folder, ask the user if they want to use the files in the FW folder
if [ -n "$all_files" ]; then
    #   List all firmwares and ask user to pick an available firmware version
    echo "Available firmware versions:"
    for file in $all_files; do
        echo $file
    done
    read -p "Which file do you want to use? " firmware_file
    if [ -f "$FW_DIR/$firmware_file" ]; then
        echo "Using firmware $firmware_file"
    else
        echo "Firmware file not found"
        exit 1
    fi
fi

# Unpack the firmware
echo "Unpacking firmware..."
$project_root/unpack.sh $FW_DIR/$firmware_file
if [ $? -ne 0 ]; then
    echo "Failed to unpack firmware"
    exit 1
fi

# Patch the firmware
echo "Patching firmware..."
$project_root/patch.sh
if [ $? -ne 0 ]; then
    echo "Failed to patch firmware"
    exit 1
fi

# Build the firmware
echo "Building firmware..."
$project_root/pack.sh
if [ $? -ne 0 ]; then
    echo "Failed to build firmware"
    exit 1
fi

echo -e "${GREEN}Firmware build complete${NC}"

exit 0
