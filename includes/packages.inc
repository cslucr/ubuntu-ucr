#!/bin/bash
#
# Handle packages: instalation and configurations.


#TODO: Need bats test.
function create_wget_cache() {
  # Creates a folder for caching files downloaded with wget
  mkdir -p $WGET_CACHE_PATH || error_exit "Error creating wget cache folder"
}

function refresh_packages() {
  sudo apt update || error_exit "Error refreshing APT package list"

  return 0
}

function purge_package_list() {
  local pkg_list=$1
  apt -y purge $pkg_list || error_exit "Error purging APT packages"
  
  return 0
}

function distupgrade_packages() {
  refresh_packages
  DEBIAN_FRONTEND=noninteractive sudo apt -y full-upgrade || error_exit "Error full-upgrading APT packages"

  return 0
}

# Install list of packages
function install_package_list() {
  local pkg_list=$1
  refresh_packages
  DEBIAN_FRONTEND=noninteractive sudo apt install $pkg_list  || error_exit "Error installing packages"
  
  return 0
}

function autoremove_packages() {
  apt -y autoremove || error_exit "Error autoremoving APT packages"
  
  return 0
}

function clean_packages_cache() {
  if ! $APT_CACHE ; then
    sudo apt clean
  fi

  return 0
}

