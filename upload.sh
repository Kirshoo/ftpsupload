#!/bin/bash

# Load ignore patterns from .ftpsignore
IGNORE_FILE=".ftpsignore"

# Parse ignore patterns
IGNORED_PATTERNS=($(grep -v -e "^\s*$" -e "^#" "$IGNORE_FILE"))

TARGET_DIR="${1:-"."}"

# Allow for extended globbing
shopt -s extglob

# Function to turn a globbing regex to regular regex
# All credit is to dan93-93
glob_to_regex() {
    local glob="$1"
    local regex="^${glob//./\\.}"
    regex="${regex//\*/.*}"
    regex="${regex//\?/.}"
    regex="${regex//\[\\!/[^\]}"
    echo "$regex"
}

# Transform all patterns from .ftpsignore to a regex
for pattern in "${IGNORED_PATTERNS[@]}"; do
    REGEX_PATTERNS+=("$(glob_to_regex "$pattern")")
done

# Initialize an empty collection of files
# This will be filled with files, that are going to be uploaded
# and dont match patterns in .ftpsignore
FILES_TO_UPLOAD=()

# Go through each file in the target derectory
# and match them with regex patterns
# If directory is encountered, recursively go through its files and filter them
filterFiles() {
    for file in $1/*; do
        filename=$(basename "$file")
        matched=true

        for regex in "${REGEX_PATTERNS[@]}"; do
            if [[ $filename =~ $regex ]]; then
                matched=false
                break
            fi
        done

        if $matched; then
            if [[ -d $file ]]; then
                filterFiles $file
            elif [[ -f $file ]] && ! [[ $filename =~ , ]]; then
                # Since we bundle files together in pushToServer.sh
                # We need to ensure that no files contain commas in their name
                echo "$file will be uploaded"
                FILES_TO_UPLOAD+=($file)
            fi
        fi
    done
}

# optout the extended gobbling
shopt -u extglob

/bin/bash pushToServer.sh ${FILES_TO_UPLOAD[@]}