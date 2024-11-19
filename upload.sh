#!/bin/bash

# Get environment variables
source .env

# Load ignore patterns from .ftpsignore
IGNORE_FILE=".ftpsignore"

# Parse ignore patterns
IGNORED_PATTERNS=($(grep -v -e "^\s*$" -e "^#" "$IGNORE_FILE"))

TARGET_DIR="."

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

# Go through each file in the target derectory 
# and match them with regex patterns
for file in "$TARGET_DIR"/*; do
    filename=$(basename "$file")
    matched=false

    for regex in "${REGEX_PATTERNS[@]}"; do
        if [[ $filename =~ $regex ]]; then
            matched=true
            break
        fi
    done

    if $matched; then
        echo "$filename matches pattern"
    fi
done

# optout the extended gobbling
shopt -u extglob