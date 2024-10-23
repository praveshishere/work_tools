#!/bin/bash

# Check if the user provided the correct number of arguments
if [ $# -ne 3 ]; then
    echo "Usage: $0 <working_branch> <backup_date> <prod_branch>"
    exit 1
fi

# Get the arguments
working_branch=$1
backup_date=$2
prod_branch=$3
backup_branch="${working_branch}_backup_${backup_date}"
orphan_branch="${working_branch}_prod2"

git fetch origin
echo "Updated origin ref"

if git rev-parse --verify --quiet "$working_branch" > /dev/null; then
    git branch -D "$working_branch"
    echo "Deleted Local '$working_branch' branch."
else
    echo "Branch '$working_branch' does not exist."
fi

# Checkout to the working branch
git checkout $working_branch

# Pull from remote origin to update the working branch
git pull origin $working_branch

# Checkout to the prod branch
git fetch prod $prod_branch

switched_branch="prod/${prod_branch}"

git checkout $switched_branch
git switch -c $prod_branch

echo "Switched to prod branch"

git pull prod $prod_branch
echo "Pulling changes from prod"

git checkout -b $orphan_branch

# Checkout the folder server/config/env from the working branch to the current branch
git checkout $working_branch -- server/config/env

echo "Folder server/config/env checked out to current branch."

git checkout $working_branch -- server/config/config.js
echo "Checkout out config.js from $working_branch"

# Add only files in the root git directory to staging area, excluding those listed in .gitignore
find . -maxdepth 1 -type f | while read file; do
    if ! git check-ignore -q $file; then
        git checkout $working_branch -- $file
    fi
done

echo "All files in the root git directory checked out to current branch."

# Stage all changes
git add -A

echo "Changes Staged"

code .

# Prompt the user to press Enter
read -p "Press Enter to commit changes..."

# Commit all changes into a single commit
git commit -m "$working_branch config added"

echo "Config from $working_branch staged and committed to $orphan_branch."

# Delete the working branch from the local repository
git branch -D $working_branch
echo "Deleted local $working_branch ."

# Make a clone of the current branch with the name of the working branch
git checkout -b $working_branch

# Print a message indicating the completion of the process
echo "Working branch $working_branch forked from $orphan_branch."

# Ask the user for confirmation
read -p "Are you sure you want to forcefully push the working branch to remote origin? (y/n): " confirm
if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
    # Push the working branch to remote origin forcefully
    git push origin $working_branch --force
    echo "Working branch $working_branch pushed to remote origin forcefully."
else
    echo "Operation cancelled."
fi