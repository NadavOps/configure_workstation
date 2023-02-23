## docker
[[ $(command -v docker) ]] || return 0

[[ $(command -v docker-buildx) ]] || return 0

docker_buildx() {
    docker_buildx_help()
    {
        bash_logging DEBUG "docker_buildx [-h](help) [-t](container_registry/container_repository:image_tag) [-f dockerfile_path]" 1>&2
        return
    }
    trap "unset -f docker_buildx_help" EXIT
    local OPTIND o h t f container_registry container_repository image_tag dockerfile_path
    while getopts "ht:f:" o; do
        case "${o}" in
            h)
                docker_buildx_help; return
                ;;
            t)
                t="${OPTARG}"
                ;;
            f)
                f="${OPTARG}"
                ;;
            *)
                docker_buildx_help; return
                ;;
        esac
    done
    container_registry=$(echo "$t" | cut -d "/" -f1)
    container_repository=$(echo "$t" | cut -d "/" -f2- | cut -d ":" -f1)
    image_tag=$(echo "$t" | cut -d ":" -f2)
    if [[ -z "$container_registry" ]] || [[ -z "$container_repository" ]] || [[ -z "$image_tag" ]]; then
        bash_logging ERROR """Wrong input:
            container_registry: \"$container_registry\", container_repository: \"$container_repository\". image_tag: \"$image_tag\""""
            docker_buildx_help
            return 1
    else
        bash_logging DEBUG """Tag input:
                    container_registry: \"$container_registry\", container_repository: \"$container_repository\". image_tag: \"$image_tag\""""
    fi
    if [[ -z "$f" ]]; then
        dockerfile_path="."
    else
        dockerfile_path="-f $f"
    fi
    bash_logging INFO """Run:
    docker buildx build \
        -t $container_registry/$container_repository:$image_tag \
        --platform \"linux/amd64\",\"linux/arm64/v8\" --push $dockerfile_path"""
}
