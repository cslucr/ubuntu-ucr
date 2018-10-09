#!./test/libs/bats/bin/bats
#
# Configuration script tests.

source ./includes/configuration.sh

@test "Replace text: exit when file to modify does not exits" {
    run replace_text $HOME/myUnexistingFileToModify
    [[ $status -eq 1 ]]
}

@test "Replace text" {
    echo -e '//\t"${distro_id}:${distro_codename}";' > ./test/test-file.txt
    run replace_text ./test/test-file.txt '//\t"${distro_id}:${distro_codename}";' '\t"${distro_id}:${distro_codename}";'
    [[ $status -eq 0 ]]
    ! [[ $(cat ./test/test-file.txt) == *'//	"${distro_id}'* ]]
    rm ./test/test-file.txt
}

