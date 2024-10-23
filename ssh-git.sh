#!/bin/bash

function get_ssh_key {
    # echo "argument to get_ssh $1"
    if [ "$1" = "health" ]; then
        echo "$HEALTH_USER"

    elif [ "$1" = "health_prod" ]; then
        echo "$HEALTH_PROD_USER"

    elif [ "$1" = "marine" ]; then
        echo "$PERSONAL_LINES_USER"

    elif [ "$1" = "marine_prod" ]; then
        echo "$MARINE_PROD_USER"
    fi
}

# Function to modify the SSH URL with the provided key
function modify_ssh_url {
    local repo_url="$1"
    local ssh_key="$2"
    local domain_and_path=$(echo "$repo_url" | sed 's/^ssh:\/\/\([^\/]*\)\(.*\)$/\1\2/')
    echo "ssh://$ssh_key@$domain_and_path"
}


# Check if the correct number of arguments are provided
if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <command> [args] <key_name>"
    echo "Available keys:"
    for key in "${!ssh_keys[@]}"; do
        echo "  $key"
    done
    echo "Available commands:"
    echo "  clone <repo_url>"
    echo "  add-remote <remote_name> <repo_url>"
    exit 1
fi

command="$1"
shift

# Get the key name from the last argument
key_name="${@: -1}"

# Get the SSH key value from the associative array
ssh_key=$(get_ssh_key "$key_name")
echo "ssh_key: $ssh_key, lob: $key_name"

case "$command" in
    "clone")
        if [ "$#" -ne 2 ]; then
            echo "Usage: $0 clone <repo_url> <key_name>"
            exit 1
        fi
        repo_url="$1"

        new_repo_url=$(modify_ssh_url "$repo_url" "$ssh_key")
        echo "$new_repo_url"
        git clone "$new_repo_url"
        ;;
    "add-remote")
        if [ "$#" -ne 3 ]; then
            echo "Usage: $0 add-remote <remote_name> <repo_url> <key_name>"
            exit 1
        fi
        remote_name="$1"
        repo_url="$2"

        new_repo_url=$(modify_ssh_url "$repo_url" "$ssh_key")

        export GIT_SSH_COMMAND="ssh -i $temp_ssh_key"
        git remote add "$remote_name" "$new_repo_url"
        ;;
    *)
        echo "Unknown command: $command"
        exit 1
        ;;
esac
