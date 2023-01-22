[[ $TERM_PROGRAM = "iTerm.app" ]] || return 0

# Allow using the option (alt) key to move through words, iterm does not allow that by default
# Another way to to achieve it is by using the ".inputrc" file
bind '"\e\e[D": backward-word'
bind '"\e\e[C": forward-word'