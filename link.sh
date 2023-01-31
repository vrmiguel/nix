#!/usr/bin/env bash

set -e

VCS_CONFIG="etc/nixos/configuration.nix"
NIX_CONFIG="/etc/nixos/configuration.nix"

if [[ $UID != 0 ]]; then
    echo "Must run with sudo privileges"
    exit 1
fi

if [ ! -f VCS_CONFIG ] ; then
    echo "No config file in VCS"
    exit 1
fi

cp -f etc/nixos/configuration.nix "$NIX_CONFIG"

echo "> Overwrote configuration.nix"

echo "> Running nixos-rebuild switch"
nixos-rebuild switch