#!/usr/bin/env bash

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "${SCRIPTPATH}/helpers.sh"

# script global variables
declare -A window

declare -A window_default
window_default[bg]='#000000'
window_default[fg]='#ffffff'

window_default[current_bg]='#00ff00'
window_default[current_fg]='#000000'

window_default[format]='#I:#W'

window_default[order]='format'

_get_window_settings() {
  for idx in "${!window_default[@]}"
  do
    window[$idx]=$(get_tmux_option "@window_${idx}" "${window_default[$idx]}")
  done

  window[separator_left]=$(get_tmux_option "@separator_left")
  window[separator_right]=$(get_tmux_option "@separator_left")
}

_compute_bg_fg(){
  local idx_name=$1
  local fg_clr=""
  local bg_clr=""
  local gradient_color=""

  if [[  -z "${window[$idx_name]}" && "${idx_name}" != "end" ]]
  then
    return 0
  fi

  if [[ "${window_state}" =~ current ]]
  then
    fg_clr="${window[current_fg]}"
    bg_clr="${window[current_bg]}"
  else
    fg_clr="${window[fg]}"
    bg_clr="${window[bg]}"
  fi

  case "${idx_name}" in
    separator_left)
      if ! tmux show-option -gqv "status-left" | grep -q -E "^#\(${SCRIPTPATH}/$(basename $0)" &> /dev/null
      then
        window_string+="#[bg=${bg_clr},fg=${window[bg]}]"
        window_string+="${window[${idx_name}]}"
      fi
      ;;
    separator_right)
      window_string+="#[bg=${window[bg]},fg=${bg_clr}]"
      window_string+="${window[${idx_name}]}"
      ;;
    end)
      window_string+=" #[bg=${bg_clr},fg=${fg_clr}]"
      ;;
    *)
      window_string+="#[bg=${bg_clr},fg=${fg_clr}]"
      window_string+=" ${window[$idx_name]}"
      ;;
  esac
}

main() {
  local window_string=""
  local window_state="$1"
  local up_gradient_color=""
  local down_gradient_color=""

  _get_window_settings

  _compute_bg_fg "separator_left"
  for i_module in ${window[order]}
  do
    _compute_bg_fg "${i_module}"
  done
  _compute_bg_fg "end"
  _compute_bg_fg "separator_right"

  echo -e "${window_string}"

}

main "$@"

# ******************************************************************************
# VIM windowLINE
# vim: ft=sh: fdm=indent
# ******************************************************************************

