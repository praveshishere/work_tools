#!/bin/bash

# Remove the existing remote named "origin"
git remote remove origin

# Check if the removal was successful
if [ $? -eq 0 ]; then
    echo "Remote 'origin' removed successfully."
else
    echo "Failed to remove remote 'origin'."
    exit 1
fi

# Add a new remote named "origin" with a different URL
git remote add origin <new_remote_url>

# Check if the addition was successful
if [ $? -eq 0 ]; then
    echo "New remote 'origin' added successfully."
else
    echo "Failed to add new remote 'origin'."
fi

