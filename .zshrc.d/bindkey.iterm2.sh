[[ $TERM_PROGRAM = "iTerm.app" ]] || return 0

# Bind key article https://apple.stackexchange.com/questions/154292/iterm-going-one-word-backwards-and-forwards
# Allow using the option (alt) key to move through words, iterm does not allow that by default
# bindkey alone will output the bindings
# '⌘ + ,' -> 'Preferences' -> 'Profiles' -> 'Keys' -> change left+right option key to 'Esc+'
bindkey "\e[1;3C" forward-word   # Alt + →
bindkey "\e[1;3D" backward-word  # Alt + ←
