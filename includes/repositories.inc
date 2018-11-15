#!/bin/bash
#
# Handle packages: instalation and configurations.

function add_repository() {
  local name=$1
  local type=$2
  local repo=$3  
}

function add_apt_repository() {
  local name=$1
  local repo=$2
  #TODO check what happens with amd64 repos like Google Chrome
  sudo sh -c "echo \"${repo}\" > /etc/apt/sources.list.d/${name}.list"
}

function add_ppa_repository() {
  local name=$1
  local repo=$2
  sudo add-apt-repository -y "$repo" || error_exit "Error adding PPA: $name"  
}

function remove_repository() {
}

function remove_apt_repository() {

}

function remove_ppa_repository() {
  local name=$1
  local repo=$2
  sudo add-apt-repository -ry "$repo" || error_exit "Error adding PPA: $name"
}

function add_repo_keyring() {
  local name=$1
  local type=$2
  local key=$3 
}

function add_repo_keyring_wget() {
  local name=$1
  local key=$2
  wget -q -O - $key | sudo apt-key add - || error_exit "Error Adding key for repository $name"
}

function add_repo_keyring_apt() {
  local name=$1
  local key=$2
  sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys $key || error_exit "Error Adding key for repository $name"
}
