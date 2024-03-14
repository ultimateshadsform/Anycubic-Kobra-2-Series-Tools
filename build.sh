#!/bin/bash

project_root="$PWD"

# Source the utils.sh file
source "$project_root/TOOLS/helpers/utils.sh" "$project_root"

# 0 arguments: interactive mode
# 1 argument: firmware file or configuration file
# 2 arguments: firmware file and configuration file
usage() {
    echo "usage : $0 [firmware_file] [configuration_file]"
    exit 1
}

# selected fw file
selected_firmware_file=""

# selected config file
selected_config_file="options.cfg"

# check first for a default file set by update.bin|zip|swu
default_firmware_file=""
if [ -f "$FW_DIR/update.swu" ]; then
    default_firmware_file="$FW_DIR/update.swu"
elif [ -f "$FW_DIR/update.zip" ]; then
    default_firmware_file="$FW_DIR/update.zip"
elif [ -f "$FW_DIR/update.bin" ]; then
    default_firmware_file="$FW_DIR/update.bin"
fi

if [ $# -eq 0 ]; then
    # no arguments provided
    if [ -n "$default_firmware_file" ]; then
        # but default file exists, use it
        selected_firmware_file="$default_firmware_file"
    fi
elif [ $# -eq 1 ]; then
    # one argument provided
    fw_file="$1"
    fw_file_ext="${fw_file##*.}"
    if [ "$fw_file_ext" = "swu" ] || [ "$fw_file_ext" = "bin" ] || [ "$fw_file_ext" = "zip" ]; then
        if [ -f "$fw_file" ]; then
            # it is a valid firmware file
            selected_firmware_file="$fw_file"
        elif [ -f "$FW_DIR/$fw_file" ]; then
            selected_firmware_file="$FW_DIR/$fw_file"
        else
            usage
        fi
    else
        cfg_file="$project_root/$1"
        if [ -f "$cfg_file" ]; then
            # it is a configuration file with ext
            selected_config_file="$cfg_file"
        elif [ -f "${cfg_file}.cfg" ]; then
            echo "${cfg_file}.cfg"
            # it is a configuration file without ext
            selected_config_file="${cfg_file}.cfg"
        else
            usage
        fi
        selected_firmware_file="$default_firmware_file"
    fi
elif [ $# -eq 2 ]; then
    # two arguments provided
    fw_file="$1"
    fw_file_ext="${fw_file##*.}"
    if [ "$fw_file_ext" = "swu" ] || [ "$fw_file_ext" = "bin" ] || [ "$fw_file_ext" = "zip" ]; then
        if [ -f "$fw_file" ]; then
            # it is a valid firmware file
            selected_firmware_file="$fw_file"
        elif [ -f "$FW_DIR/$fw_file" ]; then
            selected_firmware_file="$FW_DIR/$fw_file"
        else
            usage
        fi
    else
        usage
    fi
    cfg_file="$project_root/$2"
    if [ -f "$cfg_file" ]; then
        # it is a configuration file with ext
        selected_config_file="$cfg_file"
    elif [ -f "${cfg_file}.cfg" ]; then
        # it is a configuration file without ext
        selected_config_file="${cfg_file}.cfg"
    else
        usage
    fi
elif [ $# -ge 3 ]; then
    # 3 or more arguments provided
    usage
fi

# check the config file for build_input and build_output options
build_input=""
build_output=""
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
        if [ "$option" = "build_input" ]; then
            build_input="$parameter"
        fi
        if [ "$option" = "build_output" ]; then
            build_output="$parameter"
        fi
    done
fi

if [ -z "$selected_firmware_file" ] && [ -n "$build_input" ] && [ -f "$build_input" ]; then
    # no fw file provided but the config file has a valid fw file set, use that file
    selected_firmware_file="$build_input"
fi

if [ -z "$selected_firmware_file" ]; then

    # No firmware file selected by the user: interactive mode

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
            read -p "Enter version: " par_version
            read -p "Enter model: " par_model
            echo "Downloading firmware..."
            #  Run fwdl.sh with the model and version as parameters
            $project_root/fwdl.sh $par_model $par_version
            all_files=$(ls $FW_DIR | grep -E ".zip|.bin|.swu")
        else
            echo
            echo "Please download the firmware and place it in the FW folder"
            exit 2
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
            exit 3
        fi
    fi
    selected_firmware_file="$FW_DIR/$firmware_file"
fi

# Unpack the firmware
echo "Unpacking firmware..."
"$project_root/unpack.sh" "$selected_firmware_file"
if [ $? -ne 0 ]; then
    echo "Failed to unpack firmware"
    exit 4
fi

# Patch the firmware
echo "Patching firmware..."
"$project_root/patch.sh" "$selected_config_file"
if [ $? -ne 0 ]; then
    echo "Failed to patch firmware"
    exit 5
fi

# Build the firmware
echo "Building firmware..."
"$project_root/pack.sh"
if [ $? -ne 0 ]; then
    echo "Failed to build firmware"
    exit 6
fi

# Process the output file if set
if [ -n "$build_output" ]; then
    rm -f "$project_root/update.zip"
    zip -r "$project_root/update.zip" update
    /bin/cp -f "$project_root/update.zip" "$build_output"
    rm -f "$project_root/update.zip"
fi

echo
echo -e "${YELLOW}Selected firmware file: $selected_firmware_file ${NC}"
echo -e "${YELLOW}Selected configuration file: $selected_config_file ${NC}"
echo -e "${GREEN}Firmware build complete ${NC}"
echo

exit 0
