#!/usr/bin/env bash

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "${SCRIPTPATH}/helpers.sh"

# script global variables
declare -A mode_indicator

declare -A mode_indicator_default
mode_indicator_default[bg]='#424242'
mode_indicator_default[fg]='#ffffff'

mode_indicator_default[prefix]="WAIT"
mode_indicator_default[prefix_icon]="⏰"
mode_indicator_default[prefix_bg]=""
mode_indicator_default[prefix_fg]=""

mode_indicator_default[copy]="COPY"
mode_indicator_default[copy_icon]=" "
mode_indicator_default[copy_bg]=""
mode_indicator_default[copy_fg]=""

mode_indicator_default[sync]=" "
mode_indicator_default[sync_icon]="SYNC"
mode_indicator_default[sync_bg]=""
mode_indicator_default[sync_fg]=""

mode_indicator_default[empty]="TMUX"
mode_indicator_default[empty_icon]=" "
mode_indicator_default[empty_bg]=""
mode_indicator_default[empty_fg]=""

mode_indicator_default[order]="icon mode_indicator"

_get_mode_indicator_settings() {
  for idx in "${!mode_indicator_default[@]}"
  do
    mode_indicator[$idx]=$(get_tmux_option "@mode_indicator_${idx}" "${mode_indicator_default[$idx]}")
  done

  if [[ "${option}" == "status-right" ]]
  then
    mode_indicator[separator_right]=$(get_tmux_option "@separator_right")
  elif [[ "${option}" == "status-left" ]]
  then
    mode_indicator[separator_left]=$(get_tmux_option "@separator_left")
  fi
}

_get_mode_indicator_value() {
  local bg_clr=""
  local fg_clr=""
  for i_mode_indicator in "prefix" "copy" "sync" "empty"
  do
    if [[ -n "${mode_indicator["${i_mode_indicator}_bg"]}" ]]
    then
      bg_clr="${mode_indicator["${i_mode_indicator}_bg"]}"
    else
      bg_clr="${mode_indicator[bg]}"
    fi
    if [[ -n "${mode_indicator["${i_mode_indicator}_fg"]}" ]]
    then
      fg_clr="${mode_indicator["${i_mode_indicator}_fg"]}"
    else
      fg_clr="${mode_indicator[fg]}"
    fi
    mode_indicator["${i_mode_indicator}_style"]="#[bg=${bg_clr}]#[fg=${fg_clr}]"
  done

  mode_indicator[prompt]="#{?client_prefix,${mode_indicator[prefix]},#{?pane_in_mode_indicator,${mode_indicator[copy]},#{?pane_synchronized,${mode_indicator[sync]},${mode_indicator[empty]}}}}"
  mode_indicator[style]="#{?client_prefix,${mode_indicator[prefix_style]},#{?pane_in_mode_indicator,${mode_indicator[copy_style]},#{?pane_synchronized,${mode_indicator[sync_style]},${mode_indicator[empty_style]}}}}"
  mode_indicator[icon]="#{?client_prefix,${mode_indicator[prefix_icon]},#{?pane_in_mode_indicator,${mode_indicator[copy_icon]},#{?pane_synchronized,${mode_indicator[sync_icon]},${mode_indicator[empty_icon]}}}}"
}

_compute_bg_fg(){
  local idx_name=$1
  local fg_clr=""
  local bg_clr=""
  local gradient_color=""

  if [[  -z "${mode_indicator[$idx_name]}" && ! "${idx_name}" =~ mode_indicator|separator_left ]] \
    && [[ "${idx_name}" != end ]]
  then
    return 0
  fi

  case "${idx_name}" in
    style)
      mode_indicator_string+="${mode_indicator[style]}"
      ;;
    mode_indicator)
      #mode_indicator_string+="${mode_indicator[style]}"
      mode_indicator_string+=" ${mode_indicator[prompt]}"
      ;;
    separator_left)
      if ! tmux show-option -gqv "status-left" | grep -q -E "^#\(${SCRIPTPATH}/$(basename $0)" &> /dev/null
      then
        #mode_indicator_string+="${mode_indicator[style]}"
        mode_indicator_string+="${mode_indicator[${idx_name}]}"
      fi
      ;;
    separator_right)
      #mode_indicator_string+="${mode_indicator[style]}"
      mode_indicator_string+="${mode_indicator[${idx_name}]}"
      ;;
    end)
      tmp_style="${mode_indicator[style]}"
      tmp_style="${tmp_style//fg/tmp___fg}"
      tmp_style="${tmp_style//bg/fg}"
      tmp_style="${tmp_style//tmp___fg/bg}"
      mode_indicator_string+=" ${tmp_style}"
      ;;
    *)
      #mode_indicator_string+="${mode_indicator[style]}"
      mode_indicator_string+=" ${mode_indicator[$idx_name]}"
      ;;
  esac
}


main() {
  local mode_indicator_string=""
  local up_gradient_color=""
  local down_gradient_color=""

  _get_mode_indicator_settings
  _get_mode_indicator_value

  _compute_bg_fg "separator_left"
  _compute_bg_fg "separator_right"
  _compute_bg_fg "style"
  for i_module in ${mode_indicator[order]}
  do
    _compute_bg_fg "${i_module}"
  done
  _compute_bg_fg "end"

  echo -e "${mode_indicator_string}"
}

main "$@"

# ******************************************************************************
# VIM MODELINE
# vim: ft=sh: fdm=indent
# ******************************************************************************
