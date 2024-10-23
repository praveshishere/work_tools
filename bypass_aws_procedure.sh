#!/bin/bash

log_dir="$HOME/bypass_aws_procedure/"
current_datetime=$(date +"%Y-%m-%d_%H:%M:%S")
current_log_file="${log_dir}${current_datetime}.log"

global_total_width=65

# Function to start the subprocess with a specified command
start_subprocess() {
  local command="$1"
  
  # Start the subprocess in the background
  eval $command &
  
  # Capture the PID of the subprocess
  subprocess_pid=$!  
}

# Function to check if the subprocess is still running
is_subprocess_running() {
  # Check if the process with the specified PID is running
  kill -0 "$1" 2>/dev/null
}

# Function to clear a specified number of characters from the console
clear_characters() {
  local num_characters="$1"
  
  # Move the cursor backward
  printf "\b%.0s" $(seq 1 "$num_characters")
  
  # Output spaces to overwrite the characters
  printf "%${num_characters}s" ""

  # Move the cursor backward
  printf "\b%.0s" $(seq 1 "$num_characters")
}

# Function to count lines in a file
count_lines() {
  local filename="$1"
  
  if [ -f "$current_log_file" ]; then
    local line_count=$(wc -l < "$filename")
    echo "$line_count"
  else
    echo "0"
  fi
}

count_digits() {
  local number="$1"
  local number_string="$number"
  local length=${#number_string}
  echo "$length"
}

# Function to monitor file and log line count
monitor_file() {
  local file_name="$1"
 
  # Infinite loop to call the count_lines function every 1 second
  while true; do

    # Check if the subprocess is still running
    if ! is_subprocess_running "$subprocess_pid"; then
      break
    fi

    local lines=$(count_lines "$file_name")
    
    echo -n "$lines"
    sleep 0.05

    local len=$(count_digits $lines)
    local spaces=$((len))
    clear_characters $spaces

  done
}

# Function to print a check mark symbol
mark_completion() {
  echo -e " \xE2\x9C\x93\xE2\x9C\x93"
}

print_padded_string() {
  local input_string="$1"
  local total_width=$global_total_width

  printf "%-${total_width}s" "$input_string"
}

# Function to trim leading and trailing spaces from a string
trim_string() {
  local input_string="$1"
  local trimmed_string="${input_string#"${input_string%%[![:space:]]*}"}"
  trimmed_string="${trimmed_string%"${trimmed_string##*[![:space:]]}"}"
  echo "$trimmed_string"
}

# Function to copy file line by line
copy_file() {
  local source_file="$1"
  local destination_file="$2"
  local ex="$3"

  # Check if the source file exists
  if [ ! -f "$source_file" ]; then
    echo "Error: Source file '$source_file' not found."
    exit 1
  fi

  # Copy file line by line
  while IFS= read -r line; do

    trimmed_line=$(trim_string "$line")

    if [[ $trimmed_line != "$ex"* ]]; then
      echo "$line" >> "$destination_file"
    fi

  done < "$source_file"
}


# Creating log directory
if [ ! -d "$log_dir" ]; then
  mkdir "$log_dir"
fi

echo "\n================================================================="
echo "Bypass AWS procedure started...\n"


print_padded_string " => Filtering @tataaig packages"

copy_file "package.json" "temp.json" "\"@tataaig"
rm -rf package.json
mv temp.json package.json

mark_completion


print_padded_string " => Removing package-lock.json"
rm -rf package-lock.json
mark_completion


npm config set registry https://registry.npmjs.com/
print_padded_string " => Default registry set to https://registry.npmjs.com/"
mark_completion


print_padded_string " => Installing packages from https://registry.npmjs.com/"
start_subprocess "npm i --no-progress >> ${current_log_file}"
monitor_file $current_log_file
mark_completion


print_padded_string " => Restoring original registry"
aws codeartifact login --tool npm --repository security --domain iorta --domain-owner 118368828930 >> "$current_log_file"
mark_completion


print_padded_string " => Restoring @tataaig packages"
git checkout -- package.json
mark_completion

print_padded_string " => Installing packages from aws"
start_subprocess "npm i --no-progress >> ${current_log_file}"
monitor_file $current_log_file
mark_completion

echo " => Procedure ended."
echo "=================================================================\n"