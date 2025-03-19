#!/usr/bin/env bash

SCRIPTPATH="$(
  cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
  pwd -P
)"
SCRIPTNAME="${SCRIPTNAME:-$(basename "$0")}"
source "${SCRIPTPATH}/helpers.sh"

# script global variables
declare -A date

declare -A date_default
date_default[bg]="#424242"
date_default[fg]="#ffffff"

date_default[icon]=""
date_default[format]="%a %d %b | %H:%M "

date_default[order]="icon format"

_get_date_settings() {
  for idx in "${!date_default[@]}"; do
    date[${idx}]=$(get_tmux_option "@date_${idx}" "${date_default[${idx}]}")
  done

  if [[ "${option}" == "status-right" ]]; then
    date[separator_right]=$(get_tmux_option "@separator_right")
  elif [[ "${option}" == "status-left" ]]; then
    date[separator_left]=$(get_tmux_option "@separator_left")
  fi
}

_get_date_value() {
  date[value]=$(date +"${date[format]} ")
}

_compute_bg_fg() {
  local idx_name=$1
  local fg_clr=""
  local bg_clr=""

  fg_clr="${date[fg]}"
  bg_clr="${date[bg]}"

  case "${idx_name}" in
  status-left)
    date_string+="#[bg=${date[bg]}]"
    date_string+="${date[separator_left]}"
    ;;
  status-right)
    date_string+="#[fg=${date[bg]}]"
    date_string+="${date[separator_right]}"
    ;;
  end)
    if [[ "${option}" == "status-left" ]]; then
      date_string+=" #[bg=default]"
      if tmux show-option -gqv "status-left" |
        grep -q "${SCRIPTNAME} [a-z-]*)\$"; then
        date_string+="#[fg=${date[bg]}]"
        date_string+="${date[separator_left]}"
      fi
    fi
    date_string+="#[fg=${date[bg]}]"
    ;;
  format)
    date_string+="#[fg=${fg_clr},bg=${bg_clr}]"
    date_string+=" ${date[value]}"
    ;;
  *)
    date_string+="#[fg=${fg_clr},bg=${bg_clr}]"
    date_string+=" ${date[${idx_name}]}"
    ;;
  esac
}

main() {
  local option=$1
  local date_string=""

  _get_date_settings
  _get_date_value

  _compute_bg_fg "${option}"
  for module in ${date[order]}; do
    _compute_bg_fg "${module}"
  done
  _compute_bg_fg "end"

  echo -e "${date_string}"
}

main "$@"
