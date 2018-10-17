#!./test/libs/bats/bin/bats
#
# Parameters script tests.

source ./includes/parameters.inc
source ./includes/vars.inc

@test "Get APT_CACHE parameter" {
    get_parameters -c -y
    [[ $APT_CACHED == true ]]
}

@test "Get HELP parameter" {
    run get_parameters -h
    [[ $output == *'Customizes an Ubuntu installation'* ]]
}

@test "Get WGET_CACHED parameter" {
    get_parameters -w $HOME -y
    [[ $WGET_CACHED == true ]]
    [[ $WGET_CACHE == $HOME ]]
}

@test "Get NOFORCE parameter" {
    get_parameters -y
    [[ $NOFORCE == false ]]
}

