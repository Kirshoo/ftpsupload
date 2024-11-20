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
for file in $TARGET_DIR/*; do
    filename=$(basename "$file")
    matched=true

    for regex in "${REGEX_PATTERNS[@]}"; do
        if [[ $filename =~ $regex ]]; then
            matched=false
            break
        fi
    done

    if $matched; then
        echo "$file will be uploaded"
        FILES_TO_UPLOAD+=($file)
    fi
done

# optout the extended gobbling
shopt -u extglob

: << COMMENT
for file in "${FILES_TO_UPLOAD[@]}"; do
    if [[ -d $file ]]; then
        echo "$file is a directory"
    elif [[ -f $file ]]; then
        echo "$file is a valid file"
    else
        echo "$file is not a valid bungaloo"
    fi
done
COMMENT

/bin/bash pushToServer.sh ${FILES_TO_UPLOAD[@]}