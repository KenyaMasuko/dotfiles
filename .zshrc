# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH="/usr/local/bin:$PATH"

# bun completions
[ -s "/Users/masukokenya/.bun/_bun" ] && source "/Users/masukokenya/.bun/_bun"

# Bun
export BUN_INSTALL="/Users/masukokenya/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
VOLTA_HOME=$HOME/.volta

# pnpm
export PNPM_HOME="/Users/masukokenya/Library/pnpm/store/v3"
export PATH="$PNPM_HOME:$PATH"
# pnpm end

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/masukokenya/opt/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/masukokenya/opt/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/masukokenya/opt/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/masukokenya/opt/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# aliasの設定
alias sail="./vendor/bin/sail"
alias ll="ls -laF"
alias vi="nvim"
alias oc="opencommit"
alias g="git"
alias pn="pnpm"

# direnv
eval "$(direnv hook zsh)"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/masukokenya/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/masukokenya/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/masukokenya/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/masukokenya/google-cloud-sdk/completion.zsh.inc'; fi
