#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------------------
FEDORA_VERSION="$(cat /etc/os-release | grep -Po '(?<=VERSION_ID=)\d+')"
# User Script variables
USERNAME="${USERNAME:-"${_REMOTE_USER:-"automatic"}"}"
USER_UID="${UID:-"automatic"}"
USER_GID="${GID:-"automatic"}"
# DNF variables
DNF_INSTALL="${DNFINSTALL:-"automatic"}"
DNF_COPR="${COPR:-"automatic"}"
DNF_REMOVE="${REMOVE:-"automatic"}"
# Main script bootstraps the environment and then executes
echo -e 'source ./lib/shared-lib.sh'
source ./lib.sh || $(echo -e "lib.sh not found" && exit 1)
detectUser
createUser
configUser
dnfInstall $DNF_INSTALL