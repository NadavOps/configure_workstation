## Git
[[ $(command -v curl) ]] || return 0

github_dispatch_workflow() {
    local git_owner git_repository branch_name workflow_filename git_token inputs dry_run tmp
    git_owner="${1-GIT_OWNER}"
    git_repository="$2"
    branch_name="${3-main}"
    workflow_filename="$4"
    git_token="${5-$GIT_TOKEN}"
    inputs="$6"
    dry_run="${7-false}"
    if [[ -z "$git_owner" || -z "$git_repository" || -z "$branch_name" || -z "$workflow_filename" || -z "$git_token" ]]; then
        bash_logging ERROR "not all parameters supplied"
        return 1
    fi

    if [[ -f "$git_token" ]]; then
        bash_logging ERROR "Git token: \"$git_token\" will be read from file"
        tmp=$(cat "$git_token"); git_token="$tmp"
    fi
    
    bash_logging DEBUG "git_owner: $git_owner"
    bash_logging DEBUG "git_repository: $git_repository"
    bash_logging DEBUG "branch_name: $branch_name"
    bash_logging DEBUG "workflow_filename: $workflow_filename"
    bash_logging DEBUG "git_token: $git_token"
    bash_logging DEBUG "inputs: $inputs"

    bash_logging DEBUG """Formed command:
        curl -L -X POST
            -H \"Accept: application/vnd.github+json\"
            -H \"Authorization: Bearer $git_token\"
            -H \"X-GitHub-Api-Version: 2022-11-28\"
            https://api.github.com/repos/$git_owner/$git_repository/actions/workflows/$workflow_filename/dispatches
            -d '{\"ref\":\"$branch_name\",\"inputs\":{'$inputs'}}'
    """
    
    if [[ "$dry_run" == "false" ]]; then
        bash_logging INFO "Running the above command"
        curl -L -X POST \
            -H "Accept: application/vnd.github+json" \
            -H "Authorization: Bearer $git_token"\
            -H "X-GitHub-Api-Version: 2022-11-28" \
            https://api.github.com/repos/$git_owner/$git_repository/actions/workflows/$workflow_filename/dispatches \
            -d '{"ref":"'$branch_name'","inputs":{'$inputs'}}'
    fi
}
