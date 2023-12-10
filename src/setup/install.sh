#!/usr/bin/env bash
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
MARKER_FILE="/usr/local/etc/vscode-dev-containers/common"
# User Script variables
USERNAME="${USERNAME:-"automatic"}"
USER_UID="${UID:-"automatic"}"
USER_GID="${GID:-"automatic"}"
# DNF variables
DNF_INSTALL="${INSTALL:-"automatic"}"
DNF_COPR="${COPR:-"automatic"}"
DNF_REMOVE="${REMOVE:-"automatic"}"
REQUIREMENTS="\
    coreutils iputils shadow-utils util-linux \
    git gh sudo passwd cracklib-dicts \
    procps procps-ng python3 python3-pip psmisc fd fzf \
    wget which tar xz unzip zip fish"
# Main script bootstraps the environment and then executes
echo -e 'Preset Enviroment'

mkdir -p /etc/skel/.local/bin /etc/skel/.local/script /etc/skel/.local/share /etc/skel/.config
mkdir -p /workspaces/ && chmod 770 /workspaces/
ln -s /workspaces/ /etc/skel/workspaces

echo -e 'source scripts'
source ./lib/dnf.sh $REQUIREMENTS
source ./lib/user.sh
dnfI $DNF_INSTALL
#Check in /etc/passwd if a user owns home directory
# check if there is any home directories in /home
if [ "$(ls -A /home)" ]; then
    cp -rf ./lib/* /home/*/.local/bin
fi

# TODO: Add support for additional package managers options
# if [ DNF_COPR != "automatic" ]; then
#     echo -e 'Add COPR repos'
#     dnfR $DNF_COPR
# fi
# if [ DNF_INSTALL != "automatic" ]; then
#     echo -e 'Add DNF packages'
#     dnfI $DNF_INSTALL
# fi
# if [ DNF_REMOVE != "automatic" ]; then
#     echo -e 'Remove DNF packages'
#     dnfRm $DNF_REMOVE
# fi
echo -e 'Done!'
exit 0