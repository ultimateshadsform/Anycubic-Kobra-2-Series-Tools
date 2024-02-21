#!/bin/bash

# check the parameters
if [ $# != 1 ]; then
  echo "usage : $0 <app_file>"
  exit 1
fi

app_file="$1"

# try to find out the model
offset_pro=$(grep --binary-files=text -m1 -b -o "unmodifiable.cfg" "$app_file" | awk -F: '{print $1}')
offset_max=$(grep --binary-files=text -m1 -b -o "unmodifiable_max.cfg" "$app_file" | awk -F: '{print $1}')
offset_plus=$(grep --binary-files=text -m1 -b -o "unmodifiable_plus.cfg" "$app_file" | awk -F: '{print $1}')
app_model="Unknown"
if [ -n "$offset_pro" ]; then
  app_model="K2Pro"
fi
if [ -n "$offset_plus" ]; then
  app_model="K2Plus"
fi
if [ -n "$offset_max" ]; then
  app_model="K2Max"
fi

echo -n "$app_model"

exit 0
