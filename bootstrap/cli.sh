#!/usr/bin/env bash

pkgs=(
    git
    yadm
    curl
    extrepo
)

sudo apt install "${pkgs[@]}"

which uv || curl -LsSf https://astral.sh/uv/install.sh | sh
