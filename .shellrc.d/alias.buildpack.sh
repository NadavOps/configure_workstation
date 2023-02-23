## pack
[[ $(command -v pack) ]] || return 0
[[ $(command -v docker) ]] || return 0

# https://docs.docker.com/engine/reference/commandline/context_use/
pack_docker_context() {
    local docker_socket
    docker_socket=$(docker context ls | grep "\*" | awk '{print $4}')
    export DOCKER_HOST="$docker_socket"
}

pack_default_builder() {
    local builder_name
    if [[ -z "$1" ]]; then
        bash_logging WARN "simple builder used"
        builder_name="cnbs/sample-builder:bionic"
    else
        builder_name="$1"
    fi
    bash_logging INFO "Running: pack config default-builder $builder_name"
    pack config default-builder "$builder_name"
}
