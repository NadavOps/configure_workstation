#!/bin/zsh
get_cur_time() {
    date +"%T"
}

parse_k8s_context() {
    local k8s_symbol k8s_context k8s_namespace
    [[ $(command -v kubectl) && -d $HOME/.kube && (-f $HOME/.kube/config || -n $KUBECONFIG) ]] || return 0
    k8s_symbol=$(echo $'\u2388')
    k8s_context=$(kubectl config view -o jsonpath='{.current-context}' 2> /dev/null)
    k8s_namespace=$(kubectl config view -o jsonpath="{.contexts[?(@.name == '$k8s_context')].context.namespace}")
    if [[ $? == "0" ]]; then echo ''$k8s_symbol'['$k8s_context/$k8s_namespace']'; else echo ""; fi
}

parse_git_branch() {
    local branch_symbol head_pointer
    [[ $(command -v git) ]] || return 0
    branch_symbol=$(echo $'\u2387')
    head_pointer=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
    git rev-parse --git-dir &> /dev/null && echo " $branch_symbol [$head_pointer]"
}

myprompt() {
    local red=001; local green=002; local yellow=003; local purple_dark=004; local purple_light=140; local cyan=006; local brownish=138; local bluish=39
    local orange=166; local orange_light=130; local yellow=142; local dark_cyan=024; local green=35; local green_light=36; local peach=216

    PROMPT='%(?.%F{'$green'}[%?].%F{'$red'}[%?]) %F{'$purple_light'}'$(get_cur_time)' %F{'$bluish'}'$(parse_k8s_context)'%F{'$green_light'}'$(parse_git_branch)' %F{'$peach'}'$(pwd)'%f 
%# '
}

precmd() { myprompt; }


## if interactive rebase makes problem consider shifting back to this
# parse_git_branch() {
#     branch_symbol=$(echo $'\u2387')
#     git branch 2> /dev/null | sed -n -e 's/^\* \(.*\)/'$branch_symbol' [\1]/p'
# }