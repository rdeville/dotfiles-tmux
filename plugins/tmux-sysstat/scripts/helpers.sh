get_tmux_option() {
  local option="$1"
  local default_value="$2"
  local option_value="$(tmux show-option -gqv "$option")"
  if [ -z "$option_value" ]; then
    echo "$default_value"
  else
    echo "$option_value"
  fi
}

set_tmux_option() {
  local option="$1"
  local value="$2"
  tmux set-option -gq "$option" "$value"
}

is_osx() {
  [ $(uname) == "Darwin" ]
}

is_chrome() {
  chrome="/sys/class/chromeos/cros_ec"
  if [ -d "$chrome" ]; then
    return 0
  else
    return 1
  fi
}

is_wsl() {
  version=$(</proc/version)
  if [[ "$version" == *"Microsoft"* || "$version" == *"microsoft"* ]]; then
    return 0
  else
    return 1
  fi
}

command_exists() {
  local command="$1"
  type "$command" >/dev/null 2>&1
}

compute_hbar_graph()
{
  local char_block="2588"
  local value=$1
  local nb_char=$2
  local value_remain=""
  local value_mod_ten=""
  local graph=""

  value=$(echo "${value}" | awk '{printf("%d",$1+.5)}')
  value_remain=$(( value % 10 ))
  value_mod_ten=$(( value / 10 ))

  for (( idx=0; idx < ${value_mod_ten}; idx++))
  do
    graph+="\\u${char_block}"
  done

  value_remain="$(\
    echo "${value_remain} / ( ${nb_char} / 8 )" | \
    bc -l | awk '{printf("%d",$1+.5)}' \
  )"

  nb_char=$(( nb_char - value_mod_ten ))
  if [[ "${value_remain}" -gt 0 ]]
  then
    char_block="258$(printf "%x" "$(( 16 - ${value_remain}))")"
    graph+="\\u${char_block}"
    nb_char=$(( nb_char - 1 ))
  fi

  for (( idx=0; idx < nb_char ; idx++ ))
  do
    graph+=" "
  done
  echo "${graph}"
}

compute_vbar_graph(){
  local value=$1
  local char_block=""
  local value_mod_ten=""
  local graph=""

  value=$(echo "${value}" | awk '{printf("%d",$1+.5)}')
  value_mod_ten=$(echo "${value} / 10 / ( 10 / 8 )" | bc -l | awk '{printf("%d",$1+.5)}')
  if [[ "${value_mod_ten}" -eq 0 ]]
  then
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
  for idx in ${!module[@]}
  do
    pattern="#(#{${idx}}"
    replace="#(${module[$idx]} ${option}"
    all_interpolated=${all_interpolated//"${pattern}"/"${replace}"}
    pattern="#{${idx}}"
    replace="#(${module[$idx]} ${option})"
    all_interpolated=${all_interpolated//"${pattern}"/"${replace}"}
  done
  echo "$all_interpolated"
}

update_tmux_option() {
  local option="$1"
  local option_value="$(get_tmux_option "${option}")"
  local new_option_value="$(do_interpolation "${option_value}" "${option}")"
  set_tmux_option "${option}" "${new_option_value}"
}

# ******************************************************************************
# VIM MODELINE
# vim: ft=sh: fdm=indent
# ******************************************************************************
