#!/bin/bash

# global definitions:
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PURPLE='\033[0;35m'
NC='\033[0m'

FW_DIR="$project_root/FW"

OPTIONS_DIR="$project_root/RESOURCES/OPTIONS"

KEYS_DIR="$project_root/RESOURCES/KEYS"

TEMP_DIR="$project_root/temp"

TOOLS_DIR="$project_root/TOOLS"

ROOTFS_DIR="$project_root/unpacked/squashfs-root"

# function to check tools with tool list as parameter
check_tools() {
    TOOL_LIST="$1"
    for tool_name in $TOOL_LIST; do
        echo -e "${PURPLE}Checking tool: $tool_name${NC}"
        if [[ $tool_name == *.sh ]]; then
            tool_path="$TOOLS_DIR/$tool_name"

            # Get name of the .sh file without the extension
            tool_name=$(echo $tool_name | sed 's/\.sh//')

            # Set variable to the name of the tool without the extension and add _tool to the end
            tool_name_var="${tool_name}_tool"

            # Set the path to the tool to TOOL_DIR/tool_name with the .sh extension
            tool_path_var="${TOOLS_DIR}/${tool_name}.sh"

            # Export the dynamic variable
            export $tool_name_var=$tool_path_var
        else
            tool_path=$(which $tool_name)
            if [ -z "$tool_path" ]; then
                if [ ! -f "$TOOLS_DIR/$tool_name" ]; then
                    echo -e "${RED}ERROR: Missing tool '$tool_name' ${NC}"
                    exit 3
                fi
            fi
        fi
    done

    echo -e "${GREEN}SUCCESS: All tools are available${NC}"
}

export -f check_tools
export RED GREEN YELLOW PURPLE NC FW_DIR OPTIONS_DIR KEYS_DIR TEMP_DIR TOOLS_DIR ROOTFS_DIR
