#!./test/libs/bats/bin/bats
#
# Repositories tests.

source ./includes/repositories.inc

@test 'Yaml parser path' {
    [ "$YAML_PARSER" == "${BASE_DIR}/resources/libs/yq_linux_${ARCH}" ]
}

@test 'Get repository data: exit with index out of bounds' {
    local -A result_array
    run get_repository_data 77 result_array
    [ $status -eq 1 ]
}

@test "Get repository data: exit with no repository index" {
    skip
    run get_repository_data
    [ $status -eq 1 ]
}

@test "Get repository data: exit when repository index not a number" {
    run get_repository_data 'text'
    [ $status -eq 1 ]
}

@test 'Get repository data: exit when not resulting array name passed' {
    run get_repository_data 0
    [ $status -eq 1 ]
}

@test 'Get repository data: exit with index out of bounds' {
    local -A result_array
    run get_repository_data 77 result_array
    [ $status -eq 1 ]
}

@test "Get repository data: exit with no repository index" {
    skip
    run get_repository_data
    [ $status -eq 1 ]
}

@test "Get repository data: exit when repository index not a number" {
    run get_repository_data 'text'
    [ $status -eq 1 ]
}

@test 'Get repository data: exit when not resultin array name passed' {
    run get_repository_data 0
    [ $status -eq 1 ]
}

@test 'Get repository data' {
    local -A result_array
    get_repository_data 0 result_array
    [[ "${result_array[key]}" == *'google'* ]]
}
