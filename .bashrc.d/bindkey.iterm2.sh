[[ $TERM_PROGRAM = "iTerm.app" ]] || return 0

# Taken from here: https://apple.stackexchange.com/questions/154292/iterm-going-one-word-backwards-and-forwards
# Allow using the option (alt) key to move through words, iterm does not allow that by default
bind '"\e\e[D": backward-word'
bind '"\e\e[C": forward-word'