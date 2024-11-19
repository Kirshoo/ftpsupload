#!/bin/bash

# Get environment variables
source .env

# Load ignore patterns from .ftpsignore
IGNORE_FILE=".ftpsignore"

IGNORED_PATTERNS=($(grep -v -e "^\s*$" -e "^#" "$IGNORE_FILE"))

# Debugging: Show the loaded patterns
echo "Patterns to ignore:"
for pattern in "${IGNORED_PATTERNS[@]}"; do
    echo "  $pattern"
done

TARGET_DIR="."

IGNORED_PATTERNS+=("$@")

glob_to_regex() {
    local glob="$1"
    local regex="^${glob//./\\.}"
    regex="${regex//\*/.*}"
    regex="${regex//\?/.}"
    regex="${regex//\[\\!/[^\]}"
    echo "$regex"
}

for pattern in "${IGNORED_PATTERNS[@]}"; do
    REGEX_PATTERNS+=("$(glob_to_regex "$pattern")")
done

for file in "$TARGET_DIR"/*; do
    filename=$(basename "$file")
    matched=false

    echo "$filename checking"

    for regex in "${REGEX_PATTERNS[@]}"; do
        if [[ $filename =~ $regex ]]; then
            matched=true
            echo "$filename matches $regex, take two electric boogaloo"
            break
        fi
    done

    if $matched; then
        echo "$filename matches pattern"
    fi
done