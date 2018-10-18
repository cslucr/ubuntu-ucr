#!./test/libs/bats/bin/bats
#
# Configuration script tests.

source ./includes/utils.inc

@test "Replace text: exit with unexisting file path" {
    run replace_text $HOME/myUnexistingFileToModify
    [[ $status -eq 1 ]]
}

@test "Replace text" {
    echo -e '//\t"${distro_id}:${distro_codename}";' > ./test/test-file.txt
    run replace_text ./test/test-file.txt '//\t"${distro_id}:${distro_codename}";' '\t"${distro_id}:${distro_codename}";'
    [[ $status -eq 0 ]]
    ! [[ $(cat ./test/test-file.txt) == *'//	"${distro_id}'* ]]
    rm ./test/test-file.txt
}

@test "File contains string: exit with empty file path" {
    run file_contains_string
    [[ $status -eq 1 ]]
}

@test "File contains string: exit with empty string to search" {
    run file_contains_string /etc/apt/sources.list
    [[ $status -eq 1 ]]
}

@test "File contains string" {
    run file_contains_string /etc/apt/sources.list 'deb'
    [[ $output == true ]]
}

@test 'Get repository data' {
    local -A result_array
    get_repository_data 0 result_array
    [[  "${result_array[name]}" == 'java' ]]
}

@test 'Get repository data: exit with index out of bounds' {
    local -A result_array
    run get_repository_data 77 result_array
    [[ $status -eq 1 ]]
}

@test "Get repository data: exit with no repository index" {
    run get_repository_data
    [[ $status -eq 1 ]]
}

@test "Get repository data: exit when repository index not a number" {
    run get_repository_data 'text'
    [[ $status -eq 1 ]]
}

@test 'Get repository data: exit when not resultin array name passed' {
    run get_repository_data 0
    [[ $status -eq 1 ]]
}
