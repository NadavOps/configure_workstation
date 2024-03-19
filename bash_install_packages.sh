#!/usr/bin/env bash
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

verify_mac_bash_version() {
    bash_major_version=$(bash -c 'echo "${BASH_VERSINFO[0]}"')
    if [[ "$bash_major_version" -ge "5" ]]; then
        bash_logging INFO "\"bash\" major version is: $bash_major_version"
    else
        bash_logging WARN "\"bash\" major version is: $bash_major_version. requires upgrade"
        brew install bash
    fi
}

install_url_package() {
    local url package_name saved_location
    url="$1"
    package_name="$2"
    saved_location="/usr/local/bin"
    [[ $(command -v curl) ]] && \
    bash_logging DEBUG "Downloading \"$package_name\" from \"$url\"" && \
    curl -s -L "$url" -o "$saved_location/$package_name" && \
    chmod +x "$saved_location/$package_name" && \
    bash_logging INFO "Downloaded \"$package_name\" from \"$url\" into \"$saved_location/$package_name\"" || \
    bash_logging ERROR "Downloading \"$package_name\" from \"$url\" failed. curl package might be missing"
}

verify_package_fast() {
    local package_name
    package_name="$1"
    bash_logging DEBUG "Verify package: \"$package_name\" fast without package manager"
    [[ $(command -v "$package_name") ]] && \
    bash_logging INFO "Package: \"$package_name\" already installed" && return 0
    bash_logging DEBUG "Package: \"$package_name\" was not verified fastly will attempt to verify with package manager" && return 1
}

verify_linux_package() {
    local package_name
    package_name="$1"
    verify_package_fast "$package_name" && return 0
    dpkg -s $package_name &> /dev/null && \
    bash_logging INFO "Package: \"$package_name\" already installed" && return 0 || \
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
    sudo apt-get install -y "$package_name" && return 0
    bash_logging ERROR "Installing linux package: \"$package_name\" failed." && return 1
}

install_linux_packages_list() {
    local packages_list package_item package_identifier package_name install_repo gpg_key_url

    packages_list=("$@")

    verify_array "${packages_list[@]}" || return 1
    
    bash_logging DEBUG "Updating apt"
    sudo apt-get update -y

    for package_item in "${packages_list[@]}" ; do
        package_identifier=$(echo "$package_item" | awk -F "---" '{print $1}')
        if echo "$package_identifier" | grep -i -e "^url$" >/dev/null; then
            package_name=$(echo "$package_item" | awk -F "---" '{print $2}')
            verify_linux_package "$package_name" && continue
            install_url_package "$package_identifier" "$package_name"
            continue
        elif echo $package_identifier | grep -i -e ^gui$ -e ^mac$ > /dev/null ; then
            package_name=$(echo "$package_item" | awk -F "---" '{print $2}')
            bash_logging ERROR "The package: \"$package_name\" identifier is: \"$package_identifier\". Not supported." && continue
        else
            package_name="$package_identifier"
            verify_linux_package "$package_name" && continue
            install_repo=$(echo "$package_item" | awk -F "---" '{print $2}')
            gpg_key_url=$(echo "$package_item" | awk -F "---" '{print $3}')
            install_repository "$package_name" "$install_repo" "$gpg_key_url" || exit 1
            install_linux_package "$package_name"
	fi
    done
}

verify_mac_package() {
    local package_name package_type verify_command brew_flag
    package_name="$1"
    verify_package_fast "$package_name" && return 0
    package_type="$( echo "$2" | tr "[[:lower:]]" "[[:upper:]]" )"
    if [[ $package_type == "GUI" ]]; then
        bash_logging DEBUG "Verify cask (GUI) mac package \"$package_name\""
        brew_flag="--cask"
    else
        bash_logging DEBUG "Verify regular (formula) mac package \"$package_name\""
        brew_flag="--formula"
    fi
    verify_command="brew list $brew_flag | grep \"$package_name\$\" &> /dev/null && \
                    (bash_logging INFO \"Package: $package_name already installed\" && return 0) || \
                    (bash_logging WARN \"Package: $package_name is not installed\" && return 1)"
    eval "$verify_command"
}

install_mac_package() {
    local package_name package_type brew_flag install_command
    package_name="$1"
    package_type="$( echo "$2" | tr "[[:lower:]]" "[[:upper:]]" )"
    if [[ $package_type == "GUI" ]]; then
        bash_logging DEBUG "Installing cask (GUI) mac package \"$package_name\""
        brew_flag=" --cask"
    else
        bash_logging DEBUG "Installing regular (formula) mac package \"$package_name\""
        brew_flag=""
    fi
    install_command="brew install$brew_flag $package_name"
    bash_logging DEBUG "$install_command"
    eval "$install_command" && return 0
    bash_logging ERROR "Installing mac package: \"$package_name\" failed. package_type: \"$package_type\"" && return 1
}

install_mac_packages_list() {
    local packages_list package_item package_identifier package_name package_type package_url

    packages_list=("$@")

    verify_array "${packages_list[@]}" || return 1
    for package_item in "${packages_list[@]}" ; do
        package_identifier=$(echo "$package_item" | awk -F "---" '{print $1}')
        if echo "$package_identifier" | grep -i -e "^url$" >/dev/null; then
            package_type=""
            package_name=$(echo "$package_item" | awk -F "---" '{print $2}')
            verify_mac_package "$package_name" "$package_type" && continue
            package_url=$(echo "$package_item" | awk -F "---" '{print $3}')
            install_url_package "$package_url" "$package_name"
            continue
        elif echo "$package_identifier" | grep -i -e "^gui$" >/dev/null; then
            package_type="$package_identifier"
            package_name=$(echo "$package_item" | awk -F "---" '{print $2}')
        elif echo "$package_identifier" | grep -i -e "^mac$" >/dev/null; then
            package_type=""
            package_name=$(echo "$package_item" | awk -F "---" '{print $2}')
        else
            package_type=""
            package_name="$package_identifier"
        fi
        verify_mac_package "$package_name" "$package_type" && continue
        install_mac_package "$package_name" "$package_type"
    done
}

bash_install_packages() {
    set -e
    verify_imported_functions_exists "bash_logging" "verify_array" "verify_file"
    set +e
    bash_logging DEBUG "Running from $0"
    local os_type packages_files_lists packages_file_list file_line packages_list_array
    packages_files_lists=("$@")
    for packages_file_list in "${packages_files_lists[@]}"; do
        verify_file "$packages_file_list" || return 1
    done
    while read -r file_line; do packages_list_array+=( "$file_line" ); done <<< $(sort -u <<< $(awk 1 "${packages_files_lists[@]}" | grep -v "#"))
    os_type=$(uname | tr "[[:upper:]]" "[[:lower:]]")
    if [[ $os_type == *linux* ]]; then
        bash_logging DEBUG "We in Linux. (os_type: \"$os_type\")"
        verify_linux_package_manager
        install_linux_packages_list "${packages_list_array[@]}"
    elif [[ $os_type == *darwin* ]]; then
        bash_logging DEBUG "We in Mac. (os_type: \"$os_type\")"
        verify_mac_package_manager
        verify_mac_bash_version
        install_mac_packages_list "${packages_list_array[@]}"
    else
        bash_logging ERROR "what is this OS? (os_type is $os_type)"
        exit 1
    fi
}


bash_install_packages "./packages_lists/packages.conf" "$@"
