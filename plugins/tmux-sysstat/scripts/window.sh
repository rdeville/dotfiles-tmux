#!/usr/bin/env bash

SCRIPTPATH="$(
  cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
  pwd -P
)"
SCRIPTNAME="${SCRIPTNAME:-$(basename "$0")}"
source "${SCRIPTPATH}/helpers.sh"

# script global variables
declare -A window

declare -A window_default
window_default[bg]="#8bc34a"
window_default[fg]="#ffffff"

window_default[current_bg]="#76FF03"
window_default[current_fg]="#000000"

window_default[format]="#I:#W"

window_default[order]="format"

_get_window_settings() {
  for idx in "${!window_default[@]}"; do
    window[${idx}]=$(get_tmux_option "@window_${idx}" "${window_default[${idx}]}")
  done

  window[separator_left]=$(get_tmux_option "@separator_left")
  window[separator_right]=$(get_tmux_option "@separator_left")
}

_compute_bg_fg() {
  local idx_name=$1
  local fg_clr=""
  local bg_clr=""

  if [[ "${window_state}" =~ "current" ]]; then
    fg_clr="${window[current_fg]}"
    bg_clr="${window[current_bg]}"
  else
    fg_clr="${window[fg]}"
    bg_clr="${window[bg]}"
  fi

  case "${idx_name}" in
  left)
    window_string+="#[bg=${bg_clr},fg=$(tmux show -gv @status_bg)]"
    window_string+="${window[separator_left]}"
    ;;
  right)
    window_string+=" #[fg=${bg_clr},bg=default]"
    window_string+="${window[separator_right]}"
    ;;
  *)
    window_string+="#[bg=${bg_clr},fg=${fg_clr}]"
    window_string+=" ${window[${idx_name}]}"
    ;;
  esac
}

main() {
  local window_string=""
  local window_state="$1"

  _get_window_settings

  _compute_bg_fg "left"
  for module in ${window[order]}; do
    _compute_bg_fg "${module}"
  done
  _compute_bg_fg "right"

  echo -e "${window_string}"
}

main "$@"
