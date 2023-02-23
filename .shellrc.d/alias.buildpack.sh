## pack
[[ $(command -v pack) ]] || return 0
[[ $(command -v docker) ]] || return 0

pack_set_default_docker_context() {
    local docker_socket
    docker_socket=$(docker context ls | grep "\*" | awk '{print $3}')
    export DOCKER_HOST="$docker_socket"
}