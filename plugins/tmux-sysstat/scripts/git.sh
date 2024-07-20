#!/usr/bin/env bash

SCRIPTPATH="$(
  cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit 1
  pwd -P
)"
SCRIPTNAME="${SCRIPTNAME:-$(basename "$0")}"
source "${SCRIPTPATH}/helpers.sh"

declare -A git

declare -A git_default

git_default[fg]="#ef5350"
git_default[bg]="#795548"
git_default[icon]="  "

git_default[order]="icon sha tag branch status_order file_order"
git_default[status_order]="up_to_date conflicted behind ahead"
git_default[file_order]="stash added deleted modified type_changed renamed untracked"

git_default[sha_fg]="#2196f3"
git_default[sha_bg]="${git_default[bg]}"
git_default[sha_icon]=" "
git_default[sha]=""

git_default[tag_fg]="#9575cd"
git_default[tag_bg]="${git_default[bg]}"
git_default[tag_icon]="🔖 "
git_default[tag]=""

git_default[branch_fg]="#4fc3f7"
git_default[branch_bg]="${git_default[bg]}"
git_default[branch_icon]=" "
git_default[branch]=""

git_default[stash_fg]="#e91e63"
git_default[stash_bg]="${git_default[bg]}"
git_default[stash_icon]="  "
git_default[stash]=0

git_default[ahead_fg]="#4caf50"
git_default[ahead_bg]="${git_default[bg]}"
git_default[ahead_icon]=" "
git_default[ahead]=0

git_default[behind_fg]="#f44336"
git_default[behind_bg]="${git_default[bg]}"
git_default[behind_icon]=" "
git_default[behind]=0

git_default[diverged_fg]="#f44336"
git_default[diverged_bg]="${git_default[bg]}"
git_default[diverged_icon]=" "
git_default[diverged]=0

git_default[up_to_date_fg]="#4caf50"
git_default[up_to_date_bg]="${git_default[bg]}"
git_default[up_to_date_icon]=" "
git_default[up_to_date]=0

git_default[conflicted_fg]="#f44336"
git_default[conflicted_bg]="${git_default[bg]}"
git_default[conflicted_icon]=" "
git_default[conflicted]=0

git_default[deleted_fg]="#f44336"
git_default[deleted_bg]="${git_default[bg]}"
git_default[deleted_icon]="  "
git_default[deleted]=0

git_default[modified_fg]="#ff9800"
git_default[modified_bg]="${git_default[bg]}"
git_default[modified_icon]="  "
git_default[modified]=""

git_default[renamed_fg]="#cddc39"
git_default[renamed_bg]="${git_default[bg]}"
git_default[renamed_icon]="  "
git_default[renamed]=0

git_default[type_changed_fg]="#00bcd4"
git_default[type_changed_bg]="${git_default[bg]}"
git_default[type_changed_icon]="  "
git_default[type_changed]=0

git_default[staged_fg]="#4caf50"
git_default[staged_bg]="${git_default[bg]}"
git_default[staged_icon]="  "
git_default[staged]=0

git_default[untracked_fg]="#ffeb3b"
git_default[untracked_bg]="${git_default[bg]}"
git_default[untracked_icon]="  "
git_default[untracked]=0

_get_git_settings() {
  for idx in "${!git_default[@]}"; do
    git[${idx}]=$(get_tmux_option "@git_${idx}" "${git_default[${idx}]}")
  done

  if [[ "${option}" == "status-right" ]]; then
    git[separator_right]=$(get_tmux_option "@separator_right")
  elif [[ "${option}" == "status-left" ]]; then
    git[separator_left]=$(get_tmux_option "@separator_left")
  fi
}

_get_git_value() {
  local tag
  tag=$(git -C "${path}" tag --points-at HEAD)

  git[sha]="#[fg=${git[sha_fg]},bg=${git[sha_bg]}] ${git_default[sha_icon]}$(git -C "${path}" rev-parse --short HEAD)"
  git[branch]="#[fg=${git[branch_fg]},bg=${git[branch_bg]}] ${git_default[branch_icon]}$(git -C "${path}" rev-parse --abbrev-ref HEAD)"
  if [[ -n "${tag}" ]]; then
    git[tag]="#[fg=${git[tag_fg]},bg=${git[tag_bg]}] ${git_default[tag_icon]}${tag}"
  fi
}

# Getting the #{pane_current_path}
_get_pane_dir() {
  local nextone="false"
  for i in $(tmux list-panes -F "#{pane_active} #{pane_current_path}"); do
    if [[ "${nextone}" == "true" ]]; then
      echo "${i}"
      return
    fi
    if [ "${i}" == "1" ]; then
      nextone="true"
    fi
  done
}

