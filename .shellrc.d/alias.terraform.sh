## Terraform
[[ $(command -v terraform) ]] || return 0

## Terraform aliases
terraform_version_swap() {
    local desired_version terraform_path terraform_path_stripped
    desired_version="$1"
    terraform_path=$(which terraform)
    terraform_path_stripped=$(echo $terraform_path | rev | cut -d "/" -f2- | rev)
    if [[ -z "$desired_version" ]]; then 
        bash_logging ERROR "Supply terraform version param"
        bash_logging WARN "Choose version suffix from the following:"
        ls -lah "$terraform_path_stripped" | grep "terraform" | grep -e "\d[.].*"
        return 1
    fi
    if [[ ! -L "$terraform_path" ]]; then
        bash_logging ERROR "Terraform \"$terraform_path\" is not a link. aborting"
        return 1
    fi
    if [[ ! -f $terraform_path.$desired_version ]]; then
        bash_logging ERROR "Terraform \"$terraform_path.$desired_version\" was not found"
        bash_logging WARN "Choose version suffix from the following:"
        ls -lah "$terraform_path_stripped" | grep "terraform" | grep -e "\d[.].*"
        return 1
    fi
    bash_logging WARN "Deleting sym link \"$terraform_path\" and relinking"
    rm -rf "$terraform_path"
    ln -s "$terraform_path.$desired_version" "$terraform_path"
    bash_logging INFO "Terraform version is now:"
    ls -lah "$terraform_path"
}