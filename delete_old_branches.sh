#!/bin/bash

DAYS=${1:-30}
CUTOFF=$(date -d "${DAYS} days ago" '+%Y-%m-%d')
CURRENT=$(git branch --show-current)

echo "Deleting branches with last commit before ${CUTOFF} (older than ${DAYS} days)"
echo ""

BRANCHES=$(git branch --format='%(refname:short) %(committerdate:short)' \
  | awk -v cutoff="$CUTOFF" -v current="$CURRENT" '$1 != current && $2 < cutoff {print $1}')

if [ -z "$BRANCHES" ]; then
  echo "No branches to delete."
  exit 0
fi

echo "Branches to be deleted:"
echo "$BRANCHES"
echo ""

read -p "Proceed? (y/N) " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "Aborted."
  exit 0
fi

echo "$BRANCHES" | xargs git branch -D
