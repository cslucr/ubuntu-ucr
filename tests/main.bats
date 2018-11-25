#!./tests/libs/bats/bin/bats
#
# Main script tests.

@test "Show help" {
    [[ $(bash ubuntu-ucr-customization.sh -h) == *'Customizes an Ubuntu installation'* ]]
}
