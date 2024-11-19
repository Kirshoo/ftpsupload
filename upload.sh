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

shopt -s extglob

for file in "$TARGET_DIR"/*; do
    filename=$(basename "$file")
    matched=false

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

#     if [[ $filename =~ .* ]]; then 
#         echo "checking $filename";
#     else 
#         echo "not checking"; 
#     fi

#     for pattern in "${IGNORED_PATTERNS[@]}"; do
#         echo "checking against $pattern"
#         # Handle negated patterns (!pattern)
#         if [[ $pattern == \!* ]]; then
#             negated_pattern=${pattern:1}  # Remove the '!'
#             if [[ $filename =~ $negated_pattern ]]; then
#                 matched=false
#                 break
#             fi
#         elif [[ $filename =~ $pattern ]]; then
#             matched=true
#             echo "$filename matches $pattern";
#             break;
#         fi
#     done

#     Print the matching files
#     if $matched; then
#         echo "$filename matches a pattern in $IGNORE_FILE"
#     fi
# done

shopt -u extglob