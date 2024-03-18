#!/bin/bash

project_root="$PWD"

# Source the utils.sh file
source "$project_root/TOOLS/helpers/utils.sh" "$project_root"

# check the parameters for a model and version
if [ $# != 2 ]; then
  echo "usage  : $0 <model> <version>"
  echo "example: $0 K2Pro 3.0.9"
  echo "example: $0 K2Plus \"3.0.0 3.0.5 3.0.9 3.1.0\""
  echo "example: $0 K2Max all"
  echo "example: $0 K2Pro latest"
  echo "example: $0 all all"
  echo "example: $0 K2Pro scan"
  exit 1
fi

par_models="$1"
par_versions="$2"

stop_after_error=1
downloaded=0

if [ "$par_versions" = "latest" ] || [ "$par_versions" = "LATEST" ] || [ "$par_versions" = "last" ] || [ "$par_versions" = "LAST" ]; then
  par_versions=$(curl -s "https://raw.githubusercontent.com/AGG2017/ACK2-Webserver/master/latest_version.txt")
fi

if [ "$par_versions" = "all" ] || [ "$par_versions" = "ALL" ]; then
  par_versions="2.3.9 3.0.3 3.0.5 3.0.9 3.1.0 3.1.2"
fi

if [ "$par_versions" = "scan" ] || [ "$par_versions" = "SCAN" ]; then
  latest=$(curl -s "https://raw.githubusercontent.com/AGG2017/ACK2-Webserver/master/latest_version.txt")
  ver_h=$(echo "$latest" | awk -F. '{print $1}')
  ver_m=$(echo "$latest" | awk -F. '{print $2}')
  ver_l=$(echo "$latest" | awk -F. '{print $3}')
  par_versions=""
  for i in {1..100}; do
    ver_l=$((ver_l + 1))
    if [ $ver_l -ge 10 ]; then
      ver_l=0
      ver_m=$((ver_m + 1))
      if [ $ver_m -ge 10 ]; then
        ver_m=0
        ver_h=$((ver_h + 1))
      fi
    fi
    version="${ver_h}.${ver_m}.${ver_l}"
    if [ -z "$par_versions" ]; then
      par_versions="${version}"
    else
      par_versions="${par_versions} ${version}"
    fi
  done
  stop_after_error=0
fi

if [ "$par_models" = "all" ] || [ "$par_models" = "ALL" ]; then
  par_models="K2Pro K2Plus K2Max"
fi

# check the required tools
check_tools "curl wc awk"

for par_model in $par_models; do

  # check the model
  if [ "$par_model" != "K2Pro" ] && [ "$par_model" != "K2Plus" ] && [ "$par_model" != "K2Max" ]; then
    echo -e "${RED}ERROR: Unsupported model '$par_model' ${NC}"
    exit 1
  fi

  for par_version in $par_versions; do
    echo -e "${YELLOW}Processing model $par_model version $par_version ...${NC}"
    ver_int=${par_version//./}
    if [ "$ver_int" -le 309 ]; then
      # old url format up to 3.0.9
      url_bin="https://cdn.cloud-universe.anycubic.com/ota/${par_model}/AC104_${par_model}_1.1.0_${par_version}_update.bin"
      file_bin="FW/AC104_${par_model}_1.1.0_${par_version}_update.bin"
      rm -f "$file_bin"
      curl "$url_bin" --output "$file_bin"
      result=$(grep "<Code>NoSuchKey</Code>" "$file_bin")
      file_size=$(wc -c "$file_bin" | awk '{print $1}')
      if [ -n "$result" ] || [ "$file_size" -le 1000000 ]; then
        rm -f "$file_bin"
        # no bin update available, try zip update
        url_zip="https://cdn.cloud-universe.anycubic.com/ota/${par_model}/AC104_${par_model}_1.1.0_${par_version}_update.zip"
        file_zip="FW/AC104_${par_model}_1.1.0_${par_version}_update.zip"
        rm -f "$file_zip"
        curl "$url_zip" --output "$file_zip"
        result=$(grep "<Code>NoSuchKey</Code>" "$file_zip")
        file_size=$(wc -c "$file_zip" | awk '{print $1}')
        if [ -n "$result" ] || [ "$file_size" -le 1000000 ]; then
          rm -f "$file_zip"
          # no bin and no zip update available
          echo -e "${RED}ERROR: Cannot find an update for this model and version ${NC}"
          if [ $stop_after_error -eq 1 ]; then
            exit 3
          fi
        else
          downloaded=$((downloaded + 1))
        fi
      fi
    else
      if [ "$ver_int" -le 311 ]; then
        # url format 3.1.0
        par_model_str="k2PRO"
        par_model_id="20021"
        if [ "$par_model" = "K2Plus" ]; then
          par_model_str="k2PLUS"
          par_model_id="20022"
        fi
        if [ "$par_model" = "K2Max" ]; then
          par_model_str="k2MAX"
          par_model_id="20023"
        fi
        url_bin="https://cdn.cloud-universe.anycubic.com/ota/prod/${par_model_id}/AC104_${par_model_str}_V${par_version}.bin"
        file_bin="FW/AC104_${par_model}_1.1.0_${par_version}_update.bin"
        rm -f "$file_bin"
        curl "$url_bin" --output "$file_bin"
        result=$(grep "<Code>NoSuchKey</Code>" "$file_bin")
        file_size=$(wc -c "$file_bin" | awk '{print $1}')
        if [ -n "$result" ] || [ "$file_size" -le 1000000 ]; then
          rm -f "$file_bin"
          # no bin update available
          echo -e "${RED}ERROR: Cannot find an update for this model and version ${NC}"
          if [ $stop_after_error -eq 1 ]; then
            exit 4
          fi
        else
          downloaded=$((downloaded + 1))
        fi
      else
        # url format 3.1.2+
        par_model_str="k2+Pro"
        if [ "$par_model" = "K2Plus" ]; then
          par_model_str="k2+Plus"
        fi
        if [ "$par_model" = "K2Max" ]; then
          par_model_str="k2+Max"
        fi
        url_bin="https://cdn.cloud-universe.anycubic.com/ota/${par_model}/ChituUpgrade_${par_model_str}_V${par_version}.bin"
        file_bin="FW/AC104_${par_model}_1.1.0_${par_version}_update.bin"
        rm -f "$file_bin"
        curl "$url_bin" --output "$file_bin"
        result=$(grep "<Code>NoSuchKey</Code>" "$file_bin")
        file_size=$(wc -c "$file_bin" | awk '{print $1}')
        if [ -n "$result" ] || [ "$file_size" -le 1000000 ]; then
          rm -f "$file_bin"
          # no bin update available
          echo -e "${RED}ERROR: Cannot find an update for this model and version ${NC}"
          if [ $stop_after_error -eq 1 ]; then
            exit 4
          fi
        else
          downloaded=$((downloaded + 1))
        fi
      fi
    fi
  done
done

if [ $downloaded -eq 0 ]; then
  echo ""
  echo -e "${RED}ERROR: Cannot find an update for this model ${NC}"
  echo ""
  exit 5
fi

echo ""
echo -e "${GREEN}DONE! The requested firmware has been downloaded in the folder FW ${NC}"
echo ""
exit 0
