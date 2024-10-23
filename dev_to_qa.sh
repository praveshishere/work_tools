#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 <source-branch> <target-branch> <commit-id>"
    exit 1
}

# Check if the correct number of arguments is provided
if [ "$#" -ne 3 ]; then
    usage
fi

SOURCE_BRANCH=$1
TARGET_BRANCH=$2
COMMIT_ID=$3

# Fetch the latest changes from the remote repository
git fetch

# Switch to the source branch
git checkout $SOURCE_BRANCH

# Calculate the number of commits from the commit ID to HEAD
NUM_COMMITS=$(git rev-list --count $COMMIT_ID..HEAD)

# Get the commit hashes of the latest n commits from the source branch
COMMITS=$(git log -n $NUM_COMMITS --pretty=format:"%H")

# Reverse the order of commits to apply them from oldest to newest
COMMITS=$(echo "$COMMITS" | awk '{line[NR] = $0} END {for (i = NR; i > 0; i--) print line[i]}')

# Switch to the target branch
git checkout $TARGET_BRANCH

# Cherry-pick the commits in reverse order
for COMMIT in $COMMITS; do
    git cherry-pick $COMMIT
    if [ $? -ne 0 ]; then
        echo "Cherry-pick failed for commit $COMMIT. Please resolve conflicts manually."
        exit 1
    fi
done

echo "Cherry-picked $NUM_COMMITS commits from $SOURCE_BRANCH to $TARGET_BRANCH successfully."

