#!/usr/bin/env bash

SCRIPTPATH="$(
  cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
  pwd -P
)"
SCRIPTNAME="${SCRIPTNAME:-$(basename "$0")}"
source "${SCRIPTPATH}/helpers.sh"

# script global variables
declare -A uptime

declare -A uptime_default
uptime_default[bg]="#636363"
uptime_default[fg]="#ffffff"

uptime_default[icon]=" "

uptime_default[order]="icon value"

_get_uptime_settings() {
  for idx in "${!uptime_default[@]}"; do
    uptime[${idx}]=$(get_tmux_option "@uptime_${idx}" "${uptime_default[${idx}]}")
  done

  if [[ "${option}" == "status-right" ]]; then
    uptime[separator_right]=$(get_tmux_option "@separator_right")
  elif [[ "${option}" == "status-left" ]]; then
    uptime[separator_left]=$(get_tmux_option "@separator_left")
  fi
}

_get_uptime_value() {
  # From:
  # https://unix.stackexchange.com/questions/27013/displaying-seconds-as-days-hours-mins-seconds
  local seconds
  local days
  local hours
  local minutes

  seconds=$(awk '{printf("%d",$1+.5)}' </proc/uptime)
  days=$((seconds / 60 / 60 / 24))
  hours=$((seconds / 60 / 60 % 24))
  minutes=$((seconds / 60 % 60))

  ((days > 0)) && uptime[value]="${days} Days "
  uptime[value]+="$(printf "%02d:%02d" "${hours}" "${minutes}")"
}

_compute_bg_fg() {
  local idx_name=$1

  fg_clr="${uptime[fg]}"
  bg_clr="${uptime[bg]}"

  case "${idx_name}" in
  status-left)
    uptime_string+="#[bg=${uptime[bg]}]"
    uptime_string+="${uptime[separator_left]}"
    ;;
  status-right)
    uptime_string+="#[fg=${uptime[bg]}]"
    uptime_string+="${uptime[separator_right]}"
    ;;
  end)
    if [[ "${option}" == "status-left" ]]; then
      uptime_string+=" #[bg=default]"
      if tmux show-option -gqv "status-left" |
        grep -q "${SCRIPTNAME} [a-z-]*)\$"; then
        uptime_string+="#[fg=${uptime[bg]}]"
        uptime_string+="${uptime[separator_left]}"
      fi
    fi
    ;;
  *)
    uptime_string+="#[bg=${bg_clr}]"
    uptime_string+="#[fg=${fg_clr}]"
    uptime_string+=" ${uptime[${idx_name}]}"
    ;;
  esac
}

main() {
  local option=$1
  local uptime_string=""

  _get_uptime_settings
  _get_uptime_value

  _compute_bg_fg "${option}"
  for module in ${uptime[order]}; do
    _compute_bg_fg "${module}"
  done
  _compute_bg_fg "end"

  echo -e "${uptime_string}"
}

main "$@"
