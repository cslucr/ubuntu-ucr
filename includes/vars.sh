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
ARCH=$(uname -m)

