#!/usr/bin/env bash

get_tmux_option() {
  local option="$1"
  local default_value="$2"
  local option_value

  option_value="$(tmux show-option -gqv "${option}")"
  if [[ -z "${option_value}" ]]; then
    echo "${default_value}"
  else
    echo "${option_value}"
  fi
}

set_tmux_option() {
  local option="$1"
  local value="$2"
  tmux set-option -gq "${option}" "${value}"
}

command_exists() {
  local command="$1"
  type "${command}" >/dev/null 2>&1
}

get_gradient_idx() {
  local value=${1%%.*}
  echo "$((value / 25 + 1))"
}

compute_bar_graph() {
  local value=$1
  local char_block=""
  local value_mod_ten=""
  local graph=""

  value=$(echo "${value}" | awk '{printf("%d",$1+.5)}')
  value_mod_ten=$((value / 10))
  if [[ "${value_mod_ten}" -eq 0 ]]; then
    graph+=" "
  else
    char_block="258$(printf "%x" "${value_mod_ten}")"
    graph+="\\u${char_block}"
  fi
  echo "${graph}"
}

do_interpolation() {
  local all_interpolated="$1"
  local option="$2"
  local pattern=""
  # shellcheck disable=SC2154
  for idx in "${!module[@]}"; do
    pattern="#(#{${idx}}"
    replace="#(${module[${idx}]} ${option}"
    all_interpolated=${all_interpolated//"${pattern}"/"${replace}"}
    pattern="#{${idx}}"
    replace="#(${module[${idx}]} ${option})"
    all_interpolated=${all_interpolated//"${pattern}"/"${replace}"}
  done
  echo "${all_interpolated}"
}

update_tmux_option() {
  local option="$1"
  local option_value
  local new_option_value

  option_value="$(get_tmux_option "${option}")"
  new_option_value="$(do_interpolation "${option_value}" "${option}")"
  set_tmux_option "${option}" "${new_option_value}"
}
