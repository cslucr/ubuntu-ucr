#!./test/libs/bats/bin/bats
#
# Unattended updates script tests.

source ./includes/unattended-upgrades.sh

@test "Enable unattended upgrades" {
    run enable_unattended_upgrades
    run grep '"${distro_id}:${distro_codename}-updates";' /etc/apt/apt.conf.d/50unattended-upgrades 
    ! [[ $output == *'//'* ]]
}

@test "Verify unattended upgrades enabled" {
    run enabled_unattended_upgrades
    [[ $output == true ]]
}

@test "Disable unattended upgrades" {
    run disable_unattended_upgrades
    run grep '"${distro_id}:${distro_codename}-updates";' /etc/apt/apt.conf.d/50unattended-upgrades 
    [[ $output == *'//'* ]]
}

@test "Verify unattended upgrades disabled" {
    run enabled_unattended_upgrades
    [[ $output == false ]]
}

