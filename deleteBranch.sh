#!/usr/bin/env bash

# Check if the user provided a branch prefix as an argument
if [ "$#" -eq 0 ]; then
    echo "Please provide a branch prefix as a command-line argument."
    exit 1
fi

branch_prefix="$1"

# Delete branches with the specified prefix
git branch -D $(git branch | grep -E "${branch_prefix}/*")

