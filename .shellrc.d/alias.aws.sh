[[ $(command -v aws) ]] || return 0

aws_ecr_login() {
    local aws_region
    aws_region="${AWS_REGION:-us-east-1}"
    if [[ -z "$AWS_ACCOUNT_ID" ]]; then
        bash_logging ERROR "To use aws_ecr_login the env variable \"AWS_ACCOUNT_ID\" needs to be set and it is now: \"$AWS_ACCOUNT_ID\""
        return 1
    else
        bash_logging DEBUG "\"AWS_ACCOUNT_ID\" is set to the account: \"$AWS_ACCOUNT_ID\""
        bash_logging DEBUG "\"AWS_REGION\" is set to the region: \"$aws_region\""
        bash_logging INFO "Attempt to login into $AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com in \"$aws_region\""
    fi
    aws ecr get-login-password --region "$aws_region" | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com"
}

aws_ecr_login_public() {
    local aws_region
    aws_region="${AWS_REGION:-us-east-1}"
    bash_logging DEBUG "\"AWS_REGION\" is set to the region: \"$aws_region\""
    bash_logging INFO "Attempt to login into public.ecr.aws in \"$aws_region\""
    aws ecr-public get-login-password --region "$aws_region" | docker login --username AWS --password-stdin public.ecr.aws
}