# Get added, modified, updated and deleted files from git status
_file_info() {
  local output=""

  git[stash]=$(git -C "${path}" stash list | wc -l)

  while read -r line; do
    case "${line}" in
    [AMTDRC][AMTDRC]*)
      # shellcheck disable=SC2004
      git[staged]=$((${git[staged]} + 1))
      ;;
    _M*)
      # shellcheck disable=SC2004
      git[modified]=$((${git[modified]} + 1))
      ;;
    _U*)
      # shellcheck disable=SC2004
      git[updated]=$((${git[updated]} + 1))
      ;;
    _D*)
      # shellcheck disable=SC2004
      git[deleted]=$((${git[deleted]} + 1))
      ;;
    \?\?*)
      # shellcheck disable=SC2004
      git[untracked]=$((${git[untracked]} + 1))
      ;;
    esac
  done <<<"$(git -C "${path}" --no-optional-locks status -s | sed "s/^ /_/g")"

  output=""
  for type in ${git[file_order]}; do
    if [[ "${git[${type}]}" -gt 0 ]]; then
      output+="#[fg=${git[${type}_fg]},bg=${git[${type}_bg]}]${git[${type}_icon]}${git[${type}]}"
    fi
  done

  echo "${output}"
}

_status_info() {
  local base
  local remote
  local output=""

  base=$(git -C "${path}" for-each-ref --format='%(upstream:short) %(upstream:track)' "$(git -C "${path}" symbolic-ref -q HEAD)")
  remote=$(echo "${base}" | cut -d" " -f1)

  output=""

  if [[ -n "${remote}" ]]; then
    git[ahead]=$(echo "${base}" | grep -E -o 'ahead[ [:digit:]]+' | cut -d" " -f2)
    git[behind]=$(echo "${base}" | grep -E -o 'behind[ [:digit:]]+' | cut -d" " -f2)
  fi

  if [[ "${git[ahead]}" -eq 0 ]] && [[ "${git[behind]}" -eq 0 ]]; then
    git[up_to_date]=1
  elif [[ "${git[ahead]}" -ne 0 ]] && [[ "${git[behind]}" -ne 0 ]]; then
    git[diverged]=1
  fi

  for type in ${git[status_order]}; do
    if [[ "${git[${type}]}" -gt 0 ]]; then
      if [[ "${type}" == "up_to_date" ]] || [[ "${type}" == "up_to_date" ]]; then
        output+="#[fg=${git[${type}_fg]},bg=${git[${type}_bg]}]${git[${type}_icon]}"
      else
        output+="#[fg=${git[${type}_fg]},bg=${git[${type}_bg]}]${git[${type}_icon]}${git[${type}]}"
      fi
    fi
  done

  echo "${output}"
}

_compute_bg_fg() {
  local idx_name=$1
  local fg_clr=""
  local bg_clr=""

  fg_clr="${git[fg]}"
  bg_clr="${git[bg]}"

  case "${idx_name}" in
  status-left)
    git_string+="#[bg=${git[bg]}]"
    git_string+="${git[separator_left]}"
    ;;
  status-right)
    git_string+="#[fg=${git[bg]}]"
    git_string+="${git[separator_right]}"
    ;;
  end)
    if [[ "${option}" == "status-left" ]]; then
      git_string+=" #[bg=default]"
      if tmux show-option -gqv "status-left" |
        grep -q "${SCRIPTNAME} [a-z-]*)\$"; then
        git_string+="#[fg=${git[bg]}]"
        git_string+="${git[separator_left]}"
      fi
    fi
    git_string+="#[fg=${git[bg]}]"
    ;;
  *)
    git_string+="#[bg=${bg_clr}]"
    git_string+="#[fg=${fg_clr}]"
    git_string+="${git[${idx_name}]}"
    ;;
  esac
}

main() {
  local option=$1
  local git_string=""
  local path

  path=$(_get_pane_dir)

  _get_git_settings
  _get_git_value

  _compute_bg_fg "${option}"
  if git -C "${path}" rev-parse --abbrev-ref HEAD &>/dev/null; then
    for module in ${git[order]}; do
      if [[ "${module}" == "file_order" ]]; then
        git_string+="$(_file_info)"
      elif [[ "${module}" == "status_order" ]]; then
        git_string+="$(_status_info)"
      else
        _compute_bg_fg "${module}"
      fi
    done
  fi
  _compute_bg_fg "end"

  echo -e "${git_string}"
}

main "$@"
