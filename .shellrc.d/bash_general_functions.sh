#!/bin/bash
verify_imported_functions_exists() {
    local functions_list function_name
    functions_list=( "$@" )
    for function_name in "${functions_list[@]}" ; do
        if ! type "$function_name" | grep -q function ; then
            bash_logging ERROR "function: \"$function_name\" was not found. export the function and re-try"
            exit 1
        fi
    done
}

verify_array() {
    local array
    array=("$@")

    if [[ -z ${array[@]} ]]; then
        bash_logging WARN "Array is empty: \"${array[@]}\", no arguments were supplied"
        return 1
    fi

    if ! declare -p array 2> /dev/null | grep -q '^declare \-a'; then
        bash_logging ERROR "Something is not right with the array: \"${array[@]}\""
        return 1
    fi 
}

verify_file() {
    local file_path
    file_path="$1"
    [[ ! -f "$file_path" ]] && \
    bash_logging ERROR "file_path: \"$file_path\" is not a file/ not exists" && return 1 || return 0
}

verify_dir() {
    local dir_path
    dir_path="$1"
    [[ ! -d "$dir_path" ]] && \
    bash_logging ERROR "dir_path: \"$dir_path\" is not a dir/ not exists" && return 1 || return 0
}

archive_file() {
    local source_path destination_path suffix filename
    source_path="$1"
    destination_path="$2"
    verify_file "$source_path" || return 1
    verify_dir "$destination_path" || return 1
    suffix=$(date -u "+%Y.%m.%d-%H:%M:%S") || return 1
    filename=$(echo "$source_path" | rev | cut -d "/" -f1 | rev)
    cp "$source_path" "$destination_path/$filename.$suffix" && \
    bash_logging INFO "archived source: \"$source_path\" to destination: \"$destination_path/$filename.$suffix\""
}