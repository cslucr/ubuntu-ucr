# Install ansible.

function installedByApt() {
    # Search for text: 'Installed: (none) or Instalados: (ninguno)'.
    local INSTALLED_REGEX='.*(\(.*\))'
    
    local programName=$1
    [[ -z "$programName" ]] && return 1
    
    result=$(apt-cache policy "$programName")
    ! [[ -z "$result" ]] && ! [[ "$result" =~ $INSTALLED_REGEX ]] && echo true && return 
    echo false
}

function installByApt() {
    local programName=$1
    [[ -z "$programName" ]] && return 1

    # Verify user can sudo.
    ! [[ $(groups) = *"sudo"* ]] && ! [[ $(groups) == *"root"* ]] && echo "Permission denied, please run with admin privileges." && return 1

    if [[ $(installedByApt "$programName") == "false" ]]; then
        sudo apt-get install "$programName" -y
    fi
    return $?
}    

function uninstallByApt() {
    local programName=$1
    [[ -z "$programName" ]] && return 1

    [[ $(installedByApt "$programName") == false ]] && return 0
    
    sudo apt-get remove "$programName" -y
    sudo apt-get autoremove -y
    return $?
}
