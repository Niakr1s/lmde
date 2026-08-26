#!/usr/bin/env bash

pkgs=(
    keepassxc
    handbrake
    virt-manager
)

am_pkgs=(
    losslesscut
    obsidian
)

sudo apt install "${pkgs[@]}"
am -i "${am_pkgs[@]}"

