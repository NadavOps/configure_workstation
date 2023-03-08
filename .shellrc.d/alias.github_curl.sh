## Git
[[ $(command -v curl) ]] || return 0

github_dispatch_workflow() {
    local git_repository workflow_filename branch_name inputs git_token git_owner
    git_repository="$1"
    workflow_filename="$2"
    branch_name="$3"
    inputs="$4"
    if [[ -z "$git_repository" || -z "$workflow_filename" || -z "$branch_name" || -z "$inputs" ]]; then
        bash_logging ERROR "not all parameters supplied"
    fi
    git_token="cat ${5-$GIT_TOKEN}"
    bash_logging DEBUG "token: $git_token"
    git_owner="${6-$GIT_OWNER}"
    bash_logging DEBUG "owner: $git_owner"
    if [[ ! -f "$git_token" ]]; then bash_logging ERROR "Git token: \"$git_token\" was not found"; return 1; fi
    curl -L -X POST \
        -H "Accept: application/vnd.github+json" \
        -H "Authorization: Bearer $git_token"\
        -H "X-GitHub-Api-Version: 2022-11-28" \
        https://api.github.com/repos/$git_owner/$git_repository/actions/workflows/$workflow_filename/dispatches \
        -d '{"ref":"'$branch_name'","inputs":{'$inputs'}}'
}
