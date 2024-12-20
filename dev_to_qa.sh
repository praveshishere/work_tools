#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 <source-branch> <commit-id>"
    exit 1
}

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    usage
fi

SOURCE_BRANCH=$1

if ! git rev-parse --quiet --verify $SOURCE_BRANCH > /dev/null; then
    echo "Branch '$SOURCE_BRANCH' does not exist."
    exit 1
fi

TARGET_BRANCH=$(git rev-parse --abbrev-ref HEAD)
COMMIT_ID=$2

# Calculate the number of commits from the commit ID to HEAD of source branch
NUM_COMMITS=$(git rev-list --count $COMMIT_ID..$SOURCE_BRANCH)

# Get the commit hashes of the latest n commits from the source branch
COMMITS=$(git log -n $NUM_COMMITS $SOURCE_BRANCH --pretty=format:"%H")

# Reverse the order of commits to apply them from oldest to newest
COMMITS=$(echo "$COMMITS" | awk '{line[NR] = $0} END {for (i = NR; i > 0; i--) print line[i]}')

# Cherry-pick the commits in reverse order
for COMMIT in $COMMITS; do
    git cherry-pick $COMMIT
    if [ $? -ne 0 ]; then
        echo "Cherry-pick failed for commit $COMMIT. Please resolve conflicts manually."
        exit 1
    fi
done

echo "Cherry-picked $(git rev-list --count $COMMIT_ID..$SOURCE_BRANCH) commits from $SOURCE_BRANCH to $TARGET_BRANCH successfully."

