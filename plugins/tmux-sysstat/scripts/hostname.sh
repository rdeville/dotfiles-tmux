#!/usr/bin/env bash

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "${SCRIPTPATH}/helpers.sh"

# script global variables
declare -A hostname

declare -A hostname_default
hostname_default[bg]='#636363'
hostname_default[fg]='#ffffff'

hostname_default[icon]=" "

hostname_default[order]="icon value"

_get_hostname_settings() {
  for idx in "${!hostname_default[@]}"
  do
    hostname[$idx]=$(get_tmux_option "@hostname_${idx}" "${hostname_default[$idx]}")
  done

  if [[ "${option}" == "status-right" ]]
  then
    hostname[separator_right]=$(get_tmux_option "@separator_right")
  elif [[ "${option}" == "status-left" ]]
  then
    hostname[separator_left]=$(get_tmux_option "@separator_left")
  fi
}

_get_hostname_value() {
  hostname[value]+="$(hostname)"
}

_compute_bg_fg(){
  local idx_name=$1
  local fg_clr=""
  local bg_clr=""
  local gradient_color=""

  if [[  -z "${hostname[$idx_name]}" && "${idx_name}" != "end" ]]
  then
    return 0
  fi

  case "${idx_name}" in
    separator_left)
      if ! tmux show-option -gqv "status-left" | grep -q -E "^#\(${SCRIPTPATH}/$(basename $0)" &> /dev/null
      then
        hostname_string+="#[bg=${hostname[bg]}]"
        hostname_string+="${hostname[${idx_name}]}"
      fi
      ;;
    separator_right)
      hostname_string+="#[fg=${hostname[bg]}]"
      hostname_string+="${hostname[${idx_name}]}"
      ;;
    end)
      hostname_string+="#[fg=${hostname[bg]}]"
      ;;
    *)
      hostname_string+="#[bg=${hostname[bg]},fg=${hostname[fg]}]"
      hostname_string+=" ${hostname[$idx_name]}"
      ;;
  esac
}

main() {
  local option=$1
  local hostname_string=""
  local up_gradient_color=""
  local down_gradient_color=""

  _get_hostname_settings
  _get_hostname_value

  _compute_bg_fg "separator_left"
  _compute_bg_fg "separator_right"
  for i_module in ${hostname[order]}
  do
    _compute_bg_fg "${i_module}"
  done
  _compute_bg_fg "end"

  echo -e "${hostname_string}"
}

main "$@"

# ******************************************************************************
# VIM hostnameLINE
# vim: ft=sh: fdm=indent
# ******************************************************************************
