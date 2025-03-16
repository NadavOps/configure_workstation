[[ $TERM_PROGRAM = "iTerm.app" ]] || return 0

# bind key article https://www.computerhope.com/unix/bash/bind.htm
# Allow using the option (alt) key to move through words, iterm does not allow that by default
# Another way to to achieve it is by using the ".inputrc" file
bind '"\e[1;3C": forward-word'
bind '"\e[1;3D": backward-word'
