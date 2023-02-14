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

## Environment variables
export PERSONAL_GIT_DIR="${PERSONAL_GIT_DIR:-"$HOME/my_git"}"
## Aliases
alias reload_shellrc="source $HOME/$init_shell_file"
alias reinstall_shellrc_generic="bash $PERSONAL_GIT_DIR/configure_workstation/bash_configure_workstation.sh"
alias reinstall_shellrc_opinionated="bash $PERSONAL_GIT_DIR/job_related/configure_workstation/configure_workstation.sh"
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
# if [ -x /usr/bin/dircolors ]; then alias ls='ls --color=auto'; fi
alias ll='ls -lah'
alias la='ls -A'
alias tailf='tail -f'
alias watch='watch -t -n2'
