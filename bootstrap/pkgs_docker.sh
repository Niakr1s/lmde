#!/usr/bin/env bash

pkgs=(
    docker.io
    docker-compose
)

sudo apt install "${pkgs[@]}"

sudo systemctl enable --now docker
sudo usermod -aG docker $USER
