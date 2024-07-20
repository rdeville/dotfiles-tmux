#!/usr/bin/env bash

SCRIPTPATH="$(
  cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
  pwd -P
)"
SCRIPTNAME="${SCRIPTNAME:-$(basename "$0")}"
source "${SCRIPTPATH}/helpers.sh"

# script global variables
declare -A session

declare -A session_default
session_default[bg]="#4E342E"
session_default[fg]="#ffffff"
session_default[session]="#S"

session_default[icon]=" "

session_default[order]="icon session"

_get_session_settings() {
  for idx in "${!session_default[@]}"; do
    session[${idx}]=$(get_tmux_option "@session_${idx}" "${session_default[${idx}]}")
  done

  if [[ "${option}" == "status-right" ]]; then
    session[separator_right]=$(get_tmux_option "@separator_right")
  elif [[ "${option}" == "status-left" ]]; then
    session[separator_left]=$(get_tmux_option "@separator_left")
  fi
}

_compute_bg_fg() {
  local idx_name=$1

  case "${idx_name}" in
  status-left)
    session_string+="#[bg=${session[bg]}]"
    session_string+="${session[separator_left]}"
    ;;
  status-right)
    session_string+="#[fg=${session[bg]}]"
    session_string+="${session[separator_right]}"
    ;;
  session)
    session_string+="#[bg=${session[bg]},fg=${session[fg]}]"
    session_string+=" ${session[${idx_name}]}"
    ;;
  end)
    if [[ "${option}" == "status-left" ]]; then
      session_string+=" #[bg=default]"
      if tmux show-option -gqv "status-left" |
        grep -q "${SCRIPTNAME} [a-z-]*)\$"; then
        session_string+="#[fg=${session[bg]}]"
        session_string+="${session[separator_left]}"
      fi
    fi
    session_string+="#[fg=${session[bg]}]"
    ;;
  *)
    session_string+="#[bg=${session[bg]},fg=${session[fg]}]"
    session_string+=" ${session[${idx_name}]}"
    ;;
  esac
}

main() {
  local option="$1"
  local session_string=""

  _get_session_settings

  _compute_bg_fg "${option}"
  for module in ${session[order]}; do
    _compute_bg_fg "${module}"
  done
  _compute_bg_fg "end"

  echo -e "${session_string}"
}

main "$@"
