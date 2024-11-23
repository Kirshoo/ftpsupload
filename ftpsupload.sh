#!/usr/bin/env bash

if [ ! -f ".env" ]; then
    echo "Please create .env file, that contains all necessary variables"
    echo "FTP_SERVER - the ftp(s) address of the server in a from \"ftp://ftp.example.com\""
    echo "FTP_USERNAME - username, which will be connecting to the server to perform file upload"
    echo "FTP_PASSWORD - password of the username"
    exit 0
else
    source ".env"
fi

IGNORE_FILE=".ftpsignore"

# If ignore files exists
if [ -f $IGNORE_FILE ]; then
    # Parse ignore patterns
    IGNORED_PATTERNS=($(grep -v -e "^\s*$" -e "^#" "$IGNORE_FILE"))
else 
    IGNORED_PATTERNS=()
fi

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
	
	# Match file with every regex pattern
        for regex in "${REGEX_PATTERNS[@]}"; do
            if [[ $filename =~ $regex ]]; then
                matched=false
                break
            fi
        done

        if $matched; then
            if [[ -d $file ]]; then
		# If directory is found, go over its files and filter them out
                filterFiles $file
            elif [[ -f $file ]]; then
		# If file is found, add it to the list of files
                FILES_TO_UPLOAD+=($file)
            fi
        fi
    done
}

filterFiles $TARGET_DIR

# optout the extended gobbling
shopt -u extglob

# Upload file to the server
# Parameters are taken from .env file
for file in "${FILES_TO_UPLOAD[@]}"; do
	echo "Uploading $file"
	curl -T $file --user "$FTP_USERNAME:$FTP_PASSWORD" "$FTP_SERVER"
done

exit 0
