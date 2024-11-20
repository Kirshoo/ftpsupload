#!/bin/bash

source .env

FILES=""

first=true
# Conver passed file arguments to a string format "file1,file2,..."
for file in ${@:1}; do
  if $first; then
    first=false
  else 
    FILES+=","
  fi
  FILES+="$file"
done

# Upload files to the server using curl
# Variables are from .env
curl -T "{$FILES}" --user "$FTP_USERNAME:$FTP_PASSWORD" $FTP_SERVER
exit 0