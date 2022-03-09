#!/bin/bash
verify_linux_package_manager() {
    if [[ $(command -v apt) ]]; then
        bash_logging INFO "\"apt\" package manager was found"
        return 0
    else
        bash_logging ERROR "The supported package manager for Linux is \"apt\" only, which was not found. terminating"
        return 1
    fi
}

verify_mac_package_manager() {
    if [[ $(command -v brew) ]]; then
        bash_logging INFO "\"brew\" package manager was found"
        return 0
    else
        bash_logging DEBUG "\"brew\" package manager was not found. Installing"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    fi   
}

verify_linux_package() {
    local package_name
    package_name="$1"
    bash_logging DEBUG "Verify linux package \"$package_name\""
    dpkg -s $package_name &> /dev/null && \
    (bash_logging INFO "Package: \"$package_name\" already installed" && return 0) || \
    (bash_logging WARN "Package: \"$package_name\" is not installed" && return 1)
}

install_repository() {
    local package_name install_repo gpg_key_url
    package_name="$1"
    install_repo="$2"
    gpg_key_url="$3"
    if [[ $gpg_key_url ]]; then
        bash_logging DEBUG "Adding gpg_key: $gpg_key_url and repo: $install_repo"
        sudo curl -s "$gpg_key_url" | sudo apt-key add - || return 1
        sudo echo "deb $install_repo" | sudo tee "/etc/apt/sources.list.d/$package_name.list"
        sudo apt-get update -y && \
        (bash_logging DEBUG "Repository for package: \"$package_name\" updated" && return 0) || \
        (bash_logging ERROR "Repository for package: \"$package_name\" failed. terminating" && return 1)
    # This was for when I thought I can install without gpg, might be usefull
    # elif [[ $install_repo ]]; then
    #     bash_logging DEBUG "Adding repo: $install_repo without gpg_key"
    #     echo "deb $install_repo" | sudo tee "/etc/apt/sources.list.d/$package_name.list"
    #     sudo apt-get update -y && \
    #     (bash_logging DEBUG "Repository for package: \"$package_name\" updated" && return 0) || \
    #     (bash_logging ERROR "Repository for package: \"$package_name\" failed. terminating" && exit 1)
    else
        bash_logging DEBUG "No gpg_key: $gpg_key_url or repo: $install_repo were supplied, continue to installation"
    fi
}

install_linux_package() {
    local package_name
    package_name="$1"
    bash_logging DEBUG "Installing linux package: \"$package_name\""
    sudo apt-get install -y "$package_name" && return 0 || return 1  
}

install_linux_packages_list() {
    local packages_list package_item package_name package_type install_repo gpg_key_url

    packages_list=("$@")

    verify_array "${packages_list[@]}"
    
    bash_logging DEBUG "Updating apt"
    sudo apt-get update -y

    for package_item in "${packages_list[@]}" ; do
        package_name=$(echo "$package_item" | awk -F "---" '{print $1}')
        package_type=$(echo "$package_item" | awk -F "---" '{print $2}' | tr "[[:lower:]]" "[[:upper:]]")
        [[ "$package_type" == "GUI" ]] && bash_logging WARN "This script doesn't support GUI installs for linux. \"package_type\" is: $package_type" && continue
        verify_linux_package "$package_name" && continue
        install_repo=$(echo "$package_item" | awk -F "---" '{print $3}')
        gpg_key_url=$(echo "$package_item" | awk -F "---" '{print $4}')
        install_repository "$package_name" "$install_repo" "$gpg_key_url" || exit 1
        install_linux_package "$package_name"
    done
}

