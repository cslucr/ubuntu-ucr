#!./tests/libs/bats/bin/bats
#
# Messages script tests.

source ./includes/messages.inc

@test "Show help" {
    [[ $(help) == *'Customizes an Ubuntu installation'* ]]
}

@test "Error exit" {
    run error_exit
    [[ $output == *'Unknown error'* ]]
}

@test "Show error" {
    run show_error
    [[ $output == *'Unknown error'* ]]
}
