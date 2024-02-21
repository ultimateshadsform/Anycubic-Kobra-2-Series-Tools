#!/bin/bash

# global definitions:
RED='\033[0;31m'
GREEN='\033[0;32m'
BROWN='\033[0;33m'
NC='\033[0m'

# check the parameters for a model and version
if [ $# != 2 ]; then
  echo "usage  : $0 <model> <version>"
  echo "example: $0 K2Pro 3.0.9"
  echo "example: $0 K2Plus \"3.0.0 3.0.5 3.0.9\""
  echo "example: $0 K2Max all"
  echo "example: $0 all all"
  exit 1
fi

par_models="$1"
par_versions="$2"

if [ "$par_versions" = "all" ] || [ "$par_versions" = "ALL" ]; then
  par_versions="2.3.9 3.0.3 3.0.5 3.0.9"
fi

if [ "$par_models" = "all" ] || [ "$par_models" = "ALL" ]; then
  par_models="K2Pro K2Plus K2Max"
fi

# check the required tools
TOOL_LIST="curl wc awk"
for tool_name in $TOOL_LIST; do
  echo "Checking tool: $tool_name"
  tool_path=$(which "$tool_name")
  if [ -z "$tool_path" ]; then
    if [ ! -f "TOOLS/$tool_name" ]; then
      echo -e "${RED}ERROR: Missing tool '$tool_name' ${NC}"
      exit 3
    fi
  fi
done

for par_model in $par_models; do

  # check the model
  if [ "$par_model" != "K2Pro" ] && [ "$par_model" != "K2Plus" ] && [ "$par_model" != "K2Max" ]; then
    echo -e "${RED}ERROR: Unsupported model '$par_model' ${NC}"
    exit 1
  fi

  for par_version in $par_versions; do
    echo -e "${BROWN}Processing model $par_model version $par_version ...${NC}"
    url_bin="https://cdn.cloud-universe.anycubic.com/ota/${par_model}/AC104_${par_model}_1.1.0_${par_version}_update.bin"
    file_bin="FW/AC104_${par_model}_1.1.0_${par_version}_update.bin"
    rm -f "$file_bin"
    curl "$url_bin" --output "$file_bin"
    result=$(grep "<Error><Code>NoSuchKey</Code>" "$file_bin")
    file_size=$(wc -c "$file_bin" | awk '{print $1}')
    if [ -n "$result" ] || [ "$file_size" -le 1000000 ]; then
      rm -f "$file_bin"
      # no bin update available, try zip update
      url_zip="https://cdn.cloud-universe.anycubic.com/ota/${par_model}/AC104_${par_model}_1.1.0_${par_version}_update.zip"
      file_zip="FW/AC104_${par_model}_1.1.0_${par_version}_update.zip"
      rm -f "$file_zip"
      curl "$url_zip" --output "$file_zip"
      result=$(grep "<Error><Code>NoSuchKey</Code>" "$file_zip")
      file_size=$(wc -c "$file_zip" | awk '{print $1}')
      if [ -n "$result" ] || [ "$file_size" -le 1000000 ]; then
        rm -f "$file_zip"
        # no bin and no zip update available
        echo -e "${RED}ERROR: Cannot find an update for this model and version ${NC}"
        exit 3
      fi
    fi
  done
done

echo ""
echo -e "${GREEN}DONE! The requested firmware has been downloaded in the folder FW ${NC}"
echo ""

exit 0
