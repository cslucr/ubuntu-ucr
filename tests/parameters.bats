#!./tests/libs/bats/bin/bats
#
# Parameters script tests.

source ./includes/parameters.inc
source ./includes/vars.inc

@test "Get APT_CACHE parameter" {
    get_parameters -c -y
    [ "$APT_CACHE" == true ]
}

@test "Get HELP parameter" {
    run get_parameters -h
    [[ "$output" == *'Customizes an Ubuntu installation'* ]]
}

@test "Get WGET_CACHE parameter" {
    get_parameters -w $HOME -y
    [ "$WGET_CACHE_PATH" == "$HOME" ]
}

@test "Get NO_FORCE parameter" {
    get_parameters -y
    [ "$NO_FORCE" == false ]
}

