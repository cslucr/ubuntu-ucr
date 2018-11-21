#!./test/libs/bats/bin/bats
#
# Unattended updates script tests.

source ./includes/unattended-upgrades.inc

@test "Uncomment unattended upgrades" {
    skip
    run uncomment_unattended_upgrades
    run grep '"${distro_id}:${distro_codename}-updates";' /etc/apt/apt.conf.d/50unattended-upgrades 
    ! [[ "$output" == *'//'* ]]
}

@test "Verify unattended upgrades uncommented" {
    skip
    run is_commented_unattended_upgrades
    [ "$output" == false ]
}

@test "Comment unattended upgrades" {
    skip
    run comment_unattended_upgrades
    run grep '"${distro_id}:${distro_codename}-updates";' /etc/apt/apt.conf.d/50unattended-upgrades 
    [[ "$output" == *'//'* ]]
}

@test "Verify unattended upgrades commented" {
    skip
    run is_commented_unattended_upgrades
    [ "$output" == true ]
}

@test "Get unattended software name: non url repo." {
    run get_unattended_software_name 'webupd8team/java'
    [ "$output" == 'webupd8team-java' ]
}

@test "Add unattended upgrade: exit without software name" {
    skip
    run add_unattended_upgrade
    [ $status -eq 1 ]
}

@test "Add unattended upgrade" {
    skip
    run add_unattended_upgrade 'apt' "$( cat /etc/apt/sources.list | grep '^deb ' | head -n 1 )"
    [ $status -eq 0 ]
}

@test "Remove unattended upgrade: exit without software name" {
    skip
    run remove_unattended_upgrade
    [ $status -eq 1 ]
}

@test "Remove unattended upgrade" {
    skip
    run remove_unattended_upgrade 'apt' "$( cat /etc/apt/sources.list | grep '^deb ' | head -n 1 )"
    [ $status -eq 0 ]
}
