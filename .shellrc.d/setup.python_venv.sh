[[ $(command -v python3) ]] || return 0
if ! python3 -m venv --help &> /dev/null; then return 0; fi
[[ -d "$HOME/.virtualenvs" ]] || mkdir -p "$HOME/.virtualenvs"
[[ -d "$HOME/.virtualenvs/default" ]] || python3 -m venv "$HOME/.virtualenvs/default"
source "$HOME/.virtualenvs/default/bin/activate"
