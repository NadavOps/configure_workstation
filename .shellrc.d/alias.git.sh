## Git
[[ $(command -v git) ]] || return 0

git_commit_all() (
    git_commit_all_help() {
        bash_logging DEBUG "git_commit_all \\
            [-p](pull_first) \\
            [-m][commit message] \\
            [-c][commit hash] \\
            [-r](revert + fixup commit) \\
            [-s](push_sensitive_branch) \\
            [-h](help)" 1>&2
    }

    git_commit_all_run_command() {
        local command
        command="$1"
        bash_logging DEBUG "Running the command \"$command\""
        if ! eval "$command"; then bash_logging ERROR "The command \"$command\" failed (status code: $?)"; return 1; fi
    }

    git_commit_all_commit_message() {
        local commit_message commit_hash revert_commit_enable
        commit_message="$1"
        commit_hash="$2"
        revert_commit_enable="$3"
        if [[ -n "$commit_message" ]]; then
            git_commit_all_run_command "git commit -m \"$commit_message\"" || return 1
        else
            if [[ -z "$commit_hash" ]]; then
                commit_hash=$(git rev-parse HEAD)
            fi
            if [[ -n "$revert_commit_enable" ]]; then
                git_commit_all_run_command "git revert --no-commit $commit_hash" || return 1
                git_commit_all_run_command "git commit --fixup $commit_hash" || return 1
            else
                git_commit_all_run_command "git commit --fixup $commit_hash" || return 1
                # git_commit_all_run_command "git commit -m \"fixup! $commit_hash\"" || return 1
            fi
        fi
    }

    local o h p m c r s
    while getopts "hpm:c:rs" o; do
        case "$o" in
            h) git_commit_all_help; return 0;;
            p) p="--pull_first";;
            m) m="${OPTARG}";;
            c) c="${OPTARG}";;
            r) r="--revert_fixup_commit";;
            s) s="--push_sensitive_branch";;
            *) git_commit_all_help; return 1;;
        esac
    done

    if [[ -n "$m" && -n "$c" ]]; then
        git_commit_all_help
        bash_logging ERROR "Pick either to commit with message or to fixup a specific commit, dont provide both -m and -c"
        return 1
    fi

    if [[ -n "$r" && -z "$c" ]]; then
        git_commit_all_help
        bash_logging ERROR "Revert commit needs a commit hash. -r flag needs to be passed with -c flag"
        return 1
    fi

    local branch_name default_remote_branch_name status_code
    if ! git rev-parse --git-dir &> /dev/null; then bash_logging ERROR "$(pwd) is not a git directory" && return 1; fi
    branch_name=$(git rev-parse --abbrev-ref HEAD)
    default_remote_branch_name=$(git rev-parse --abbrev-ref refs/remotes/origin/HEAD 2> /dev/null | rev | cut -d "/" -f1 | rev)

    if [[ "$p" == "--pull_first" ]]; then git_commit_all_run_command "git pull" || return 1; fi

    if [[ -n "$r" ]]; then
        bash_logging INFO "Making a revert fixup commit"
        git_commit_all_commit_message "$m" "$c" "$r" || return 1
    elif [[ -z "$(git status --porcelain)" ]]; then
        bash_logging INFO "Working tree is clean, nothing to add or commit"        
    elif [[ -n "$(git diff --cached --exit-code)" ]]; then
        git_commit_all_commit_message "$m" "$c" || return 1
    # elif [[ -n "$(git diff --exit-code)" ]]; then
    else
        git_commit_all_run_command "git add -A" || return 1
        git_commit_all_commit_message "$m" "$c" || return 1
    fi

    if [[ "$s" != "--push_sensitive_branch" ]]; then
        if [[ "$branch_name" == "main" || "$branch_name" == "master" || "$branch_name" == "$default_remote_branch_name" ]]; then
            git_commit_all_help
            bash_logging ERROR "Branch \"$branch_name\" is sensitive."
            return 1
        fi
    else
        if [[ "$branch_name" == "main" || "$branch_name" == "master" || "$branch_name" == "$default_remote_branch_name" ]]; then
            bash_logging WARN "Branch \"$branch_name\" is sensitive. Pushing as \"$s\" was supplied"
        fi
    fi
    git push

    status_code=$?
    if [[ "$status_code" -eq 128 ]]; then
        bash_logging WARN "\"branch_name\" might not exist, should we run:
                    git push --set-upstream origin $branch_name
                    any key to continue, CTRL+C to quit"
        read
        git push --set-upstream origin "$branch_name"
    elif [[ "$status_code" -eq 1 ]]; then
        bash_logging DEBUG "When local does not match remote fail is expected"
        bash_logging WARN "Should we unstage with:
                              git reset HEAD^
                              any key to continue, CTRL+C to quit"
        read
        git reset HEAD^
        bash_logging INFO "The function support pulling first with \"-p\""
    fi
)

git_rebase_autosquash() {
    local commit_hash branch_name default_remote_branch_name branching_point_commit
    commit_hash="$1"
    branch_name=$(git rev-parse --abbrev-ref HEAD)
    default_remote_branch_name=$(git rev-parse --abbrev-ref refs/remotes/origin/HEAD 2> /dev/null | rev | cut -d "/" -f1 | rev)
    if [[ -n "$commit_hash" ]]; then
        git rebase -i --autosquash "$commit_hash"
    elif [[ "$branch_name" == "$default_remote_branch_name" ]]; then
        bash_logging ERROR "Rebasing in \"$default_remote_branch_name\" branch requires explicit commit hash."
        git_log
        return 1
    else
        branching_point_commit=$(git merge-base "$branch_name" "$default_remote_branch_name")
        bash_logging DEBUG "Rebase on $branching_point_commit"
        git rebase -i --autosquash $branching_point_commit
    fi
}

git_log() {
    local number_of_commits
    number_of_commits="$1"
    git log --pretty=format:"%C(auto)%h %ad %an %d %s" --date short --graph -n ${1-10}
}
