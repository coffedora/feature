#!/bin/sh
# Maintainer: d1sev
# Version: 0.1.0
# Snippets taken from:
#    - https://github.com/devcontainers/features/tree/main/src/setup-utils
#    - https://github.com/ublue-os/startingpoint
#    - https://github.com/devcontainers/feature-starter
#-------------------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://github.com/devcontainers/features/blob/main/LICENSE for license information.
#-------------------------------------------------------------------------------------------------------------------------
# Script variables
USERNAME="${USERNAME:-"${_REMOTE_USER:-"automatic"}"}"
USER_UID="${USERUID:-"automatic"}"
USER_GID="${USERGID:-"automatic"}"
RPM_REPOS="${REPOS:-"automatic"}"
MINIMAL="\
    coreutils iputils shadow-utils util-linux
    git  sudo passwd cracklib-dicts\
    procps procps-ng psmisc \
    wget which tar xz unzip zip"
echo -e 'Source script lib'
source ./lib/dnf.sh $MINIMAL
source ./lib/user.sh
echo -e 'Done!'
exit 0
