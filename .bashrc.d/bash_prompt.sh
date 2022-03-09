#!/bin/bash
bash_prompt() {
    local exit_code="$?"
    local default="\033[0m"; local cyan="\033[38;5;6m"; local lime='\033[38;5;118m';
    local green='\033[38;5;2m'; local red='\033[38;5;1m'; local purplish='\033[38;5;12m'
    # Choose colour for exit status code
    if [[ $exit_code != 0 ]]; then local exit_color=$red; else local exit_color=$cyan; fi
    # Prompt Line
    ps_exit_code="\[$cyan\][\[$exit_color\]${exit_code}\[$cyan\]]"
    ps_time="\[$purplish\]($(get_current_time))"
    ps_git_branch="\[$cyan\]$(parse_git_branch)"
    ps_path="\[$lime\]\w"
    ps_input="\n\[$default\]% "
    PS1="$ps_exit_code $ps_time $ps_git_branch$ps_path$ps_input"
}

parse_git_branch() {
    git rev-parse --git-dir &> /dev/null && echo "($(git rev-parse --abbrev-ref HEAD)) "
}

get_current_time() {
    date +"%T"
}

export PROMPT_COMMAND=bash_prompt
