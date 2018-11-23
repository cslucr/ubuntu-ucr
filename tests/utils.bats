#!./tests/libs/bats/bin/bats
#
# Configuration script tests.

source ./includes/utils.inc

@test "Verify program is not installed." {
    sudo apt-get remove rolldice -y
    [[ $(installed_by_apt 'rolldice') == false ]]
}

@test "Install program by apt." {
    install_by_apt 'rolldice'
    [[ $(installed_by_apt 'rolldice') == true ]]
}

@test "Uninstall program by apt." {
    uninstall_by_apt 'rolldice'
    [[ $(installed_by_apt 'rolldice') == false ]]
}
