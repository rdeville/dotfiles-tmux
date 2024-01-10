#!/usr/bin/env #!/bin/bash

# Source per host/user configuration if any
# -----------------------------------------------------------------------------
HOST=$(hostname)
custom_host_files=(
  "${SCRIPTPATH}/hosts/${HOST}/config.sh"
  "${SCRIPTPATH}/hosts/${HOST}.sh"
  "${SCRIPTPATH}/hosts/${HOST}/${USER}.sh"
  "${SCRIPTPATH}/hosts/${HOST}/${USER}/config.sh"
)
for iFile in "${custom_host_files[@]}"
do
  if [[ -f "${iFile}" ]]
  then
    # shellcheck disable=SC1090
    source "${iFile}"
  fi
done

# Update fg to bold if SSH
# -----------------------------------------------------------------------------
if [[ -n "${SSH_CLIENT}"  ]]
then
  status[fg]+=" bold"
fi

# Update fg with underscore if root
# -----------------------------------------------------------------------------
if [[ "$(whoami)" == "root"  ]]
then
  status[fg]+=" underscore"
fi


