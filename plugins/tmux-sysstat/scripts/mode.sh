#!/usr/bin/env bash

SCRIPTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "${SCRIPTPATH}/helpers.sh"

# script global variables
declare -A mode

declare -A mode_default
mode_default[bg]='#424242'
mode_default[fg]='#ffffff'
mode_default[separator_right]=''
mode_default[separator_left]=''

mode_default[prefix]="⏰WAIT"
mode_default[prefix_bg]=""
mode_default[prefix_fg]=""

mode_default[copy]=" COPY"
mode_default[copy_bg]=""
mode_default[copy_fg]=""

mode_default[sync]=" SYNC"
mode_default[sync_bg]=""
mode_default[sync_fg]=""

mode_default[empty]=" TMUX"
mode_default[empty_bg]=""
mode_default[empty_fg]=""

mode_default[custom]=""
mode_default[custom_bg]=""
mode_default[custom_fg]=""

mode_default[order]="mode"

_get_mode_settings() {
  for idx in "${!mode_default[@]}"
  do
    mode[$idx]=$(get_tmux_option "@mode_${idx}" "${mode_default[$idx]}")
  done

  if [[ "${option}" == "status-right" ]]
  then
    mode[separator_right]=$(get_tmux_option "@right_separator")
  elif [[ "${option}" == "status-left" ]]
  then
    mode[separator_left]=$(get_tmux_option "@left_separator")
  fi
}

_get_mode_value() {
  local bg_clr=""
  local fg_clr=""
  for i_mode in "prefix" "copy" "sync" "normal" "custom"
  do
    if [[ -n "${mode["${i_mode}_bg"]}" ]]
    then
      bg_clr="${mode["${i_mode}_bg"]}"
    else
      bg_clr="${mode[bg]}"
    fi
    if [[ -n "${mode["${i_mode}_fg"]}" ]]
    then
      fg_clr="${mode["${i_mode}_fg"]}"
    else
      fg_clr="${mode[fg]}"
    fi
    mode["${i_mode}_style"]="#[bg=${bg_clr}]#[fg=${fg_clr}]"
  done

  mode[prompt]="#{?#{!=:${mode[custom]},},${mode[custom]},#{?client_prefix,${mode[prefix]},#{?pane_in_mode,${mode[copy]},#{?pane_synchronized,${mode[sync]},${mode[empty]}}}}}"
  mode[style]="#{?#{!=:${mode[custom_style]},},${mode[custom_style]},#{?client_prefix,${mode[prefix_style]},#{?pane_in_mode,${mode[copy_style]},#{?pane_synchronized,${mode[sync_style]},${mode[empty_style]}}}}}"
}

_compute_bg_fg(){
  local idx_name=$1
  local fg_clr=""
  local bg_clr=""
  local gradient_color=""

  if [[  -z "${mode[$idx_name]}" && ! "${idx_name}" =~ mode|separator_left ]] \
    && [[ "${idx_name}" != end ]]
  then
    return 0
  fi

  case "${idx_name}" in
    mode)
      mode_string+="${mode[style]}"
      mode_string+=" ${mode[prompt]}"
      ;;
    separator_left)
      if ! tmux show-option -gqv "status-left" | grep -q -E "^#\(${SCRIPTPATH}/$(basename $0)" &> /dev/null
      then
        mode_string+="#[bg=${mode[bg]}]"
        mode_string+="${mode[${idx_name}]}"
      fi
      ;;
    separator_right)
      mode_string+="#[bg=${mode[bg]}]"
      mode_string+="${mode[${idx_name}]}"
      ;;
    end)
      mode_string+="#[fg=${mode[bg]}]"
      ;;

    separator_*)
      new_style="$(echo "${mode[style]}" \
        | sed -e "s|#\[fg=#[0-9A-Fa-f]\{3,6\}\]||g"
      )"
      new_style=${new_style//bg=/fg=}
      mode_string+="${new_style}"
      mode_string+="${mode[${idx_name}]}"
      ;;
    *)
      mode_string+="${mode[style]}"
      mode_string+="${mode[$idx_name]}"
      ;;
  esac
}


main() {
  local mode_string=""
  local up_gradient_color=""
  local down_gradient_color=""

  _get_mode_settings
  _get_mode_value

  _compute_bg_fg "separator_left"
  _compute_bg_fg "separator_right"
  for i_module in ${mode[order]}
  do
    _compute_bg_fg "${i_module}"
  done
  _compute_bg_fg "end"

  echo -e "${mode_string}"
}

main "$@"

# ******************************************************************************
# VIM MODELINE
# vim: ft=sh: fdm=indent
# ******************************************************************************
