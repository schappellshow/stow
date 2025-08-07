#Aliases
#alias alias_name="command_to_run"

#ls aliases
alias ll="ls -l"

alias la="ls -a"

alias lla="ls -la"

#DNF5
#alias dnf="dnf5" && alias sudo="sudo "

#Upgrade system
alias dsync="~/.local/bin/update.sh"

#SpotX
alias spotx="bash <(curl -sSL https://raw.githubusercontent.com/SpotX-Official/SpotX-Bash/main/spotx.sh) -f"

#LSD
alias ls='"lsd"'

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
