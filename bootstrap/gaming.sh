#!/usr/bin/env bash

pkgs=(
    lutris
    steam
    mangohud
)

sudo apt install "${pkgs[@]}"

link_steamruntime_to_umu() {
  mkdir -p ~/.local/share/umu
  rm -rf ~/.local/share/umu/steamrt*
  ln -s ~/.steam/debian-installation/steamapps/common/SteamLinuxRuntime ~/.local/share/umu/steamrt1
  ln -s ~/.steam/debian-installation/steamapps/common/SteamLinuxRuntime ~/.local/share/umu/steamrt
  ln -s ~/.steam/debian-installation/steamapps/common/SteamLinuxRuntime_soldier ~/.local/share/umu/steamrt2
  ln -s ~/.steam/debian-installation/steamapps/common/SteamLinuxRuntime_sniper ~/.local/share/umu/steamrt3
  ln -s ~/.steam/debian-installation/steamapps/common/SteamLinuxRuntime_4 ~/.local/share/umu/steamrt4
}

link_steamruntime_to_umu
