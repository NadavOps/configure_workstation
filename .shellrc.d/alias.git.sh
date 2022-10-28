## Git
[[ $(command -v git) ]] || exit 0

## Git aliases
git_commit_all()
{
    git_commit_help() { bash_logging DEBUG "git_commit_all [-h](help) [-f](force) [-m cusomt_commit_message] [-p](pull first)" 1>&2; return }
    local OPTIND o h f m p
    while getopts "hfm:p" o; do
        case "${o}" in
            h)
                git_commit_help; unset -f git_commit_help; return
                ;;
            f)
                f="--force"
                ;;
            m)
                m="${OPTARG}"
                ;;
            p)
                p="--pull_first"
                ;;
            *)
                git_commit_help; unset -f git_commit_help; return
                ;;
        esac
    done
    if [[ "$p" == "--pull_first" ]]; then git pull; fi
    if [[ -z "$m" ]]; then m="squash this commit later"; fi
    shift $((OPTIND-1))

    local branch_name
    if ! git rev-parse --git-dir &> /dev/null; then bash_logging ERROR "$(pwd) is not a git directory" && return 1; fi
    branch_name=$(git rev-parse --abbrev-ref HEAD)
    if [[ $branch_name == "main" || $branch_name == "master" ]] && [[ $f != "--force" ]]; then
        bash_logging ERROR "Branch \"$branch_name\" is sensitive. add -f to push anyway"
        return 1
    fi
    if [[ $branch_name == "main" || $branch_name == "master" ]] && [[ $f == "--force" ]]; then
        bash_logging WARN "Pushing with "$f" to \"$branch_name\" branch"
    fi
    bash_logging DEBUG "Running the command:
                               git add -A && git commit -m \"$m\" && git push"
    git add -A && git commit -m "$m" && git push
    if [[ "$?" -eq 128 ]]; then
        bash_logging WARN "\"branch_name\" might not exist, should we run:
                    git push --set-upstream origin $branch_name
                    any key to continue, CTRL+C to quit"
        read
        git push --set-upstream origin "$branch_name"
    fi
}
