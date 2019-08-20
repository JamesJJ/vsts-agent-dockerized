#!/bin/bash

[ -z "${VSTS_ACCOUNT}" ] && exit 1
[ -z "${PAT_TOKEN}" ]    && exit 2
[ -z "${AGENT_POOL}" ]   && exit 3
[ -z "${AGENT_NAME}" ]   && \
    export AGENT_NAME="${AGENT_POOL:-x}-$(date '+%Y%m%d')-$(hostname -s)"
[ -z "${VSTS_URL}" ]   && \
    export VSTS_URL="https://dev.azure.com/${VSTS_ACCOUNT}"

if [ ! -f config.sh ] || [ ! -f run.sh ]; then
    echo "* Use this as a base image in your own Dockerfile e.g. FROM jamesjj/vsts-agent-dockerized" 1>&2
    exit 4
fi

exit_script() {
    sudo -u "${VSTS_LINUX_USER}" bash ./config.sh remove  --auth pat --token "${PAT_TOKEN}"
    trap - SIGINT SIGTERM # clear the trap
    kill -- -$$ # Sends SIGTERM to child/sub processes
}

trap exit_script SIGINT SIGTERM

[ -f "${VSTS_BASE_DIR}/bin/local.sh" ] && source "${VSTS_BASE_DIR}/bin/local.sh"

source scl_source enable rh-git29 && \
    echo "Defaults secure_path=\"${PATH}\"" | tee /etc/sudoers.d/92-secure-path

# Source git and set Agent PATH
sudo -u "${VSTS_LINUX_USER}" bash -c 'source scl_source enable rh-git29 && echo "$PATH" | tee .path'

mkdir -p "${VSTS_BASE_DIR}/tmp/_work"

chown -R "${VSTS_LINUX_USER}" "${VSTS_BASE_DIR}/tmp/_work"

sudo -u "${VSTS_LINUX_USER}" bash ./config.sh \
    --unattended  \
    --url "${VSTS_URL}" \
    --auth pat \
    --token "${PAT_TOKEN}" \
    --pool "${AGENT_POOL}" \
    --agent "${AGENT_NAME}" \
    --work "${VSTS_BASE_DIR}/tmp/_work" \
  && \
  sudo -u "${VSTS_LINUX_USER}" bash ./run.sh

