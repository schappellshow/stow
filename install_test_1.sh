#!/bin/bash

# This is an install script for OpenMandriva LX ROME. This should also work for ROCK 6.0.
# Created by: Mike Schappell
# Created: July XX, 2025
# Version 1.0
#
#

# Update System
sudo dnf clean all;dnf clean all; sudo dnf distro-sync --allowerasing --refresh -y

# Dependencies
git
wget
curl

# Variables
config="$HOME/mike/.config"
dotfiles="https://github.com/schappellshow/stow.git"
packages="./packages.txt"
flatpaks="./flatpaks.txt"


# Natives Install via dnf


# Flatpaks


# Dotfiles



# Install applications
sudo dnf install ghostty kitty 
