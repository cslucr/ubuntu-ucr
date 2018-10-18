#!./test/libs/bats/bin/bats
#
# Unattended updates script tests.

source ./includes/unattended-upgrades.inc

@test 'Get repository data' {
    local -A result_array
    get_repository_data 0 result_array
    [[  "${result_array[name]}" == 'java' ]]
}

@test 'Get repository data: exit with index out of bounds' {
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

@test "Uncomment unattended upgrades" {
    run uncomment_unattended_upgrades
    run grep '"${distro_id}:${distro_codename}-updates";' /etc/apt/apt.conf.d/50unattended-upgrades 
    ! [[ $output == *'//'* ]]
}

@test "Verify unattended upgrades uncommented" {
    run is_commented_unattended_upgrades
    [[ $output == false ]]
}

@test "Comment unattended upgrades" {
    run comment_unattended_upgrades
    run grep '"${distro_id}:${distro_codename}-updates";' /etc/apt/apt.conf.d/50unattended-upgrades 
    [[ $output == *'//'* ]]
}

@test "Verify unattended upgrades commented" {
    run is_commented_unattended_upgrades
    [[ $output == true ]]
}

@test "Add unattended upgrade: exit without software name" {
    run add_unattended_upgrade
    [[ $status -eq 1 ]]
}

@test "Add unattended upgrade" {
    run add_unattended_upgrade 'apt' "$( cat /etc/apt/sources.list | grep '^deb ' | head -n 1 )"
    [[ $status -eq 0 ]]
}

@test "Remove unattended upgrade: exit without software name" {
    run remove_unattended_upgrade
    [[ $status -eq 1 ]]
}

@test "Remove unattended upgrade" {
    run remove_unattended_upgrade 'apt' "$( cat /etc/apt/sources.list | grep '^deb ' | head -n 1 )"
    [[ $status -eq 0 ]]
}

