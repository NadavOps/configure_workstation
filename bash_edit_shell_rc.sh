#!/bin/bash
create_rc_dirs() {
    local current_rc_file shellrc_d_directories shellrc_directory shellrc_file archive_directory dest_shellrc_file unique_flow
    current_rc_file="$1"
    archive_directory="$2"
    unique_flow="$3"
    if [[ "$unique_flow" == "unique_flow" ]]; then
        shellrc_d_directories=( "$current_rc_file.d" )
    else
        shellrc_d_directories=( ".shellrc.d" "$current_rc_file.d" )
    fi
    for shellrc_directory in "${shellrc_d_directories[@]}"; do
        mkdir -p "$HOME/$shellrc_directory" && bash_logging DEBUG "Creating dir \"$HOME/$shellrc_directory\" if not exist"
        for shellrc_file in $(ls $shellrc_directory); do
            dest_shellrc_file="$HOME/$shellrc_directory/$shellrc_file"
            verify_file "$dest_shellrc_file" 2> /dev/null && \
            bash_logging DEBUG "The file: \"$dest_shellrc_file\" already exist, will try to archive first" && \
            archive_file "$dest_shellrc_file" "$archive_directory"
            cp "$shellrc_directory/$shellrc_file" "$dest_shellrc_file" && \
            bash_logging DEBUG "Copy \"$shellrc_file\" to \"$HOME/$shellrc_directory/$shellrc_file\""
        done
    done
}

update_rc_file() {
    local current_rc_file archive_directory shell_rc_configurations_files shell_rc_configuration_file shell_rc_basename enrich_directory enrich_file
    current_rc_file="$HOME/$1"
    archive_directory="$2"
    shift 2
    shell_rc_configurations_files=("$@")
    archive_file "$current_rc_file" "$archive_directory" || return 1
    enrich_directory="./shellrc_enrich"
    verify_dir "$enrich_directory" || return 1

    verify_array "${shell_rc_configurations_files[@]}" && \
    for shell_rc_configuration_file in "${shell_rc_configurations_files[@]}"; do
        shell_rc_basename=$(basename "$shell_rc_configuration_file")
        bash_logging DEBUG "copy additional $shell_rc_configuration_file to $enrich_directory/ignore_me_git.$shell_rc_basename"
        cp "$shell_rc_configuration_file" "$enrich_directory/ignore_me_git.$shell_rc_basename"
    done || bash_logging DEBUG "additional were not supplied"

    echo "" > "$current_rc_file" && bash_logging WARN "Editing \"$current_rc_file\". (os_type: \"$os_type\")"

    for enrich_file in $(ls $enrich_directory); do
        cat "$enrich_directory/$enrich_file" >> "$current_rc_file" && \
        bash_logging INFO "Added \"$enrich_directory/$enrich_file\" into the running rc file: \"$current_rc_file\"" || \
        bash_logging ERROR "Failed to add \"$enrich_directory/$enrich_file\" into the running rc file: \"$current_rc_file\""
    done
}

bash_edit_shell_rc() {
    set -e
    verify_imported_functions_exists "bash_logging" "verify_array" "archive_file" "verify_file" "verify_dir"
    set +e
    bash_logging DEBUG "Running from $0"
    local shell_rc_configurations_files shell_rc_configuration_file os_type archive_directory current_rc_file
    shell_rc_configurations_files=("$@")
    verify_array "${shell_rc_configurations_files[@]}" && \
    for shell_rc_configuration_file in "${shell_rc_configurations_files[@]}"; do verify_file "$shell_rc_configuration_file" || return 1; done || \
    bash_logging INFO "Additional configrations were not supplied, configuring with the built in configuration only"
    archive_directory="$HOME/archive"
    mkdir -p "$archive_directory"
    os_type=$(uname | tr "[[:upper:]]" "[[:lower:]]")
    if [[ $os_type == *linux* || $os_type == *darwin* ]]; then
        current_rc_file=".bashrc"
        verify_file "$HOME/$current_rc_file" || touch "$HOME/$current_rc_file"
        create_rc_dirs "$current_rc_file" "$archive_directory"
        update_rc_file "$current_rc_file" "$archive_directory" "${shell_rc_configurations_files[@]}" || exit 1
    fi
    if [[ $os_type == *darwin* ]]; then
        current_rc_file=".zshrc"
        verify_file "$HOME/$current_rc_file" || touch "$HOME/$current_rc_file"
        create_rc_dirs "$current_rc_file" "$archive_directory" "unique_flow"
        update_rc_file "$current_rc_file" "$archive_directory" "${shell_rc_configurations_files[@]}" || exit 1
    fi
    if [[ $os_type != *linux* && $os_type != *darwin* ]]; then
        bash_logging ERROR "what is this OS? (os_type is $os_type)"
        exit 1
    fi
}

bash_edit_shell_rc "$@"
