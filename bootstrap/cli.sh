#!/usr/bin/env bash

pkgs=(
    git
    yadm
    curl
)

sudo apt install "${pkgs[@]}"
