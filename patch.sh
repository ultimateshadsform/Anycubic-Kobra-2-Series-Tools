#!/bin/bash

# the default options file
optionsfile="options.cfg"

# global definitions:
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
project_root="$PWD"

# check the parameters for a custom options file
if [ $# == 1 ]; then
  optionsfile="$1"
  if [ ! -f "$optionsfile" ]; then
    optionsfile="${optionsfile}.cfg"
  fi
fi

# check the options file
if [ ! -f "$optionsfile" ]; then
  echo -e "${RED}ERROR: Cannot find the '$optionsfile' file ${NC}"
  exit 1
fi

# check the required tools
TOOL_LIST=("awk")
i=0
part_num=${#TOOL_LIST[*]}
while [ $i -lt $((part_num)) ]; do
  echo "Checking tool: ${TOOL_LIST[$i]}"
  t=$(which "${TOOL_LIST[$i]}")
  if [ -z "$t" ]; then
    if [ ! -f "TOOLS/${TOOL_LIST[$i]}" ]; then
      echo -e "${RED}ERROR: Missing tool '${TOOL_LIST[$i]}' ${NC}"
      exit 2
    fi
  fi
  i=$(($i + 1))
done

# parse the enabled options that have a set value
options=$(awk -F '=' '{if (! ($0 ~ /^;/) && ! ($0 ~ /^#/) && ! ($0 ~ /^$/) && ! ($2 == "")) print $1}' "$optionsfile")

# execute the enabled options
for option in $options; do
  echo "Processing option '$option' ..."
  # parse the parameters (only from the first found option)
  # duplicated options are not supported, if needed use more parameters for the same listed option:
  # startup_script="script1.sh" "script2.sh" "script3.sh"
  parameters=$(awk -F '=' "{if (! (substr(\$0,1,1) == \"#\") && ! (substr(\$0,1,1) == \";\") && ! (\$1 == \"\") && ! (\$2 == \"\") && (\$1 ~ /$option/ ) ) print \$2}" "$optionsfile" | head -n 1)
  # replace the project root requests
  parameters="${parameters/@/"$project_root"}"
  # execute the script
  opt_script="${project_root}/RESOURCES/OPTIONS/${option}/${option}.sh"
  if [ ! -f "$opt_script" ]; then
    echo -e "${RED}ERROR: Cannot find the file '$opt_script' ${NC}"
    exit 3
  fi
  "$opt_script" "$project_root" "$parameters"
  if [ $? -ne 0 ]; then
    # errors found, exit
    echo "Errors found! The patching has been canceled."
    exit 4
  fi
done

echo ""
echo -e "${GREEN}DONE! THE SELECTED OPTIONS ARE IMPLEMENTED. IF NEEDED, ADD MORE OPTIONS MANUALLY.${NC}"
echo ""

exit 0
