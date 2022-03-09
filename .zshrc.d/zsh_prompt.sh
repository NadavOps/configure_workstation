#!/bin/zsh
get_cur_time() {
    date +"%T"
}

parse_k8s_context() {
    local k8s_context k8s_symbol
    k8s_symbol=$(echo $'\u2388')
    k8s_context=$(kubectl config view --minify -o jsonpath='{.users[].user.exec.env[].value}' 2> /dev/null)
    if [[ $? == "0" ]]; then echo ''$k8s_symbol'['$k8s_context']'; else echo ""; fi
}

parse_git_branch() {
    local branch_symbol
    branch_symbol=$(echo $'\u2387')
    git rev-parse --git-dir &> /dev/null && echo " $branch_symbol [$(git rev-parse --abbrev-ref HEAD)]"
}

myprompt() {
    local green=002; local red=001; local purple_light=140; local cyan=006; local brownish=138; local bluish=39
    local purple_dark=004; local orange=130; local yellow=142; local dark_cyan=024

    PROMPT='%(?.%F{'$green'}[%?].%F{'$red'}[%?]) %F{'$purple_light'}'$(get_cur_time)' %F{'$brownish'}'$(parse_k8s_context)''$(parse_git_branch)' %F{'$bluish'}'$(pwd)'%f 
%# '
}

precmd() { myprompt; }


## if interactive rebase makes problem consider shifting back to this
# parse_git_branch() {
#     branch_symbol=$(echo $'\u2387')
#     git branch 2> /dev/null | sed -n -e 's/^\* \(.*\)/'$branch_symbol' [\1]/p'
# }