# pip
alias pipi='sudo pip install'
alias pipu='sudo pip install -U'
alias pipr='sudo pip uninstall'

# apt
alias agi='sudo apt-get install'
alias agr='sudo apt-get remove'
alias agu='sudo apt-get update'
alias agup='sudo apt-get upgrade'
alias agar='sudo apt-get autoremove'
alias agc='sudo apt-get clean'
alias agac='sudo apt-get autoclean'

# npm
alias npmi='sudo npm install --global'

# tmux
alias tmux='TERM=xterm-256color tmux'

# convenience
alias killp='pgrep $1 | xargs sudo kill'
alias asciifu='grep -P "[\x80-\xFF]"'
alias non_ascii='grep --color="auto" -P -n "[\x80-\xFF]" '
alias ed='ed -p "ed> "'
alias emacs='emacs -nw'
