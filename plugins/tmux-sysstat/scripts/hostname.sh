#!/usr/bin/env bash

SCRIPTPATH="$(
  cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
  pwd -P
)"
SCRIPTNAME="${SCRIPTNAME:-$(basename "$0")}"
source "${SCRIPTPATH}/helpers.sh"

# script global variables
declare -A hostname

declare -A hostname_default
hostname_default[bg]="#fff176"
hostname_default[fg]="#212121"

hostname_default[icon]=" "

hostname_default[order]="icon value"

_get_hostname_settings() {
  for idx in "${!hostname_default[@]}"; do
    hostname[${idx}]=$(get_tmux_option "@hostname_${idx}" "${hostname_default[${idx}]}")
  done

  if [[ "${option}" == "status-right" ]]; then
    hostname[separator_right]=$(get_tmux_option "@separator_right")
  elif [[ "${option}" == "status-left" ]]; then
    hostname[separator_left]=$(get_tmux_option "@separator_left")
  fi
}

_get_hostname_value() {
  hostname[value]+="$(hostname)"
}

_compute_bg_fg() {
  local idx_name=$1

  case "${idx_name}" in
  status-left)
    hostname_string+="#[bg=${hostname[bg]}]"
    hostname_string+="${hostname[separator_left]}"
    ;;
  status-right)
    hostname_string+="#[fg=${hostname[bg]}]"
    hostname_string+="${hostname[separator_right]}"
    ;;
  end)
    if [[ "${option}" == "status-left" ]]; then
      hostname_string+=" #[bg=default]"
      if tmux show-option -gqv "status-left" |
        grep -q "${SCRIPTNAME} [a-z-]*)\$"; then
        hostname_string+="#[fg=${hostname[bg]}]"
        hostname_string+="${hostname[separator_left]}"
      fi
    fi
    ;;
  *)
    hostname_string+="#[bg=${hostname[bg]},fg=${hostname[fg]}]"
    hostname_string+=" ${hostname[${idx_name}]}"
    ;;
  esac
}

main() {
  local option=$1
  local hostname_string=""

  _get_hostname_settings
  _get_hostname_value

  _compute_bg_fg "${option}"
  for module in ${hostname[order]}; do
    _compute_bg_fg "${module}"
  done
  _compute_bg_fg "end"

  echo "${hostname_string}"
}

main "$@"
