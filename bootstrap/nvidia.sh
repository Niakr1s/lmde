#!/usr/bin/env bash

pkgs=(
    nvidia-driver
    libnvidia-api1
    nvtop
)

sudo apt install "${pkgs[@]}"
