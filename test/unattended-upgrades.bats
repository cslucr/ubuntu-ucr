#!./test/libs/bats/bin/bats
#
# Unattended updates script tests.

source ./includes/unattended-upgrades.inc

@test "Enable unattended upgrades" {
    run enable_unattended_upgrades
    run grep '"${distro_id}:${distro_codename}-updates";' /etc/apt/apt.conf.d/50unattended-upgrades 
    ! [[ $output == *'//'* ]]
}

@test "Verify unattended upgrades enabled" {
    run is_enabled_unattended_upgrades
    [[ $output == true ]]
}

@test "Disable unattended upgrades" {
    run disable_unattended_upgrades
    run grep '"${distro_id}:${distro_codename}-updates";' /etc/apt/apt.conf.d/50unattended-upgrades 
    [[ $output == *'//'* ]]
}

@test "Verify unattended upgrades disabled" {
    run is_enabled_unattended_upgrades
    [[ $output == false ]]
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

