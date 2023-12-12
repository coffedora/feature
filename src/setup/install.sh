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
source ./setup.sh || $(echo -e "lib.sh not found" && exit 1)
echo -e 'Run coffedora-feature-setup.sh'
cp ./setup.sh /usr/local/lib/coffedora-feature-setup.sh
chmod +x /usr/local/lib/coffedora-feature-setup.sh
detectUser && echo -e "User detected: $USERNAME\nUID"
createUser && echo -e "User created: $USER_UID\nGID: $USER_GID"
configUser && echo -e "Userhome configured: $(ls /home)"
dnfInstall $DNF_INSTALL && echo -e "Packages installed: $DNF_INSTALL"