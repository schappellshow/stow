#!/usr/bin/bash

# File location /home/username/.local/bin/update.sh
# and can be called from the ~/.bash_aliases or ~/.bashrc file with this alias command
# alias dsync="~/.local/bin/update.sh" # dnf updates for OpenMandriva with log file
#
echo # This just adds blank line to separate these headers.
echo -e "\033[0;31m╔════════════════════════════════╗\033[0m" # Red for root.
echo -e "\033[0;31m║**Updating all System packages**║\033[0m" # Red for root.
echo -e "\033[0;31m╚════════════════════════════════╝\033[0m" # Red for root.
echo
{ sudo dnf clean all ; dnf clean all ; sudo dnf distro-sync --allowerasing --refresh ; } 2>&1 | tee ~/dsync-log.txt
echo
echo -e "\033[0;34m╔═════════════════════════════╗\033[0m" # Blue for user
echo -e "\033[0;34m║**Updating AppImages via AM**║\033[0m" # Blue for user
echo -e "\033[0;34m╚═════════════════════════════╝\033[0m" # Blue for user
echo
am -u
echo
echo -e "\033[0;33m╔═══════════════════════════════╗\033[0m" # Cyan for user
echo -e "\033[0;33m║**Updating Rust-Compiled Apps**║\033[0m" # Cyan for user
echo -e "\033[0;33m╚═══════════════════════════════╝\033[0m" # Cyan for user
echo
cargo install-update -a
echo
echo -e "\033[0;32m╔═════════════════════╗\033[0m" # Green for complete
echo -e "\033[0;32m║**Update Completed!**║\033[0m" # Green for complete
echo -e "\033[0;32m╚═════════════════════╝\033[0m" # Green for complete
echo

# There are some special characters used to make the boxes.
# ╔ ╗ ╚ ╝ ═ ║
#
# Color References placed here for your convenience
# Reset
# \e[0;0m | NoColor
#
# Regular Colors
# Value    | Color
# -------- | ------
# \e[0;30m | Black
# \e[0;31m | Red
# \e[0;32m | Green
# \e[0;33m | Yellow
# \e[0;34m | Blue
# \e[0;35m | Purple
# \e[0;36m | Cyan
# \e[0;37m | White
#
# Bold Text Colors
# Value    | Color
# -------- | ------
# \e[1;30m | Bright Black
# \e[1;31m | Bright Red
# \e[1;32m | Bright Green
# \e[1;33m | Bright Yellow
# \e[1;34m | Bright Blue
# \e[1;35m | Bright Purple
# \e[1;36m | Bright Cyan
# \e[1;37m | Bright White

# Tip: Make sure Kate is using the same monospace font as your terminal
# 
# Special characters can be found with
# `sudo dnf install plasma6-kcharselect --refresh'
# They were under "common"
#
# https://forum.openmandriva.org/t/rice-for-the-sake-of-rice-in-an-update-script/7454
#
