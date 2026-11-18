#!/usr/bin/bash

# File location /home/username/.local/bin/update.sh
# and can be called from the ~/.bash_aliases or ~/.bashrc file with this alias command
# alias dsync="~/.local/bin/update.sh" # dnf updates for OpenMandriva with log file
#
# om-post-update holds the "what matters on this desktop" logic (watch set,
# preflight, post-update checks); this script only sequences it. Resolve it via
# the real file so the call works whether or not ~/.local/bin is on PATH.
OMPU="$(dirname "$(readlink -f "$0")")/om-post-update"
[ -x "$OMPU" ] || OMPU="$HOME/.local/bin/om-post-update"

echo # This just adds blank line to separate these headers.
echo -e "\033[0;33m╔═══════════════════════════════╗\033[0m" # Yellow for look-before-you-leap
echo -e "\033[0;33m║**Checking the pending update**║\033[0m" # Yellow for look-before-you-leap
echo -e "\033[0;33m╚═══════════════════════════════╝\033[0m" # Yellow for look-before-you-leap
# Preflight ALWAYS runs: it reads dnf's real pending transaction (a dry run, no
# root) for the packages that have broken this desktop before. Exit 0 = clean,
# 1 = flagged, anything else = it could not tell. Only "clean" proceeds without
# asking: an unknown answer must not read as a safe one.
"$OMPU" --preflight
case $? in
    0) ;;
    1) echo
       read -r -p "Continue with the update? [y/N] " answer
       case "$answer" in [yY]|[yY][eE][sS]) ;; *) echo "Update cancelled."; exit 1 ;; esac ;;
    *) echo
       echo -e "\033[0;33mPreflight could not inspect the pending update (see above).\033[0m"
       read -r -p "Continue with the update anyway? [y/N] " answer
       case "$answer" in [yY]|[yY][eE][sS]) ;; *) echo "Update cancelled."; exit 1 ;; esac ;;
esac

# The newest transaction id BEFORE updating, so afterwards "did dnf do anything
# at all?" is a comparison and not a guess from its output.
txn_before=$("$OMPU" --last-txn 2>/dev/null)

echo
echo -e "\033[0;31m╔════════════════════════════════╗\033[0m" # Red for root.
echo -e "\033[0;31m║**Updating all System packages**║\033[0m" # Red for root.
echo -e "\033[0;31m╚════════════════════════════════╝\033[0m" # Red for root.
echo
{ sudo dnf clean all ; dnf clean all ; sudo dnf distro-sync --allowerasing --refresh ; } 2>&1 | tee ~/dsync-log.txt
# PIPESTATUS[0] is the braces group, whose status is the LAST command: the
# distro-sync. Without it `tee`'s success would hide a failed update.
dnf_status=${PIPESTATUS[0]}
echo
echo -e "\033[0;34m╔═════════════════════════════╗\033[0m" # Blue for user
echo -e "\033[0;34m║**Updating AppImages via AM**║\033[0m" # Blue for user
echo -e "\033[0;34m╚═════════════════════════════╝\033[0m" # Blue for user
echo
am -u
echo
# Post-update checks are slow and can sudo, so run them only when this update
# changed something the desktop depends on. Judged from what dnf ACTUALLY did
# (dnf history), not from the preflight's prediction.
txn_after=$("$OMPU" --last-txn 2>/dev/null)
if [ "$dnf_status" -ne 0 ]; then
    echo -e "\033[0;31mdnf distro-sync exited with status $dnf_status; see ~/dsync-log.txt.\033[0m"
fi
if [ -z "$txn_after" ] || [ "$txn_after" = "$txn_before" ]; then
    echo "No new dnf transaction; post-update check skipped."
else
    changed=$("$OMPU" --needs-check "$txn_after")
    case $? in
        0) echo -e "\033[0;33m╔═══════════════════════════════╗\033[0m"
           echo -e "\033[0;33m║**Checking the desktop (post)**║\033[0m"
           echo -e "\033[0;33m╚═══════════════════════════════╝\033[0m"
           echo "Desktop-critical packages changed:"
           echo "$changed"
           # The update's sudo ticket may have expired during dnf and am; a
           # prompt here beats the lgi/amdgpu fixes silently failing.
           sudo -v
           "$OMPU" ;;
        1) echo "No desktop-critical packages changed; post-update check skipped." ;;
        # Could not tell: the check is read-mostly and idempotent, so over-run.
        *) echo -e "\033[0;33mCould not classify transaction $txn_after; running the full check to be safe.\033[0m"
           sudo -v
           "$OMPU" ;;
    esac
fi
echo
#echo -e "\033[0;33m╔═══════════════════════════════╗\033[0m" # Cyan for user
#echo -e "\033[0;33m║**Updating Rust-Compiled Apps**║\033[0m" # Cyan for user
#echo -e "\033[0;33m╚═══════════════════════════════╝\033[0m" # Cyan for user
#echo
#cargo install-update -a
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
