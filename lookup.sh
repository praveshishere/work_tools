#!/bin/bash

# This script takes two arguments: a directory and a threshold.
# It will recursively scan the directory and all its subdirectories
# for files that have more lines than the given threshold.
# If such a file is found, it will print the name of the file and
# the number of lines it has.

# Function to recursively scan directory
scan_directory() {
    local dir="$1"
    local threshold="$2"
    
    # Loop through each file in the directory
    for file in "$dir"/*; do
        # Check if the file is a directory
        if [ -d "$file" ]; then
            # If it's a directory, recursively call the function
            scan_directory "$file" "$threshold"
        elif [ -f "$file" ]; then
            # If it's a file, check the number of lines
            lines=$(wc -l < "$file")
            if [ "$lines" -gt "$threshold" ]; then
                echo "$file has $lines lines"
            fi
        fi
    done
}

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <directory> <threshold>"
    exit 1
fi

# Check if the directory exists
if [ ! -d "$1" ]; then
    echo "Directory '$1' does not exist."
    exit 1
fi

# Call the function with the provided directory and threshold
scan_directory "$1" "$2"

