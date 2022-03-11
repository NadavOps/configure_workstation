## Source additional files
if [[ $(echo "$0") == *bash* ]]; then
    init_shell_file=".bashrc"
elif [[ $(echo "$0") == *zsh* ]]; then
    init_shell_file=".zshrc"
else
    init_shell_file=".shellrc"
    echo "The shell: \"$0\" is not identified"
fi

shellrc_d_directories=( "$HOME/.shellrc.d" "$HOME/$init_shell_file.d" )
for shellrc_directory in "${shellrc_d_directories[@]}"; do
    for shellrc_file in $(ls $shellrc_directory); do source $shellrc_directory/$shellrc_file; done
done

## Aliases
alias reload_shellrc="source $HOME/$init_shell_file"
alias grep='grep --color=auto'
alias ll='ls -lah'
alias la='ls -A'
alias tailf='tail -f'
alias watch='watch -t -n2'
