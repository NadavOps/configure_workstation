[[ $TERM_PROGRAM = "iTerm.app" ]] || return 0

# Taken from here: https://apple.stackexchange.com/questions/154292/iterm-going-one-word-backwards-and-forwards
# Allow using the option (alt) key to move through words, iterm does not allow that by default
bindkey "[D" backward-word
bindkey "[C" forward-word