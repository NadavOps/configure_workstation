## docker
[[ $(command -v docker) ]] || return 0

[[ $(command -v lima) ]] || return 0

alias docker_context_current='docker context ls | grep "*"'
docker_context_lima() {
    local vm
    [[ -z "$1" ]] && vm="lima" || vm="$1"
    docker context inspect "$vm" &> /dev/null || docker context create "$vm" --docker "host=unix://$HOME/.$vm/docker/sock/docker.sock"
    docker context use "$vm"
}
