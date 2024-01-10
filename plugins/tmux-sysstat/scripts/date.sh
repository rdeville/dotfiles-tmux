#!/usr/bin/env bash

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "${SCRIPTPATH}/helpers.sh"

# script global variables
declare -A date

declare -A date_default
date_default[bg]='#424242'
date_default[fg]='#ffffff'

date_default[icon]=''
date_default[format]='%a %d %b | %H:%M'

date_default[order]="icon format"

_get_date_settings() {
  for idx in "${!date_default[@]}"
  do
    date[$idx]=$(get_tmux_option "@date_${idx}" "${date_default[$idx]}")
  done

  if [[ "${option}" == "status-right" ]]
  then
    date[separator_right]=$(get_tmux_option "@separator_right")
  elif [[ "${option}" == "status-left" ]]
  then
    date[separator_left]=$(get_tmux_option "@separator_left")
  fi
}

_get_date_value(){
  date[value]=$(date +"${date[format]}")
}

_compute_bg_fg(){
  local idx_name=$1
  local fg_clr=""
  local bg_clr=""

  if [[  -z "${date[$idx_name]}" && "${idx_name}" != "end" ]]
  then
    return 0
  fi

  fg_clr="${date[fg]}"
  bg_clr="${date[bg]}"

  case "${idx_name}" in
    separator_left)
      if ! tmux show-option -gqv "status-left" | grep -q -E "^#\(${SCRIPTPATH}/$(basename $0)" &> /dev/null
      then
        date_string+="#[bg=${date[bg]}]"
        date_string+="${date[${idx_name}]}"
      fi
      ;;
    separator_right)
      date_string+="#[fg=${date[bg]}]"
      date_string+="${date[${idx_name}]}"
      ;;
    end)
      date_string+="#[fg=${date[bg]}]"
      ;;
    format)
      date_string+="#[fg=${fg_clr},bg=${bg_clr}]"
      date_string+=" ${date[value]}"
      ;;
    *)
      date_string+="#[fg=${fg_clr},bg=${bg_clr}]"
      date_string+=" ${date[$idx_name]}"
      ;;
  esac
}


main() {
  local option=$1
  local date_string=""
  local up_gradient_color=""
  local down_gradient_color=""

  _get_date_settings
  _get_date_value

  _compute_bg_fg "separator_left"
  _compute_bg_fg "separator_right"
  for i_module in ${date[order]}
  do
    _compute_bg_fg "${i_module}"
  done
  _compute_bg_fg "end"

  echo -e "${date_string}"
}

main "$@"

# ******************************************************************************
# VIM MODELINE
# vim: ft=sh: fdm=indent
# ******************************************************************************