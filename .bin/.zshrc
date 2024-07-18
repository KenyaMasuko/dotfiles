# alias
alias sail="./vendor/bin/sail"
alias ll="ls -laF"
alias vi="nvim"
alias oc="opencommit"
alias g="git"
alias pn="pnpm"


# Load Homebrew environment settings
eval "$(/opt/homebrew/bin/brew shellenv)"

# Initialize Starship for Zsh
eval "$(starship init zsh)"
