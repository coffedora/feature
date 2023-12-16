#!/usr/bin/env bash
#------------------------------------------------------------------------
set -e
FEDORA_VERSION="$(cat /etc/os-release | grep -Po '(?<=VERSION_ID=)\d+')"
# User Script variables
USERNAME="${USERNAME:-"${_REMOTE_USER:-"automatic"}"}"
USER_UID="${UID:-"automatic"}"
USER_GID="${GID:-"automatic"}"
LANGUAGE_SUPPORT="${LANGUAGESUPPORT:-"automatic"}"
# Lists of DNF packages and repositories to add/remove   
DNF_INSTALL="${DNFINSTALL:-"automatic"}"
DNF_COPR="${COPR:-"automatic"}"
DNF_REMOVE="${REMOVE:-"automatic"}"


REQUIREMENTS="\
    coreutils iputils shadow-utils util-linux \
    git gh gcc gcc++ sudo passwd cracklib-dicts \
    procps procps-ng psmisc \
    wget which tar xz unzip zip"

# setup.sh script
source ./setup.sh || $(echo -e "setup.sh not found" && exit 1)  
dnfInstall $REQUIREMENTS  && echo -e "Packages installed: $REQUIREMENTS"
languageSupport $LANGUAGE_SUPPORT && echo -e "Language support installed: $LANGUAGE_SUPPORT"
detectUser && echo -e "User detected: $USERNAME\nUID"
createUser && echo -e "User created: $USER_UID\nGID: $USER_GID"
configUser && echo -e "Userhome configured: $(ls /home)"
dnfInstall $DNF_INSTALL && echo -e "Packages installed: $DNF_INSTALL"


# Source additional scripts