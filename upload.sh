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

shopt -s extglob

IGNORED_PATTERNS=($1)

for file in "$TARGET_DIR"/*; do
    filename=$(basename "$file")
    matched=false
    if [[ $filename =~ .* ]]; then 
        echo "checking $filename";
    else 
        echo "not checking"; 
    fi

    for pattern in "${IGNORED_PATTERNS[@]}"; do
        echo "checking against $pattern"
        # Handle negated patterns (!pattern)
        if [[ $pattern == \!* ]]; then
            negated_pattern=${pattern:1}  # Remove the '!'
            if [[ $filename =~ $negated_pattern ]]; then
                matched=false
                break
            fi
        elif [[ $filename =~ $pattern ]]; then
            matched=true
            echo "$filename matches $pattern";
            break;
        fi
    done

    # Print the matching files
    if $matched; then
        echo "$filename matches a pattern in $IGNORE_FILE"
    fi
done

shopt -u extglob