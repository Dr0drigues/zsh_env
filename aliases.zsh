# cd
alias ..='cd ..'

# clear
alias c='clear'

# ls / replaced by eza
## Colorize the ls output ##
alias ls='eza --color=auto'

alias l="ls -lah"

## Use a long listing format ##
alias ll='ls -la'

## Show hidden files ##
alias l.='ls -d .* --color=auto'

# history
alias h='history'

# tar
## unzip a tar file ##
alias untar='tar -zxvf $1'

## zip argument onto a tar ##
alias tar='tar -czvf $1'

# git
alias gst='git status'
alias gl='git fetch --all; git pull'
alias ga='git add $1'
alias gp='git push'
alias gc='git commit $1'
alias gld='git log –oneline –decorate –graph –all' 

# source
alias s="source $1"
alias ss="source $HOME/.zshrc"

# Misc
## Re-run last command using sudo ##
alias please='/usr/bin/sudo $(history -p !!)'