verify_mac_package() {
    local package_name package_type verify_command brew_flag
    package_name="$1"
    package_type=$( echo "$2" | tr "[[:lower:]]" "[[:upper:]]" )
    if [[ $package_type == "CLI" ]]; then
        bash_logging DEBUG "Verify CLI mac package \"$package_name\""
        brew_flag="--formula"
    elif [[ $package_type == "GUI" ]]; then
        bash_logging DEBUG "Verify GUI mac package \"$package_name\""
        brew_flag="--cask"
    else
        bash_logging ERROR "Verifying mac package: \"$package_name\" failed. package_type: \"$package_type\" is not correct. terminating"
        exit 1
    fi
    verify_command="brew list $brew_flag | grep \"$package_name\$\" &> /dev/null && \
                    (bash_logging INFO \"Package: $package_name already installed\" && return 0) || \
                    (bash_logging WARN \"Package: $package_name is not installed\" && return 1)"
    eval "$verify_command"
}

install_mac_package() {
    local package_name package_type verify_command brew_flag
    package_name="$1"
    package_type="$2"
    if [[ $package_type == "CLI" ]]; then
        bash_logging DEBUG "Install CLI mac package \"$package_name\""
        brew_flag=""
    elif [[ $package_type == "GUI" ]]; then
        bash_logging DEBUG "Install GUI mac package \"$package_name\""
        brew_flag=" --cask"
    else
        bash_logging ERROR "Installing mac package failed. package_name: \"$package_name\", package_type: \"$package_type\". terminating"
        exit 1
    fi
    verify_command="brew install$brew_flag $package_name"
    bash_logging DEBUG "$verify_command"
    eval "$verify_command" && return 0
    bash_logging ERROR "Installing mac package failed. package_name: \"$package_name\", package_type: \"$package_type\". terminating" && exit 1
}

install_mac_packages_list() {
    local packages_list package_item package_name package_type

    packages_list=("$@")

    verify_array "${packages_list[@]}"

    for package_item in "${packages_list[@]}" ; do
        package_name=$(echo "$package_item" | awk -F "---" '{print $1}')
        package_type=$(echo "$package_item" | awk -F "---" '{print $2}' | tr "[[:lower:]]" "[[:upper:]]")
        verify_mac_package "$package_name" "$package_type" && continue
        install_mac_package "$package_name" "$package_type"
    done
}

bash_install_packages() {
    set -e
    verify_imported_functions_exists "bash_logging" "verify_array"
    set +e
    bash_logging DEBUG "Running from $0"
    local os_type packages_list
    packages_list=("$@")
    os_type=$(uname | tr "[[:upper:]]" "[[:lower:]]")
    if [[ $os_type == *linux* ]]; then
        bash_logging DEBUG "We in Linux. (os_type: \"$os_type\")"
        verify_linux_package_manager
        install_linux_packages_list "${packages_list[@]}"
    elif [[ $os_type == *darwin* ]]; then
        bash_logging DEBUG "We in Mac. (os_type: \"$os_type\")"
        verify_mac_package_manager
        install_mac_packages_list "${packages_list[@]}"
    else
        bash_logging ERROR "what is this OS? (os_type is $os_type)"
        exit 1
    fi
}

PACKAGES_LIST=("$@")
bash_install_packages "${PACKAGES_LIST[@]}"
# PACKAGES_PREREQUISITE=( "apt-transport-https"
#                         "ca-certificates"
#                         "curl" )
#              # package_name---install_repo---gpg_key
# PACKAGES_CLI=( "kubectl---https://apt.kubernetes.io/ kubernetes-xenial main---https://packages.cloud.google.com/apt/doc/apt-key.gpg"
#                 "helm---https://baltocdn.com/helm/stable/debian/ all main---https://baltocdn.com/helm/signing.asc"
#                 "jq"
#                 "shellcheck"
#                 "mysql-client" )
#              # unsupported for linux ATM
#              # install_name---filesystem_name
# PACKAGES_GUI=( "microsoft-edge"
#                "google-chrome"
#                "firefox"
#                "visual-studio-code"
#                "iterm2" )
# PACKAGES_MAC=( "lima"
#                "docker" )