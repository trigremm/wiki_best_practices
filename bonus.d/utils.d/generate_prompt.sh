#!/bin/bash

# Initialize an empty prompt.txt
> prompt.txt

path=""
declare -a additional_ignores

# Default ignore list
DEFAULT_IGNORE=(
    .git
    .DS_Store
    .vscode
    .idea
    .docker_volumes
    __pycache__
    node_modules
    dist
    build
)

# Use getopts to parse command line arguments
while getopts ":p:i:" opt; do
  case $opt in
    p)
      path="$OPTARG"
      ;;
    i)
      additional_ignores+=("$OPTARG")
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# Combine default and additional ignores
ignores=("${DEFAULT_IGNORE[@]}" "${additional_ignores[@]}")

# Build the find command
find_cmd="find \"$path\""

for ignore in "${ignores[@]}"; do
    find_cmd+=" -type d -name \"$ignore\" -prune -o"
done

find_cmd+=" \( -name \"*.py\" -o -name \"*.js\" -o -name \"*.ts\" -o -name \"*.vue\" "
find_cmd+="-o -name \"*.yaml\" -o -name \"*.yml\" -o -name \"Dockerfile\" -o -name \"*.toml\" "
find_cmd+="-o -name \"package.json\" -o -name \"tsconfig.json\" -o -name \"*.hurl\" \) -type f -print0 | xargs -0 -I {} sh -c '"
find_cmd+="echo \"{}:\" >> prompt.txt; "
find_cmd+="cat \"{}\" >> prompt.txt; "
find_cmd+="echo \"\" >> prompt.txt; "
find_cmd+="echo \"\" >> prompt.txt"
find_cmd+="'"

# Execute the dynamically built find command
eval $find_cmd

echo "Content of specified files from $path have been written to prompt.txt"
echo "Ignored directories and files: ${ignores[*]}"