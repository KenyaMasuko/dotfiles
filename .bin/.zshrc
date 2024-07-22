# alias
alias sail="./vendor/bin/sail"
alias ll="ls -laF"
alias vi="nvim"
alias oc="opencommit"
alias g="git"
alias pn="pnpm"

# volta setting
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
VOLTA_HOME=$HOME/.volta
export PATH=$VOLTA_HOME/bin:$PATH

# Load Homebrew environment settings
eval "$(/opt/homebrew/bin/brew shellenv)"

# Initialize Starship for Zsh
eval "$(starship init zsh)"

# pnpm
export PNPM_HOME="/Users/kenya.masuko/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
