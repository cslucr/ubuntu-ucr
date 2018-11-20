#!./test/libs/bats/bin/bats
#
# Configuration script tests.

source ./include/utils.inc

@test "Verify program is not installed." {
    sudo apt-get remove rolldice -y
    [[ $(installedByApt 'rolldice') == false ]]
}

@test "Install program by apt." {
    installByApt 'rolldice'
    [[ $(installedByApt 'rolldice') == true ]]
}

@test "Uninstall program by apt." {
    uninstallByApt 'rolldice'
    [[ $(installedByApt 'rolldice') == false ]]
}
