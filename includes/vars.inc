#!/bin/bash
#
# Shared varibles.

# Does not saves apt cache.
APT_CACHED=false

# Does not saves wget cache.
WGET_CACHED=false

# Path where to download files via wget.
WGET_CACHE=/tmp/wget_cache

# Ask before make any changes.
NOFORCE=true

# Directory where the script is being executed.
SCRIPTPATH=$(readlink -f $0)
BASEDIR=$(dirname "$SCRIPTPATH")

# Computer architecture.
arch=$(uname -m)

# This variable aggregates package names that will be installed:
# packages="$packages package1 package2 package3"
packages=""

# This variable aggregates package names that will be uninstalled
#  purgepackages="$purgepackages package1 package2 package3"
purgepackages=""

# This variable aggregates path to .desktop files for applications
# that must run on startup:
#  autostart="$autostart path1 path2 path3"
autostart=""

# REGEX for matching HTTP strings
HTTP_REGEX='https?://([-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|])'

