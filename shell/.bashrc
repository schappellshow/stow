# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

export PATH="$HOME/.cargo/bin:$PATH"

export PATH="$HOME/.local/bin:$PATH"

#fastfetch --kitty-direct /home/mike/Pictures/Logo/openmandriva-logo1.png

BAT_THEME="base16"

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

#Aliases
#alias alias_name="command_to_run"

#Long format list
alias ll="ls -la"

#DNF5
#alias dnf="dnf5" && alias sudo="sudo "

#Upgrade system
alias dsync="sudo dnf clean all ; dnf clean all ; sudo dnf upgrade; flatpak update; cargo install-update -a"

#History or latest installed packages
alias dhist="rpm -qa --last |less"

#Install new package
alias din="sudo dnf install"

#Remove package
alias drm="sudo dnf remove"

#Search for package name
alias dsearch="dnf search"

#fzf w/ colorized bat preview
alias fbat='fzf --preview "bat --color=always --style=numbers --line-range=:500 {}"'

alias nfbat='nvim $(fzf --preview "bat --color=always --style=numbers --line-range=:500 {}")'

alias mfbat='micro $(fzf --preview "bat --color=always --style=numbers --line-range=:500 {}")'

#trash-cli
alias rm="trash-put"

#SpotX
alias spotx="bash <(curl -sSL https://raw.githubusercontent.com/SpotX-Official/SpotX-Bash/main/spotx.sh) -f"

#LSD
alias ls='"lsd"'

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

eval "$(zoxide init --cmd cd bash)"

#. "$HOME/.cargo/env"


# Rust/Cargo environment settings
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

# Cargo linker configuration for OpenMandriva
export RUSTFLAGS="-C link-arg=-fuse-ld=bfd"
export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER=gcc
