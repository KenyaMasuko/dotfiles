# alias
alias sail="./vendor/bin/sail"
alias ll="ls -laF"
alias vi="nvim"
alias oc="opencommit"
alias g="git"
alias pn="pnpm"

export PATH=/opt/homebrew/bin/:$PATH

# Load Homebrew environment settings
eval "$(/opt/homebrew/bin/brew shellenv)"

# Initialize Starship for Zsh
eval "$(starship init zsh)"

zsh-completions
if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
    autoload -Uz compinit
    compinit
fi

# pnpm
export PNPM_HOME="/Users/kenya.masuko/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# mise
eval "$(~/.local/bin/mise activate zsh)"

# コマンド履歴を１万行保存する
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt hist_ignore_dups  # 同じコマンドを履歴に残さない
setopt share_history     # 同時に起動したzshで履歴を共有する

# option + n/pでコマンド履歴を検索する
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^N" history-beginning-search-forward-end
bindkey "^P" history-beginning-search-backward-end
