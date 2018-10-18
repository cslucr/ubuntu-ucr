#!/bin/bash
#
# Handle configuration: replace text in file.

# Path to yaml parser.
YAML_PARSER=./resources/libs/yq_linux_amd64

# Path to repositories.yaml file.
REPOSITORIES_FILE=./configuration/repositories.yaml

# Replaces text on a file.
function replace_text() {
    file_to_modify=$1
    original_text=$2
    replace_text=$3
    use_sudo=$4
    sudo_command=''

    # Verify file exists.
    ! [[ -f "$file_to_modify" ]] && return 1

    # Escape special characters: / with \/.
    original_text=${original_text//\//\\/}
    replace_text=${replace_text//\//\\/}

    [[ "$use_sudo" == true ]] && sudo_command='sudo'
    $sudo_command sed -i -e "s/$original_text/$replace_text/" $file_to_modify

    return 0
}

# Verifies if a file contains a given string.
function file_contains_string() {
    file_to_check=$1
    string_to_search=$2

    # Verify file exists and string passed is not empty.
    ! [[ -f "$file_to_check" ]] || [[ -z "$string_to_search"  ]] && return 1

    [[ $(cat $file_to_check) == *"$string_to_search"* ]] && echo true && return 0

    echo false && return 0
}

# Given a repository index, get his data as an associative array.
function get_repository_data() {
  local digit_regex='[[:digit:]]+'
  local repository_index=$1
  result_array=$2

  # Verify repository index is a positive number.
  [[ -z "$repository_index" ]] && return 1
  ! [[ $repository_index =~ $digit_regex ]] && return 1
  
  # Verify array name was passed.
  [[ -z "$result_array" ]] && return 1

  # Test if repository index is not out of bounds.
  [[ $($YAML_PARSER r $REPOSITORIES_FILE repositories[$repository_index]) == 'null' ]] && return 1

  # Get repository data.
  result_array[name]=$($YAML_PARSER r $REPOSITORIES_FILE repositories[$repository_index].name)
  result_array[type]=$($YAML_PARSER r $REPOSITORIES_FILE repositories[$repository_index].type)
  result_array[repo]=$($YAML_PARSER r $REPOSITORIES_FILE repositories[$repository_index].repo)
  result_array[key]=$($YAML_PARSER r $REPOSITORIES_FILE repositories[$repository_index].key)
  result_array[unattended]=$($YAML_PARSER r $REPOSITORIES_FILE repositories[$repository_index].unattended)
  
  return 0
}

