#!/bin/bash

# global definitions:
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# check the parameters for a model and version
if [ $# != 2 ]; then
  echo "usage  : $0 <model> <version>"
  echo "example: $0 K2Pro 3.0.9"
  exit 1
fi

par_model="$1"
par_version="$2"

# check the model
if [ "$par_model" != "K2Pro" ] && [ "$par_model" != "K2Plus" ] && [ "$par_model" != "K2Max" ]; then
  echo -e "${RED}ERROR: Unsupported model '$par_model' ${NC}"
  exit 1
fi

# check the required tools
TOOL_LIST=("curl" "wc" "awk")
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

echo ""
echo -e "${GREEN}DONE! The requested firmware has been downloaded in the folder FW ${NC}"
echo ""

exit 0
