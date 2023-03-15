#!/usr/bin/env bash

set -e


DIR="$( dirname -- "${BASH_SOURCE[0]}" )" # Get the directory name
DIR="$( realpath -e -- "$DIR" )"          # Resolve its full path if need be
cd "$DIR"

AWESOME_CONFIG="$DIR/.config/awesome/rc.lua"

echo "$AWESOME_CONFIG"
VCS_CONFIG="$DIR/etc/nixos/configuration.nix"
NIX_CONFIG="/etc/nixos/configuration.nix"

if [[ $UID != 0 ]]; then
    echo "Must run with sudo privileges"
    exit 1
fi

echo "> Overwriting configuration.nix"
cp -f "$VCS_CONFIG" "$NIX_CONFIG"

echo "> Overwriting Awesome config"
cp -f "$AWESOME_CONFIG" "/home/vrmiguel/.config/awesome/rc.lua"

echo "> Running nixos-rebuild switch"
nixos-rebuild switch
