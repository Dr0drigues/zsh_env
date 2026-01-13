eval "$(starship init zsh)"

# Init
## Load variables ##
if [ -f "$ZSH_ENV_DIR/variables.zsh" ]; then
    source "$ZSH_ENV_DIR/variables.zsh"
fi
## Load aliases ##
if [ -f "$ZSH_ENV_DIR/aliases.zsh" ]; then
    source "$ZSH_ENV_DIR/aliases.zsh"
fi
## Load functions ##
if [ -f "$ZSH_ENV_DIR/functions.zsh" ]; then
    source "$ZSH_ENV_DIR/functions.zsh"
fi

# PATH
## Always prepend new folders to :$PATH
export PATH="$SCRIPTS_DIR:$PATH"

# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
