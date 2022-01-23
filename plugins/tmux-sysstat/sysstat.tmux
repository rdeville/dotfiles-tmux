#!/usr/bin/env bash

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "${SCRIPTPATH}/scripts/helpers.sh"

declare -A module

module[cpu]="${SCRIPTPATH}/scripts/cpu.sh"
module[mem]="${SCRIPTPATH}/scripts/mem.sh"
module[net]="${SCRIPTPATH}/scripts/net.sh"
module[disk]="${SCRIPTPATH}/scripts/disk.sh"
module[date]="${SCRIPTPATH}/scripts/date.sh"
module[mode]="${SCRIPTPATH}/scripts/mode.sh"
module[session]="${SCRIPTPATH}/scripts/session.sh"
module[window]="${SCRIPTPATH}/scripts/window.sh"
module[uptime]="${SCRIPTPATH}/scripts/uptime.sh"
module[hostname]="${SCRIPTPATH}/scripts/hostname.sh"

main() {
  local nb_cols=$(( $(tput cols) / 2 - 1 ))
  update_tmux_option "status-right"
  update_tmux_option "status-left"
  update_tmux_option "status-left"
  update_tmux_option "window-status-format"
  update_tmux_option "window-status-current-format"

  if [[ "$@" =~ \-v ]]
  then
    for i_module in ${module[@]}
    do
      ${i_module}
    done
  fi

  #set_tmux_option "status-right-length" "${nb_cols}"
  #set_tmux_option "status-left-length" "${nb_cols}"
}

main "$@"
