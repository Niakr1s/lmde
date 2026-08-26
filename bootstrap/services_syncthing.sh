#!/usr/bin/env bash

pkgs=(
    syncthing
)

sudo apt install "${pkgs[@]}"
systemctl enable --now --u syncthing
