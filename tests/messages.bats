#!./tests/libs/bats/bin/bats
#
# Messages script tests.

source ./includes/messages.inc

@test "Show help" {
    [[ $(help) == *'Customizes an Ubuntu installation'* ]]
}
