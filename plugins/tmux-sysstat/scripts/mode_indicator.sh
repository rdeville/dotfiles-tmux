#!/usr/bin/env bash

SCRIPTPATH="$(
  cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
  pwd -P
)"
SCRIPTNAME="${SCRIPTNAME:-$(basename "$0")}"
source "${SCRIPTPATH}/helpers.sh"

# script global variables
declare -A mode_indicator

declare -A mode_indicator_default
mode_indicator_default[bg]="#424242"
mode_indicator_default[fg]="#ffffff"

mode_indicator_default[wait]="WAIT"
mode_indicator_default[wait_icon]="󰀡 "
mode_indicator_default[wait_bg]="#3F51B5"
mode_indicator_default[wait_fg]="#fafafa"

mode_indicator_default[copy]="COPY"
mode_indicator_default[copy_icon]=" "
mode_indicator_default[copy_bg]="#ffeb3b"
mode_indicator_default[copy_fg]="#212121"

mode_indicator_default[sync]=" "
mode_indicator_default[sync_icon]="SYNC"
mode_indicator_default[sync_bg]="#ff5722"
mode_indicator_default[sync_fg]="#fafafa"

mode_indicator_default[empty]="TMUX"
mode_indicator_default[empty_icon]=" "
mode_indicator_default[empty_bg]="#cddc39"
mode_indicator_default[empty_fg]="#212121"

mode_indicator_default[order]="icon text"

_get_mode_indicator_settings() {
  for idx in "${!mode_indicator_default[@]}"; do
    mode_indicator[${idx}]=$(get_tmux_option "@mode_indicator_${idx}" "${mode_indicator_default[${idx}]}")
  done

  if [[ "${option}" == "status-right" ]]; then
    mode_indicator[separator_right]=$(get_tmux_option "@separator_right")
  elif [[ "${option}" == "status-left" ]]; then
    mode_indicator[separator_left]=$(get_tmux_option "@separator_left")
  fi
}

_get_mode_indicator_value() {
  local bg_clr=""
  local fg_clr=""
  for indicator in "wait" "copy" "sync" "empty"; do
    bg_clr="${mode_indicator["${indicator}_bg"]:-${mode_indicator[bg]}}"
    fg_clr="${mode_indicator["${indicator}_fg"]:-${mode_indicator[fg]}}"
    mode_indicator["${indicator}_style_first"]="#[bg=${bg_clr}]#[fg=default]"
    mode_indicator["${indicator}_style"]="#[bg=${bg_clr}]#[fg=${fg_clr}]"
    mode_indicator["${indicator}_style_end"]="#[fg=${bg_clr}]#[bg=default]"
  done

  mode_indicator[prompt]="#{?client_prefix,${mode_indicator[wait]},#{?pane_in_mode,${mode_indicator[copy]},#{?pane_synchronized,${mode_indicator[sync]},${mode_indicator[empty]}}}}"
  mode_indicator[style_first]="#{?client_prefix,${mode_indicator[wait_style_first]},#{?pane_in_mode,${mode_indicator[copy_style_first]},#{?pane_synchronized,${mode_indicator[sync_style_first]},${mode_indicator[empty_style_first]}}}}"
  mode_indicator[style]="#{?client_prefix,${mode_indicator[wait_style]},#{?pane_in_mode,${mode_indicator[copy_style]},#{?pane_synchronized,${mode_indicator[sync_style]},${mode_indicator[empty_style]}}}}"
  mode_indicator[style_end]="#{?client_prefix,${mode_indicator[wait_style_end]},#{?pane_in_mode,${mode_indicator[copy_style_end]},#{?pane_synchronized,${mode_indicator[sync_style_end]},${mode_indicator[empty_style_end]}}}}"
  mode_indicator[icon]="#{?client_prefix,${mode_indicator[wait_icon]},#{?pane_in_mode,${mode_indicator[copy_icon]},#{?pane_synchronized,${mode_indicator[sync_icon]},${mode_indicator[empty_icon]}}}}"
}

_compute_bg_fg() {
  local idx_name=$1
  local fg_clr=""
  local bg_clr=""

  case "${idx_name}" in
  status-left)
    mode_indicator_string+="${mode_indicator[style_first]}"
    mode_indicator_string+="${mode_indicator[separator_left]}"
    mode_indicator_string+="${mode_indicator[style]}"
    ;;
  status-right)
    mode_indicator_string+="${mode_indicator[style]}"
    mode_indicator_string+="${mode_indicator[separator_right]}"
    ;;
  text)
    mode_indicator_string+=" ${mode_indicator[prompt]}"
    ;;
  icon)
    mode_indicator_string+=" ${mode_indicator[icon]}"
    ;;
  end)
    if [[ "${option}" == "status-left" ]]; then
      mode_indicator_string+=" #[bg=default]"
      if tmux show-option -gqv "status-left" |
        grep -q "${SCRIPTNAME} [a-z-]*)\$"; then
        mode_indicator_string+="#[fg=${mode_indicator[bg]}]"
        mode_indicator_string+="${mode_indicator[separator_left]}"
      fi
    fi
    mode_indicator_string+="${mode_indicator[style_end]}"
    ;;
  esac
}

main() {
  local option="$1"
  local mode_indicator_string=""

  _get_mode_indicator_settings
  _get_mode_indicator_value

  _compute_bg_fg "${option}"
  for module in ${mode_indicator[order]}; do
    _compute_bg_fg "${module}"
  done
  _compute_bg_fg "end"

  echo -e "${mode_indicator_string}"
}

main "$@"
