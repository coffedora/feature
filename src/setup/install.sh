#!/usr/bin/env bash
#------------------------------------------------------------------------
set -e
FEDORA_VERSION="$(cat /etc/os-release | grep -Po '(?<=VERSION_ID=)\d+')"
# User Script variables
USERNAME="${USERNAME:-"automatic"}"
USER_UID="${UID:-"automatic"}"
USER_GID="${GID:-"automatic"}"
LANGUAGE_SUPPORT="${LANGUAGESUPPORT:-"automatic"}"
WSL_CONFIG="${WSLCONFIG:-"automatic"}"
# Lists of DNF packages and repositories to add/remove   
DNF_INSTALL="${DNFINSTALL:-"automatic"}"
DNF_UPDATE="${DNFUPDATE:-"false"}"
DNF_COPR="${COPR:-"automatic"}"
DNF_REMOVE="${DNFREMOVE:-"automatic"}"
INSTALL_HOMEBREW="${INSTALLHOMEBREW:-"automatic"}"
REQUIREMENTS="\
    dnf-plugins-core coreutils curl iputils shadow-utils util-linux \
    gcc gcc-c++ git gh sudo passwd cracklib-dicts\
    procps procps-ng file psmisc fontconfig\
    wget which tar xz unzip"

# setup.sh script
source ./setup.sh || $(echo -e "setup.sh not found" && exit 1)  
dnfInstall $REQUIREMENTS  && echo -e "Packages installed: $REQUIREMENTS"
detectUser && echo -e "User detected: $USERNAME\nUID"
createUser && echo -e "User created: $USER_UID\nGID: $USER_GID"
configUser && echo -e "Userhome configured: $(ls /home)"
dnfInstall $DNF_INSTALL && echo -e "Packages installed: $DNF_INSTALL"

languageSupport $LANGUAGE_SUPPORT && echo -e "Language support installed: $LANGUAGE_SUPPORT"
homebrewSupport $INSTALL_HOMEBREW && echo -e "Homebrew installed: $INSTALL_HOMEBREW"
wslConfig $WSL_CONFIG && echo -e "WSL configured: $WSL_CONFIG"
# Source additional scripts
if [ DNF_UPDATE == "true" ]; then
    dnf update -y && echo -e "DNF updated"
fi