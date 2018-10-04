#!./test/libs/bats/bin/bats

@test "Show help" {
    [[ $(bash ubuntu-ucr-customization.sh -h) == *'Customizes an Ubuntu installation'* ]]
}

