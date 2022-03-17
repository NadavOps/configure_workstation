## Git
[[ $(command -v git) ]] || exit 0

## Git aliases
git_squash_later() {
    local branch_name force_flag
    if ! git rev-parse --git-dir 2> /dev/null; then bash_logging ERROR "$(pwd) is not a git directory" && return 1; fi
    force_flag="$1"
    branch_name=$(git rev-parse --abbrev-ref HEAD)
    if [[ $branch_name == "main" || $branch_name == "master" ]] && [[ $force_flag != "--force" ]]; then
        bash_logging ERROR "You are trying to run the function without the --force flag in a branch named: \"$branch_name\". master/ main are not allowed"
        return 1
    fi
    if [[ $branch_name == "main" || $branch_name == "master" ]] && [[ $force_flag == "--force" ]]; then
        bash_logging WARN "You are pushing to \"$branch_name\" with dirty commit message, there is nothing much to do about it d:p"
    fi
    bash_logging INFO "Running the command \"git add -A && git commit -m \"squash this commit later\" && git push"
    git add -A && git commit -m "squash this commit later" && git push
}
