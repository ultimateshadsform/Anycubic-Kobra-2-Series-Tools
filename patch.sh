#!/bin/bash

# the default options file
optionsfile="options.cfg"

# the result of installed options log
installed_options="installed_options.log"

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
TOOL_LIST="awk"
for tool_name in $TOOL_LIST; do
  echo "Checking tool: $tool_name"
  tool_path=$(which "$tool_name")
  if [ -z "$tool_path" ]; then
    echo -e "${RED}ERROR: Missing tool '$tool_name' ${NC}"
    exit 1
  fi
done

# remove the old result file for the installed options
rm -f "$installed_options"

# parse the enabled options that have a set value
options=$(awk -F '=' '{if (! ($0 ~ /^;/) && ! ($0 ~ /^#/) && ! ($0 ~ /^$/) && ! ($2 == "")) print $1}' "$optionsfile")

# for each enabled option
for option in $options; do
  echo "Processing option '$option' ..."
  # parse the parameters (only from the first found option)
  # duplicated options are not supported, if needed use list of parameters for the same option:
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
  # for each parameter in the list
  for parameter in $parameters; do
    # remove the leading and ending double quotes
    param=$(echo "$parameter" | sed -e 's/^"//' -e 's/"$//')
    # remove the leading and ending single quotes
    par=$(echo "$param" | sed -e 's/^'\''//' -e 's/'\''$//')
    # remove the leading and ending square brackets
    req_option=$(echo "$par" | sed -e 's/^\[//' -e 's/\]$//')
    if [ "$par" == "$req_option" ]; then
      # current parameter requires processing
      "$opt_script" "$project_root" "$par"
      if [ $? -ne 0 ]; then
        # errors found, exit
        echo "Errors found! The patching has been canceled."
        exit 4
      fi
      # set this option as already installed
      echo "$option=\"$par\"" >>"$installed_options"
    else
      # this is an option requirement that needs validation
      found=""
      for opt in $options; do
        if [ "$opt" == "$req_option" ]; then
          found="$opt"
          break
        fi
      done
      if [ -z "$found" ]; then
        # required option is missing or not enabled
        echo -e "${RED}ERROR: Option '$option' requires option '$req_option' which is missing or not enabled. ${NC}"
        exit 5
      fi
      echo -e "${GREEN}Option '$option' requires option '$req_option'. This requirement was successfuly validated. ${NC}"
    fi
  done
done

echo ""
echo -e "${GREEN}DONE! The selected options are successfuly processed.${NC}\nYou may do manually more changes in the 'unpacked' folder if needed."
echo ""

exit 0
