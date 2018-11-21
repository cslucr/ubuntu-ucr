#!/bin/bash
#
# Handle configuration: replace text in file.

# Replaces text on a file.
function replace_text() {
    local file_to_modify=$1
    local original_text=$2
    local replace_text=$3
    local use_sudo=$4
    local sudo_command=''

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
    local file_to_check=$1
    local string_to_search=$2

    # Verify file exists and string passed is not empty.
    ! [[ -f "$file_to_check" ]] || [[ -z "$string_to_search"  ]] && return 1

    [[ $(cat $file_to_check) == *"$string_to_search"* ]] && echo true && return 0

    echo false && return 0
}
