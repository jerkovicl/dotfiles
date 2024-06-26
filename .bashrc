eval `ssh-agent -s` #Turning on SSH-Agent
#ssh-add $pemfiles

# Only set and export EDITOR and GIT_EDITOR env variables if they have been empty.
[ -z "$EDITOR" ] && export EDITOR=vim
[ -z "$GIT_EDITOR" ] && export GIT_EDITOR=vim

# Fixing global terminal colors
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

#CUSTOM FUNCTIONS
gh_clone() {
  git clone "https://github.com/$1.git"
}

# ALIASES CUSTOM
alias pull-all='find . -type d -name .git -execdir git pull -v ";"'
alias update-all='/usr/local/bin/update-all'
alias rimraf='rm -rf'
alias cls='clear'
alias cd..='cd ..'
alias .='cd .'
alias ..='cd ..'
alias ll='ls -l'
alias gh-clone=gh_clone

clear
