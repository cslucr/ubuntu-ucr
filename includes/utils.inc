# @file utils
# @brief Wrapper around apt to install ansible.

#############################################################################
# @description Verifies if a package is installed.
#
# @example
#
#  `# Verify if ansible is installed.`
#   installed_by_apt ansible
#
# @arg $packageName *string* package name to search.
#
# @exitcode true is package is installed, false otherwise.
# @exitcode 1 on failure.
#############################################################################
function installed_by_apt() {
    # Search for text: 'Installed: (none) or Instalados: (ninguno)'.
    local INSTALLED_REGEX='.*(\(.*\))'
    
    local packageName=$1
    [[ -z "$packageName" ]] && return 1
    
    result=$(apt-cache policy "$packageName")
    ! [[ -z "$result" ]] && ! [[ "$result" =~ $INSTALLED_REGEX ]] && echo true && return 
    echo false
}

#############################################################################
# @description Installs a package via apt.
#
# @example
#
#  `# Install ansible.`
#   install_by_apt ansible
#
# @arg $packageName *string* package name to install.
#
# @exitcode 0 on sucess.
# @exitcode 1 on failure.
#############################################################################
function install_by_apt() {
    local packageName=$1
    [[ -z "$packageName" ]] && return 1

    if [[ $(installed_by_apt "$packageName") == "false" ]]; then
        sudo apt-get install "$packageName" -y
    fi
    return $?
}    

#############################################################################
# @description Uninstalls a package via apt.
#
# @example
#
#  `# Uninstall ansible.`
#   uninstall_by_apt ansible
#
# @arg $packageName *string* package name to uninstall.
#
# @exitcode 0 on sucess.
# @exitcode 1 on failure.
#############################################################################
function uninstall_by_apt() {
    local packageName=$1
    [[ -z "$packageName" ]] && return 1

    [[ $(installed_by_apt "$packageName") == false ]] && return 0
    
    sudo apt-get remove "$packageName" -y
    sudo apt-get autoremove -y
    return $?
}
