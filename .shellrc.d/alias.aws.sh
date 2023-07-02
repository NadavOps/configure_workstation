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

aws_verify_profile() {
    local profile_name
    profile_name="${1:-default}"
    bash_logging DEBUG "Looking for aws profile: \"$profile_name\""
    aws configure list --profile "$profile_name" > /dev/null && return 0
    bash_logging ERROR "Profile \"$profile_name\" was not found. here are the avilable profiles"
    aws configure list-profiles
    return 1
}

aws_get_credentials_of_sso_profile() {
    local recent_token_file sso_token_dir access_token profile_name profile_account_id profile_sso_role profile_region credentials_properties
    sso_token_dir="$HOME/.aws/sso/cache"
    recent_token_file="$(ls -ltah "$sso_token_dir" | head -n 2 | tail -1 | awk '{print $9}')"
    access_token="$(cat $sso_token_dir/$recent_token_file | jq -r .accessToken)"
    profile_name="${1:-default}"
    aws_verify_profile "$profile_name" || return 1
    profile_account_id=$(aws configure get sso_account_id --profile "$profile_name")
    profile_sso_role=$(aws configure get sso_role_name --profile "$profile_name")
    profile_region=$(aws configure get sso_region --profile "$profile_name")
    credentials_properties=$(aws sso get-role-credentials --account-id "$profile_account_id" \
        --role-name "$profile_sso_role" \
        --access-token "$access_token" \
        --region "$profile_region")
    export AWS_ACCESS_KEY_ID=$(echo "$credentials_properties" | jq -r ".roleCredentials.accessKeyId")
    export AWS_SECRET_ACCESS_KEY=$(echo "$credentials_properties" | jq -r ".roleCredentials.secretAccessKey")
    export AWS_SESSION_TOKEN=$(echo "$credentials_properties" | jq -r ".roleCredentials.sessionToken")
    aws sts get-caller-identity
}

aws_get_credentials_of_role_assumption() {
    local role_arn profile_name credentials_properties
    role_arn="$1"
    profile_name="${2:-default}"
    role_session_name="${3:-debugging}"
    [[ -z "$role_arn" ]] && bash_logging ERROR "role_arn: \"$role_arn\" can't be empty (param #1)" && return 1
    aws_verify_profile "$profile_name" || return 1
    credentials_properties=$(aws sts assume-role \
        --role-arn "$role_arn" \
        --role-session-name "$role_session_name" \
        --profile "$profile_name") || return 1
    export AWS_ACCESS_KEY_ID=$(echo "$credentials_properties" | jq -r ".Credentials.AccessKeyId")
    export AWS_SECRET_ACCESS_KEY=$(echo "$credentials_properties" | jq -r ".Credentials.SecretAccessKey")
    export AWS_SESSION_TOKEN=$(echo "$credentials_properties" | jq -r ".Credentials.SessionToken")
    aws sts get-caller-identity
}
