#!/bin/bash

# This is my attempt at an install script to facilitate faster setup of all of my OM stuff


sudo dnf clean all;dnf clean all; sudo dnf distro-sync --allowerasing --refresh -y

sudo dnf install ghostty
