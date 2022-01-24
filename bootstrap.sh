#!/usr/bin/env bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

declare -A NODES

NODES["${SCRIPTPATH}/tmux.conf"]="${HOME}/.tmux.conf"

source "${SCRIPTPATH}/lib/_tmux_log.sh"

for i_node in "${!NODES[@]}"
do
  src="${i_node}"
  dest="${NODES[${i_node}]}"

  if ! [[ -d "$(dirname "${dest}")" ]]
  then
    mkdir -p "$(dirname "${dest}")"
  fi

  if ! [[ -e "${src}" ]]
  then
    tmux_log "WARNING" "Bootstrap: Symlink source **${src/${HOME}/\~}** does not exists."
    tmux_log "WARNING" "Bootstrap: Will create symlink anyway as you may setup source later."
  fi

  if ! [[ -L "${dest}" ]]
  then
    tmux_log "INFO" "Bootstrap: Create symlink to **${dest/${HOME}/\~}**."
    ln -s "${src}" "${dest}"
  else
    tmux_log "INFO" "Bootstrap: Symlink to **${dest/${HOME}/\~}** already exists."
  fi
done

tpm_folder="${XDG_CONFIG_HOME:-"${HOME}/.config"}/tmux/plugins/tpm"
if [[ ! -e "${tpm_folder}" ]]
then
  printf "WARNING: Cannot found TPM (Tmux Plugin Manager) at default location: ${tpm_folder}"
  git clone https://github.com/tmux-plugins/tpm "${tpm_folder}"
fi


# Install TPM plugins.
# TPM requires running tmux server, as soon as `tmux start-server` does not work
# create dump __noop session in detached mode, and kill it when plugins are installed
printf "Install TPM plugins\n"
tmux new -d -s __noop >/dev/null 2>&1 || true
tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$(dirname ${tpm_folder})"
"${SCRIPTPATH}/plugins/tpm/bin/install_plugins" || true
tmux kill-session -t __noop >/dev/null 2>&1 || true

printf "OK: Completed\n"
