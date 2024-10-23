#!/bin/bash

# Global variables for source and destination branches
source_branch="dev"
destination_branch="qa"

# Function to create a backup branch
create_backup() {
    local dest_branch=$1
    local current_branch=$(git rev-parse --abbrev-ref HEAD)
    local current_date=$(date +"%d_%B_%Y")
    local backup_branch="$dest_branch-$current_date"

    # Fetch the latest changes from the remote destination branch
    git fetch origin $dest_branch

    # Create a temporary copy of the branch from origin/dest_branch
    git checkout -b $backup_branch origin/$dest_branch --quiet

    git push origin $backup_branch

    # Return the backup branch name
    echo $backup_branch
}

# Function to verify if the backup branch was successfully created
verify_backup() {
    local backup_branch=$1
    local dest_branch=$2

    # Checkout to the backup branch
    git checkout $backup_branch

    # Compare the backup branch with the destination branch
    if git diff --quiet $backup_branch origin/$dest_branch; then
        echo "Backup branch $backup_branch is the same as $dest_branch"
        return 0  # Return true
    else
        echo "Backup branch $backup_branch is different from $dest_branch"
        return 1  # Return false
    fi
}

# Function to synchronize the source and destination branches
sync_branch() {
    local source_branch=$1
    local dest_branch=$2
    local temp_source_branch="temp_$source_branch"

    # Fetch the latest changes from the remote source branch
    git fetch origin $source_branch

    # Checkout the source branch to a temporary branch
    git checkout -b $temp_source_branch origin/$source_branch
    echo "Temporary copy of branch created: $dest_branch"

    # Fetch the latest changes from the remote destination branch
    git fetch origin $dest_branch

    # Checkout the specified files from the destination branch to the temporary branch
    git checkout origin/$dest_branch buildspec.yml Dockerfile

    # Add the changes
    git add buildspec.yml Dockerfile

    # Commit the changes with the commit message
    git commit -m "$dest_branch config added"
    echo "Config added"

    # Delete the local destination branch
    git branch -D $dest_branch

    # Checkout from the temporary branch with the same name as destination branch
    git checkout -b $dest_branch

    echo "Force pushed $dest_branch to remote"

    # Force push the destination branch to the remote repository
    git push -f origin $dest_branch
}

# Check if both source and destination branches are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <source_branch> <destination_branch>"
    exit 1
fi

source_branch=$1
destination_branch=$2

backup_branch=$(create_backup $destination_branch)

# Verify if the backup branch was successfully created
if verify_backup $backup_branch $destination_branch; then
    echo "Backup branch verification successful"
    sync_branch $source_branch $destination_branch
else
    echo "Backup branch verification failed"
    exit 1  # Terminate the script
fi
