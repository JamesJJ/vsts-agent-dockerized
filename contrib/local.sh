#!/bin/bash

DOCKER_SOCKET="${DOCKER_SOCKET:-/var/run/docker.sock}"

DOCKER_GROUP="docker_vsts"

# Create a duplicate group to bridge the socket permissions to the VSTS USER
# (even though the default docker group maybe called "docker" on both the
#  host machine and in the container, often their GID is different.
#  This will handle that case)

if [ -S "${DOCKER_SOCKET}" ]; then
    DOCKER_GID="$(stat -c '%g' "${DOCKER_SOCKET}")"
    groupadd -for -g "${DOCKER_GID}" "${DOCKER_GROUP}"
    usermod -aG "${DOCKER_GROUP}" "${VSTS_LINUX_USER}"
fi

