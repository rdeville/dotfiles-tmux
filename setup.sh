#!/usr/bin/env bash
# """Setup script to install symlinks if specified
# """

# shellcheck disable=SC2034
SCRIPTPATH="$( cd -- "$(dirname "$0")" &>/dev/null || exit 1 ; pwd -P )"
SCRIPTNAME="$(basename "$0")"

init_setup(){
  local setup_file="/tmp/_setup.sh"
  if ping -q -c 1 -W 1 framagit.org &> /dev/null
  then
    # shellcheck disable=SC1090
    source <(curl -s https://framagit.org/-/snippets/7207/raw/main/_get_setup.sh)
  elif [[ -f "${setup_file}" ]]
  then
    echo -e "\e[1;32m[INFO]\e[0m\e[32m ${SCRIPTNAME}: Not able to ping \e[1;31mframagit.org, will source existing **${setup_file}**\e[0m"
    # shellcheck disable=SC1090
    source <(cat "${setup_file}")
  else
    echo -e "\e[1;31m[ERROR]\e[0m\e[31m ${SCRIPTNAME}: Not able to ping \e[1;31mframagit.org\e[0m"
    echo -e "\e[1;31m[ERROR]\e[0m\e[31m ${SCRIPTNAME}: And setup lib file ${setup_file} does not exists.\e[0m"
    echo -e "\e[1;31m[ERROR]\e[0m\e[31m ${SCRIPTNAME}: Logger not available, script will now exit\e[0m"
    exit 1
  fi
}

setup_tpm(){
  tpm_folder="${CONFIG_DIR}/tmux/plugins/tpm"
  if [[ ! -e "${tpm_folder}" ]]
  then
    _log "WARNING" "${SCRIPTNAME}: Cannot found TPM (Tmux Plugin Manager) at default location: ${tpm_folder}"
    git clone https://github.com/tmux-plugins/tpm "${tpm_folder}"
  fi
}


install_plugins(){
  # Install TPM plugins.
  # TPM requires running tmux server, as soon as `tmux start-server` does not work
  # create dump __noop session in detached mode, and kill it when plugins are installed
  _log "INFO" "${SCRIPTNAME}: Install TPM plugins"
  tmux new -d -s __noop >/dev/null 2>&1 || true
  tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$(dirname "${tpm_folder}")"
  "${SCRIPTPATH}/plugins/tpm/bin/install_plugins" || true
  tmux kill-session -t __noop >/dev/null 2>&1 || true
}

main(){
  local DEBUG_LEVEL="${SETUP_DEBUG_LEVEL:-"INFO"}"
  init_setup
  setup "LINKS" "PKGS" "CRONS"
  setup_tpm
  install_plugins
}

DATA_DIR="${XDG_DATA_HOME:-${HOME}/.local/share}"
CONFIG_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}"

declare -A LINKS
LINKS["${HOME}/.tmux.conf"]="${SCRIPTPATH}/tmux.conf"
# LINKS["<DEST>"]="<SRC>"

declare -A CRONS
# CRONS["<PATH|CMD>"]="<RECURRENCE>"

PKGS=(
#  "<PKGS_NAME>"
  "tmux"
)

main "$@"

# vim: ft=sh