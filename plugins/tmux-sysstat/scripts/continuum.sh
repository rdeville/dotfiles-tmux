#!/usr/bin/env bash

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "${SCRIPTPATH}/helpers.sh"

# script global variables
declare -A continuum

declare -A continuum_default
continuum_default[bg]="#212121"
continuum_default[fg]="#ffffff"

continuum_default[icon]=" "
continuum_default[value]=""

continuum_default[order]="icon value"

_get_continuum_settings() {
  for idx in "${!continuum_default[@]}"
  do
    continuum[$idx]=$(get_tmux_option "@continuum_${idx}" "${continuum_default[$idx]}")
  done

  if [[ "${option}" == "status-right" ]]
  then
    continuum[separator_right]=$(get_tmux_option "@separator_right")
  elif [[ "${option}" == "status-left" ]]
  then
    continuum[separator_left]=$(get_tmux_option "@separator_left")
  fi
}

_get_continuum_value() {
  local continuum_value=""
  local continuum_status_script="${XDG_CONFIG_HOME:-${HOME}/.config}/tmux/plugins/tmux-continuum/scripts/continuum_status.sh"

  if [[ -f "${continuum_status_script}" ]]
  then
    continuum[value]="$(${continuum_status_script})"
  fi
}

_compute_bg_fg(){
  local idx_name=$1
  local fg_clr=""
  local bg_clr=""

  if [[  -z "${continuum[$idx_name]}" && "${idx_name}" != "end" ]]
  then
    return 0
  fi

  fg_clr="${continuum[fg]}"
  bg_clr="${continuum[bg]}"

  case "${idx_name}" in
    separator_left)
      if ! tmux show-option -gqv "status-left" | grep -q -E "^#\(${SCRIPTPATH}/$(basename $0)" &> /dev/null
      then
        continuum_string+="#[bg=${continuum[bg]}]"
        continuum_string+="${continuum[${idx_name}]}"
      fi
      ;;
    separator_right)
      continuum_string+="#[fg=${continuum[bg]}]"
      continuum_string+="${continuum[${idx_name}]}"
      ;;
    end)
      continuum_string+="#[fg=${continuum[bg]}]"
      ;;
    *)
      continuum_string+="#[bg=${bg_clr},fg=${fg_clr}]"
      continuum_string+=" ${continuum[$idx_name]}"
      ;;
  esac
}

main() {
  local option=$1
  local continuum_string=""

  _get_continuum_settings
  _get_continuum_value

  _compute_bg_fg "separator_left"
  _compute_bg_fg "separator_right"
  for i_module in ${continuum[order]}
  do
    _compute_bg_fg "${i_module}"
  done
  _compute_bg_fg "end"

  echo -e "${continuum_string}"
}

main "$@"

# ******************************************************************************
# VIM continuumLINE
# vim: ft=sh: fdm=indent
# ******************************************************************************