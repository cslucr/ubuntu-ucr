#!/bin/bash
#
# Handle configuration: replace text in file.

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

