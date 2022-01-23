#!/usr/bin/env bash

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "${SCRIPTPATH}/helpers.sh"

# script global variables
declare -A session

declare -A session_default
session_default[bg]='#212121'
session_default[fg]='#ffffff'
session_default[separator_right]=''
session_default[separator_left]=''
session_default[session]='#S'

session_default[icon]=" "

session_default[order]="icon session"

_get_session_settings() {
  for idx in "${!session_default[@]}"
  do
    session[$idx]=$(get_tmux_option "@session_${idx}" "${session_default[$idx]}")
  done

  if [[ "${option}" == "status-right" ]]
  then
    session[separator_right]=$(get_tmux_option "@right_separator")
  elif [[ "${option}" == "status-left" ]]
  then
    session[separator_left]=$(get_tmux_option "@left_separator")
  fi
}

_compute_bg_fg(){
  local idx_name=$1
  local fg_clr=""
  local bg_clr=""
  local gradient_color=""

  if [[  -z "${session[$idx_name]}" && "${idx_name}" != "end" ]]
  then
    return 0
  fi

  case "${idx_name}" in
    session)
      session_string+="#[bg=${session[bg]},fg=${session[fg]}]"
      session_string+=" #S"
      ;;
    separator_left)
      if ! tmux show-option -gqv "status-left" | grep -q -E "^#\(${SCRIPTPATH}/$(basename $0)" &> /dev/null
      then
        session_string+="#[bg=${session[bg]}]"
        session_string+="${session[${idx_name}]}"
      fi
      ;;
    separator_right)
      session_string+="#[bg=${session[bg]}]"
      session_string+="${session[${idx_name}]}"
      ;;
    end)
      session_string+="#[fg=${session[bg]}]"
      ;;
    *)
      session_string+="#[bg=${session[bg]},fg=${session[fg]}]"
      session_string+=" ${session[$idx_name]}"
      ;;
  esac
}

main() {
  local option="$1"
  local session_string=""
  local up_gradient_color=""
  local down_gradient_color=""

  _get_session_settings

  _compute_bg_fg "separator_left"
  _compute_bg_fg "separator_right"
  for i_module in ${session[order]}
  do
    _compute_bg_fg "${i_module}"
  done
  _compute_bg_fg "end"

  echo -e "${session_string}"
}

main "$@"

# ******************************************************************************
# VIM sessionLINE
# vim: ft=sh: fdm=indent
# ******************************************************************************
