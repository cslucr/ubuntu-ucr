#!/bin/bash
#
# Shared varibles.

# Does not saves apt cache.
APT_CACHE=false

# Path where to download files via wget.
WGET_CACHE=/tmp/wget_cache

# Ask before make any changes.
NO_FORCE=true

# Directory where the script is being executed.
SCRIPT_PATH=$(readlink -f $0)
BASE_DIR=$(dirname "$SCRIPT_PATH")

# Fix base dir when running bats tests.
if [[ $BASE_DIR == *'bats'* ]]; then
  BASE_DIR=(${BASE_DIR//ubuntu-ucr/ })
  BASE_DIR=$BASE_DIR/ubuntu-ucr
fi

# Computer architecture.
ARCH=$(uname -m)

# This variable aggregates package names that will be installed:
# packages="$packages package1 package2 package3"
packages=""

# This variable aggregates package names that will be uninstalled
#  purgepackages="$purgepackages package1 package2 package3"
purge_packages=""

# This variable aggregates path to .desktop files for applications
# that must run on startup:
#  autostart="$autostart path1 path2 path3"
autostart=""

# REGEX for matching HTTP strings
HTTP_REGEX='https?://([-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|])'

# Path to yaml parser.
YAML_PARSER=${BASE_DIR}/resources/libs/yq_linux_${ARCH}

# Path to ubuntu.yml file.
CONFIGURATION_FILE=${BASE_DIR}/configuration/ubuntu.yml #TODO: load as parameter, default ubuntu. i.e. ubuntu-ucr-customization-sh -y ubuntu
