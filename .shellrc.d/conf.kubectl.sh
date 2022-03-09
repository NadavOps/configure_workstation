## Kubectl
[[ $(command -v kubectl) ]] || exit 0

## Kubectl aliases
alias kube='kubectl'
alias kubens='kubectl config set-context --current --namespace $1'

kubecontext() {
    local desired_context current_context all_contexts suffix tmp_config
    KUBECONFIG=""
    desired_context="$1"
    [[ -z "$desired_context" ]] && bash_logging ERROR "Specify a context to switch into" && return 1
    current_context="$(kubectl config current-context)"
    all_contexts=$(kubectl config view -o jsonpath='{.contexts[*].name}' | tr " " "\n")
    echo $all_contexts | grep "^$desired_context$" > /dev/null
    if [[ $? != "0" ]]; then bash_logging ERROR "desired_context: \"$desired_context\" was not found. choose from: \n$(echo $all_contexts)" && return 1; fi
    kubectl config use-context "$desired_context"
    suffix=$(date -u "+%Y.%m.%d-%H_%M_%S")
    tmp_config="/tmp/kube_config.$suffix"
    kubectl config view --minify > "$tmp_config"
    kubectl config use-context "$current_context" > /dev/null
    export KUBECONFIG="$tmp_config"
}

## need to add that with conditional of completion
## https://kubernetes.io/docs/tasks/tools/included/optional-kubectl-configs-bash-linux/