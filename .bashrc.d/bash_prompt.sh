#!/bin/bash
get_current_time() {
    date +"%T"
}

parse_k8s_context() {
    [[ $(command -v kubectl) && -d ~/.kube ]] || return 0
    local k8s_symbol k8s_context k8s_namespace
    k8s_symbol=$(echo $'\u2388')
    k8s_context=$(kubectl config view -o jsonpath='{.current-context}' 2> /dev/null)
    # k8s_context=$(kubectl config view --minify -o jsonpath='{.users[].user.exec.env[].value}' 2> /dev/null) --> old way
    k8s_namespace=$(kubectl config view -o jsonpath="{.contexts[?(@.name == '$k8s_context')].context.namespace}")
    if [[ $? == "0" ]]; then echo ''$k8s_symbol'['$k8s_context/$k8s_namespace']'; else echo ""; fi
}

parse_git_branch() {
    [[ $(command -v git) ]] || return 0
    local branch_symbol head_pointer
    branch_symbol=$(echo $'\u2387')
    head_pointer=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
    git rev-parse --git-dir &> /dev/null && echo "$branch_symbol [$head_pointer] "
}

bash_prompt() {
    local exit_code="$?"
    ## Colors at https://i.stack.imgur.com/clnVw.jpg
    local default=$(tput setaf 15); local red=$(tput setaf 01); local green=$(tput setaf 35); local purple_light=$(tput setaf 140); local bluish=$(tput setaf 27)
    local green_light=$(tput setaf 36); local peach=$(tput setaf 216)
    # Choose colour for exit status code
    if [[ $exit_code != 0 ]]; then local exit_color=$red; else local exit_color=$green; fi
    # Prompt Line
    ps_exit_code="\[$exit_color\][\[$exit_color\]${exit_code}\[$exit_color\]]"
    ps_time="\[$purple_light\]$(get_current_time)"
    ps_k8s="\[$bluish\]$(parse_k8s_context)"
    ps_git_branch="\[$green_light\]$(parse_git_branch)"
    ps_path="\[$peach\]\w"
    ps_input="\n\[$default\]# "
    PS1="$ps_exit_code $ps_time $ps_k8s $ps_git_branch$ps_path$ps_input"
}

export PROMPT_COMMAND=bash_prompt
