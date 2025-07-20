#!/bin/bash

# This is my attempt at an install script to facilitate faster setup of all of my OM stuff

# Update System
sudo dnf clean all;dnf clean all; sudo dnf distro-sync --allowerasing --refresh -y

# Install applications
sudo dnf install ghostty kitty 
