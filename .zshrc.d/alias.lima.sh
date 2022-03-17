## Lima (examples at https://github.com/lima-vm/lima/tree/master/examples)
[[ $(command -v lima) ]] || return 0
lima_home="$HOME/.lima"
lima_engine_configuration="$lima_home/.engine_configuration"
docker_config="docker.yaml"
containerd_config="containerd.yaml"

alias lima="limactl"
alias lima_remove_engine_configuration="[[ ! -z $lima_engine_configuration ]] && [[ -d $lima_engine_configuration ]] && rm -f $lima_engine_configuration/* | xargs 'y'"

lima_docker_start() {
    local engine lima_home lima_engine_configuration
    engine="docker"
    lima_home="$HOME/.lima"
    lima_engine_configuration="$lima_home/.engine_configuration"
    lima list | grep -q "$engine" && lima start "$engine" && return 0
    lima start --name="$engine" "$lima_engine_configuration/$engine.yaml"
}

lima_containerd_start() {
    local engine lima_home lima_engine_configuration
    engine="containerd"
    lima_home="$HOME/.lima"
    lima_engine_configuration="$lima_home/.engine_configuration"
    lima list | grep -q "$engine" && lima start "$engine" && return 0
    lima start --name="$engine" "$lima_engine_configuration/$engine.yaml"
}

mkdir -p "$lima_engine_configuration"

[[ ! -f "$lima_engine_configuration/$docker_config" ]] && \
cat << EOF > "$lima_engine_configuration/$docker_config"
# https://github.com/lima-vm/lima/blob/master/examples/docker.yaml
images:
- location: "https://cloud-images.ubuntu.com/releases/21.10/release-20220201/ubuntu-21.10-server-cloudimg-amd64.img"
  arch: "x86_64"
  digest: "sha256:73fe1785c60edeb506f191affff0440abcc2de02420bb70865d51d0ff9b28223"
- location: "https://cloud-images.ubuntu.com/releases/21.10/release-20220201/ubuntu-21.10-server-cloudimg-arm64.img"
  arch: "aarch64"
  digest: "sha256:1b5b3fe616e1eea4176049d434a360344a7d471f799e151190f21b0a27f0b424"
- location: "https://cloud-images.ubuntu.com/releases/21.10/release/ubuntu-21.10-server-cloudimg-amd64.img"
  arch: "x86_64"
- location: "https://cloud-images.ubuntu.com/releases/21.10/release/ubuntu-21.10-server-cloudimg-arm64.img"
  arch: "aarch64"

cpus: 2
memory: 2GiB
disk: 70GiB

mounts:
- location: "$lima_home"
  writable: false
- location: "/tmp/lima"
  writable: true
containerd:
  system: false
  user: false
provision:
- mode: system
  # This script defines the host.docker.internal hostname when hostResolver is disabled.
  # It is also needed for lima 0.8.2 and earlier, which does not support hostResolver.hosts.
  # Names defined in /etc/hosts inside the VM are not resolved inside containers when
  # using the hostResolver; use hostResolver.hosts instead (requires lima 0.8.3 or later).
  script: |
    #!/bin/sh
    sed -i 's/host.lima.internal.*/host.lima.internal host.docker.internal/' /etc/hosts
- mode: system
  script: |
    #!/bin/bash
    set -eux -o pipefail
    command -v docker >/dev/null 2>&1 && exit 0
    export DEBIAN_FRONTEND=noninteractive
    curl -fsSL https://get.docker.com | sh
    # NOTE: you may remove the lines below, if you prefer to use rootful docker, not rootless
    systemctl disable --now docker
    apt-get install -y uidmap dbus-user-session
- mode: user
  script: |
    #!/bin/bash
    set -eux -o pipefail
    systemctl --user start dbus
    dockerd-rootless-setuptool.sh install
    docker context use rootless
probes:
- script: |
    #!/bin/bash
    set -eux -o pipefail
    if ! timeout 30s bash -c "until command -v docker >/dev/null 2>&1; do sleep 3; done"; then
      echo >&2 "docker is not installed yet"
      exit 1
    fi
    if ! timeout 30s bash -c "until pgrep rootlesskit; do sleep 3; done"; then
      echo >&2 "rootlesskit (used by rootless docker) is not running"
      exit 1
    fi
  hint: See "/var/log/cloud-init-output.log". in the guest
