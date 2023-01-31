#!/usr/bin/env bash

set -e


DIR="$( dirname -- "${BASH_SOURCE[0]}"; )";   # Get the directory name
DIR="$( realpath -e -- "$DIR"; )";    # Resolve its full path if need be
cd "$DIR"

VCS_CONFIG="$DIR/etc/nixos/configuration.nix"
NIX_CONFIG="/etc/nixos/configuration.nix"

if [[ $UID != 0 ]]; then
    echo "Must run with sudo privileges"
    exit 1
fi

echo "> Overwriting configuration.nix"
cp -f "$VCS_CONFIG" "$NIX_CONFIG"


echo "> Running nixos-rebuild switch"
nixos-rebuild switch