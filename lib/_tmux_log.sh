#!/usr/bin/env bash
# """Contain method to print log message
#
# SYNOPSIS:
#   source /path/to/mr_log.sh
#
# DESCRIPTION:
#   Echo colored log depending on user provided message severity. Message
#   severity are associated to following color output:
#
#     - `DEBUG` print in the fifth colors of the terminal (usually magenta)
#     - `INFO` print in the second colors of the terminal (usually green)
#     - `WARNING` print in the third colors of the terminal (usually yellow)
#     - `ERROR` print in the third colors of the terminal (usually red)
#
#   If no message severity is provided, severity will automatically be set to
#   INFO.
#
# """

# shellcheck disable=SC2034
#   - SC2034: var appears unused, Verify use (or export if used externally)
tmux_log()
{
  # """Print debug message in colors depending on message severity on stderr
  #
  # Echo colored log depending on user provided message severity. Message
  # severity are associated to following color output:
  #
  #   - `DEBUG` print in the fifth colors of the terminal (usually magenta)
  #   - `INFO` print in the second colors of the terminal (usually green)
  #   - `WARNING` print in the third colors of the terminal (usually yellow)
  #   - `ERROR` print in the third colors of the terminal (usually red)
  #
  # If no message severity is provided, severity will automatically be set to
  # INFO.
  #
  # Globals:
  #   None
  #
  # Arguments:
  #   $1: string, message severity or message content
  #   $@: string, message content
  #
  # Output:
  #   Log informations colored
  #
  # Returns:
  #   None
  #
  # """

  # Store color prefixes in variable to ease their use.
  # Base on only 8 colors to ensure portability of color when in tty
  local e_normal="\e[0m"     # Normal (usually white fg & transparent bg)
  local e_bold="\e[1m"       # Bold
  local e_underline="\e[4m"  # Underline
  local e_debug="\e[0;34m"   # Fifth term color (usually magenta fg)
  local e_info="\e[0;32m"    # Second term color (usually green fg)
  local e_warning="\e[0;33m" # Third term color (usually yellow fg)
  local e_error="\e[0;31m"   # First term color (usually red fg)

  # Store preformated colored prefix for log message
  local error="${e_bold}${e_error}[ERROR]${e_normal}${e_error}"
  local warning="${e_bold}${e_warning}[WARNING]${e_normal}${e_warning}"
  local info="${e_bold}${e_info}[INFO]${e_normal}${e_info}"
  local debug="${e_bold}${e_debug}[INFO]${e_normal}${e_debug}"

  local color_output="e_error"
  local msg_severity
  local msg

  # Not using ${1^^} to ensure portability when using ZSH
  msg_severity=$(echo "$1" | tr '[:upper:]' '[:lower:]')

  if [[ "${msg_severity}" =~ ^(error|time|warning|info|debug)$ ]]
  then
    # Shift arguments by one such that $@ start from the second arguments
    shift
    # Place the content of variable which name is defined by ${msg_severity}
    # For instance, if `msg_severity` is INFO, then `prefix` will have the same
    # value as variable `info`.
    prefix="${!msg_severity}"
    color_output="e_${msg_severity}"
  else
    prefix="${info}"
  fi
  color_output="${!color_output}"

  # Concat all remaining arguments in the message content and apply markdown
  # like syntax.
  msg_content=$(echo "$*" | \
    sed -e "s/ \*\*/ \\${e_bold}/g" \
        -e "s/\*\*\./\\${e_normal}\\${color_output}./g" \
        -e "s/\*\*,/\\${e_normal}\\${color_output},/g" \
        -e "s/\*\* /\\${e_normal}\\${color_output} /g" \
        -e "s/ \_\_/ \\${e_underline}/g" \
        -e "s/\_\_\./\\${e_normal}\\${color_output}./g" \
        -e "s/\_\_ /\\${e_normal}\\${color_output} /g")
  msg="${prefix} ${msg_content}${e_normal}"

  # Print message
  echo -e "${msg}" 1>&2
}


# ------------------------------------------------------------------------------
# VIM MODELINE
# vim: ft=bash: fdm=indent
# ------------------------------------------------------------------------------
