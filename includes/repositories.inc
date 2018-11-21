#!/bin/bash
#
# Handle packages: installation and configurations.

source ./includes/vars.inc

# Given a repository index, get his data as an associative array.
function get_repository_data() {
  local digit_regex='[[:digit:]]+'
  local repository_index=$1
  result_array=$2

  # Verify repository index is a positive number.
  [[ -z "$repository_index" ]] && return 1
  ! [[ $repository_index =~ $digit_regex ]] && return 1
  
  # Verify array name was passed.
  [[ -z "$result_array" ]] && return 1

  # Test if repository index is not out of bounds.
  [[ $($YAML_PARSER r $CONFIGURATION_FILE repositories[$repository_index]) == 'null' ]] && return 1

  # Get repository data.
  result_array[name]=$($YAML_PARSER r $CONFIGURATION_FILE repositories[$repository_index].name)
  result_array[type]=$($YAML_PARSER r $CONFIGURATION_FILE repositories[$repository_index].type)
  result_array[repo]=$($YAML_PARSER r $CONFIGURATION_FILE repositories[$repository_index].repo)
  result_array[key]=$($YAML_PARSER r $CONFIGURATION_FILE repositories[$repository_index].key)
  result_array[unattended]=$($YAML_PARSER r $CONFIGURATION_FILE repositories[$repository_index].unattended)
  
  return 0
}

function add_repository() {
  local name=$1
  local type=$2
  local repo=$3

  # Verify repository name, type and repo.
  [[ -z "$name" ]] && show_error "Error: No repository name" && return 1
  [[ -z "$type" ]] && show_error "Error: No repository type" && return 1
  [[ -z "$repo" ]] && show_error "Error: No repository string" && return 1
   
  # Generates repo name for apt policy data
  case "$type" in
    apt)
      add_apt_repository "$name" "$repo" || (show_error "Error: Adding APT ${name} repository" && return 1)
      ;;
    ppa)
      add_ppa_repository "$name" "$repo" || (show_error "Error: Adding PPA ${name} repository" && return 1)
      ;;
    *)
      show_error "Error: Repository type not supported" && return 1
  esac 
}

function add_apt_repository() {
  local name=$1
  local repo=$2
  #TODO check what happens with amd64 repos like Google Chrome
  sudo sh -c "echo \"${repo}\" > /etc/apt/sources.list.d/${name}.list"
  return $?
}

function add_ppa_repository() {
  local name=$1
  local repo=$2
  sudo add-apt-repository -y "$repo"
  return $?
}

function remove_repository() {
  local name=$1
  local type=$2
  local repo=$3

  # Verify repository name, type and repo.
  [[ -z "$name" ]] && show_error "Error: No repository name" && return 1
  [[ -z "$type" ]] && show_error "Error: No repository type" && return 1
  [[ -z "$repo" ]] && show_error "Error: No repository string" && return 1
   
  # Generates repo name for apt policy data
  case "$type" in
    apt)
      remove_apt_repository "$name" || (show_error "Error: Removing APT ${name} repository" && return 1)
      ;;
    ppa)
      remove_ppa_repository "$name" "$repo" || (show_error "Error: Removing PPA ${name} repository" && return 1)
      ;;
    *)
      show_error "Error: Repository type not supported" && return 1
  esac 
}

function remove_apt_repository() {
  local name=$1
  local repo_file="/etc/apt/sources.list.d/${name}.list"
  
  if [ -e "$repo_file" ]; then
     rm "$repo_file"
  else
    show_error "Error: Repository file for ${name} does not exist"
    return 1
  fi
  return 0
}

function remove_ppa_repository() {
  local name=$1
  local repo=$2
  sudo add-apt-repository -ry "$repo"
  return $?
}

function add_repo_keyring() {
  local name=$1
  local key=$2
  if [[ "$key" =~ $HTTP_REGEX ]]; then
    add_repo_keyring_wget $name $key || (show_error "Error: Adding key for repository $name" && return 1)
  else
    add_repo_keyring_apt $name $key || (show_error "Error: Adding key for repository $name" && return 1)
  fi
}

function add_repo_keyring_wget() {
  local name=$1
  local key=$2
  wget -q -O - $key | sudo apt-key add -
  return $?
}

function add_repo_keyring_apt() {
  local name=$1
  local key=$2
  sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys $key
  return $?
}
