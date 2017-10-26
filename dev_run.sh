#!/bin/sh

mkdir -p cache/apt
mkdir -p cache/wget

echo "Removing temporary file"
sudo rm -rf ubuntu-iso-customization
echo "Creating ISO"
./ubuntu-iso-customization.sh -d -c "cache/apt" -w "cache/wget" ubuntu-mate-16.04.3-desktop-amd64.iso
