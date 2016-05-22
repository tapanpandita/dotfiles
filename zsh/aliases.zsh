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

# aliases for heroku
alias push-staging='git push origin develop;git push staging develop:master;heroku run python hypertrackapi/manage.py migrate --app hypertrack-api-v2-staging'
alias push-production='git push origin master;git push --tags origin;git push heroku master;heroku run python hypertrackapi/manage.py migrate --app hypertrack-api-v2-prod'
alias ipython-prod='heroku run python hypertrackapi/manage.py shell --app hypertrack-api-v2-prod'
alias ipython-staging='heroku run python hypertrack/manage.py shell --app hypertrack-api-v2-staging'
