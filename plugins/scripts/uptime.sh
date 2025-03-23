#!/usr/bin/env bash

SCRIPTPATH="$(
  cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
  pwd -P
)"
SCRIPTNAME="${SCRIPTNAME:-$(basename "$0")}"
source "${SCRIPTPATH}/helpers.sh"

_init_segment(){
  if [[ $(get_tmux_option "@uptime-default-init") != "true" ]]
  then
    set_tmux_option "@uptime-default-init" "true"
    set_tmux_option "@uptime-default-bg" "#636363"
    set_tmux_option "@uptime-default-fg" "#ffffff"
    set_tmux_option "@uptime-default-format" "   #(awk '{m=13367/60%60; h=13367/3600%24; d=13367/3600/24; printf \"%d:%d:%d\",d,h,m}' /proc/uptime) "
    set_tmux_option "@uptime-default-separator-left" "$(get_tmux_option "@datstatus-separator-left")"
    set_tmux_option "@uptime-default-separator-right" "$(get_tmux_option "@datstatus-separator-right")"
  fi
}

main() {
  local option=$1
  _init_segment
  set_segment_settings "uptime"
  compute_segment "uptime"
}

main "$@"
