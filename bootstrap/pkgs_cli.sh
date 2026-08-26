#!/usr/bin/env bash

pkgs=(
    git
    yadm
    curl
    extrepo
    golang-go
    btm
    xclip
    borgbackup
    lazygit
    neovim
)

sudo apt install "${pkgs[@]}"

which uv || curl -LsSf https://astral.sh/uv/install.sh | sh

which am || (cd /tmp; wget -q https://raw.githubusercontent.com/ivan-hc/AM/main/INSTALL && chmod a+x ./INSTALL && sudo ./INSTALL && rm ./INSTALL)