hostResolver:
  # hostResolver.hosts requires lima 0.8.3 or later. Names defined here will also
  # resolve inside containers, and not just inside the VM itself.
  hosts:
    host.docker.internal: host.lima.internal
portForwards:
- guestSocket: "/run/user/{{.UID}}/docker.sock"
  hostSocket: "{{.Dir}}/sock/docker.sock"
message: |
  To run "docker" on the host (assumes docker-cli is installed), run the following commands:
  ------
  docker context create lima --docker "host=unix://{{.Dir}}/sock/docker.sock"
  docker context use lima
  docker run hello-world
  ------
EOF

[[ ! -f "$lima_engine_configuration/$containerd_config" ]] && \
cat << EOF > "$lima_engine_configuration/$containerd_config"
# https://github.com/lima-vm/lima/blob/master/examples/default.yaml
images:
- location: "https://cloud-images.ubuntu.com/releases/21.10/release-20220201/ubuntu-21.10-server-cloudimg-amd64.img"
  arch: "x86_64"
  digest: "sha256:73fe1785c60edeb506f191affff0440abcc2de02420bb70865d51d0ff9b28223"
- location: "https://cloud-images.ubuntu.com/releases/21.10/release-20220201/ubuntu-21.10-server-cloudimg-arm64.img"
  arch: "aarch64"
  digest: "sha256:1b5b3fe616e1eea4176049d434a360344a7d471f799e151190f21b0a27f0b424"
- location: "https://cloud-images.ubuntu.com/releases/21.10/release/ubuntu-21.10-server-cloudimg-amd64.img"
  arch: "x86_64"
- location: "https://cloud-images.ubuntu.com/releases/21.10/release/ubuntu-21.10-server-cloudimg-arm64.img"
  arch: "aarch64"

cpus: 2
memory: 2GiB
disk: 70GiB

mounts:
- location: "$lima_home"
  writable: false
  sshfs:
    # Enabling the SSHFS cache will increase performance of the mounted filesystem, at
    # the cost of potentially not reflecting changes made on the host in a timely manner.
    # Warning: It looks like PHP filesystem access does not work correctly when
    # the cache is disabled.
    # Builtin default: true
    cache: null
    # SSHFS has an optional flag called 'follow_symlinks'. This allows mounts
    # to be properly resolved in the guest os and allow for access to the
    # contents of the symlink. As a result, symlinked files & folders on the Host
    # system will look and feel like regular files directories in the Guest OS.
    # Builtin default: false
    followSymlinks: null
- location: "/tmp/lima"
  writable: true

ssh:
  # A localhost port of the host. Forwarded to port 22 of the guest.
  # Builtin default: 0 (automatically assigned to a free port)
  # NOTE: when the instance name is "default", the builtin default value is set to
  # 60022 for backward compatibility.
  localPort: 0
  # Load ~/.ssh/*.pub in addition to $LIMA_HOME/_config/user.pub .
  # This option is useful when you want to use other SSH-based
  # applications such as rsync with the Lima instance.
  # If you have an insecure key under ~/.ssh, do not use this option.
  # Builtin default: true
  loadDotSSHPubKeys: null
  # Forward ssh agent into the instance.
  # Builtin default: false
  forwardAgent: null

containerd:
  # Enable system-wide (aka rootful)  containerd and its dependencies (BuildKit, Stargz Snapshotter)
  # Builtin default: false
  system: null
  # Enable user-scoped (aka rootless) containerd and its dependencies
  # Builtin default: true
  user: null

cpuType:
  # Builtin default: "cortex-a72" (or "host" when running on aarch64 host)
  aarch64: null
  # Builtin default: "qemu64" (or "host" when running on x86_64 host)
  x86_64: null

firmware:
  # Use legacy BIOS instead of UEFI. Ignored for aarch64.
  # Builtin default: false
  legacyBIOS: null

video:
  display: null

networks:

propagateProxyEnv: null

hostResolver:
  enabled: null
  ipv6: null
  hosts:
    # guest.name: 127.1.1.1
    # host.name: host.lima.internal
EOF

unset lima_home lima_engine_configuration docker_config containerd_config
