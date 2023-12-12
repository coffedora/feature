#!/bin/bash
# User Script variables
USERNAME="${USERNAME:-"automatic"}"
USER_UID="${USERUID:-"automatic"}"
USER_GID="${USERGID:-"automatic"}"
REQUIREMENTS="\
    coreutils iputils shadow-utils util-linux \
    git gh gcc gcc++ sudo passwd cracklib-dicts \
    procps procps-ng psmisc \
    wget which tar xz unzip zip"
    
dnfInstall() {
  ln -s $(ls /bin/dnf* | head -n 1) /bin/dnf
  local DNF_INSTALLED=""
  local DNF_FAILED=""
  local dnfPackages=""
    # skip if $@" is "automatic" or empty exit function
    if [ "$@" = "automatic" ] || [ "$@" = "" ]; then
        echo -e "No packages to install"
        exit 0
    fi
  mapfile -d ' ' dnfPackages  < <(echo "$@")
  for package in "${dnfPackages[@]}"; do
      dnf install -y $package && DNF_INSTALLED="${DNF_INSTALLED} $package"|| DNF_FAILED="${DNF_FAILED} $package"
  done
  echo -e "Cleanup..."
  dnf clean all
  rm -rfd /var/cache/*
  echo -e "n\
  DNF_INSTALLED: ${DNF_INSTALLED}\n\
  DNF_FAILED: ${DNF_FAILED}\n\
  DNF_BINARY: $(ls /bin/dnf* | head -n 1)"
  echo -e "Done!"
}

detectUser(){
    # If in automatic mode, determine if a user already exists, if not use vscode
    if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
        if [ "${_REMOTE_USER}" != "root" ]; then
            USERNAME="${_REMOTE_USER}"
        else
            USERNAME=""
            POSSIBLE_USERS=("devcontainer" "vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
            for CURRENT_USER in "${POSSIBLE_USERS[@]}"; do
                if id -u ${CURRENT_USER} > /dev/null 2>&1; then
                    USERNAME=${CURRENT_USER}
                    break
                fi
            done
            if [ "${USERNAME}" = "" ]; then
                USERNAME=vscode
            fi
        fi
    elif [ "${USERNAME}" = "none" ]; then
        USERNAME=root
        USER_UID=0
        USER_GID=0
    fi
}
createUser(){
    dnfInstall $REQUIREMENTS
    # Create or update a non-root user to match UID/GID.
    group_name="${USERNAME}"
    if id -u ${USERNAME} > /dev/null 2>&1; then
        # User exists, update if needed
        if [ "${USER_GID}" != "automatic" ] && [ "$USER_GID" != "$(id -g $USERNAME)" ]; then
            group_name="$(id -gn $USERNAME)"
            groupmod --gid $USER_GID ${group_name} || echo "Failed groupmod" >&2
            usermod --gid $USER_GID $USERNAME || echo "Failed usermod" >&2
        fi
        if [ "${USER_UID}" != "automatic" ] && [ "$USER_UID" != "$(id -u $USERNAME)" ]; then
            usermod --uid $USER_UID $USERNAME || echo "Failed usermod" >&2
        fi
    else
        # Create user
        if [ "${USER_GID}" = "automatic" ]; then
            groupadd $USERNAME || echo "Failed groupadd" >&2
        else
            groupadd --gid $USER_GID $USERNAME || echo "Failed groupadd" >&2
        fi
        if [ "${USER_UID}" = "automatic" ]; then
            useradd --gid $USERNAME -m $USERNAME || echo "Failed useradd" >&2
        else
            useradd --uid $USER_UID --gid $USERNAME -m $USERNAME || echo "Failed useradd" >&2
        fi
        passwd -d ${USERNAME} || echo "Failed passwd" >&2
    fi
    # Add sudo support for non-root user
    if [ "${USERNAME}" != "root" ] && [ "${EXISTING_NON_ROOT_USER}" != "${USERNAME}" ]; then
        usermod -aG wheel ${USERNAME} || echo "Failed  to add ${USERNAME} to wheel" >&2
        echo $USERNAME ALL=\(wheel\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME
        chmod 0440 /etc/sudoers.d/$USERNAME || echo "Failed chmod" >&2
        EXISTING_NON_ROOT_USER="${USERNAME}"
        passwd -d ${USERNAME} || echo "Failed remove passwd" >&2
        echo "EXISTING_NON_ROOT_USER: $EXISTING_NON_ROOT_USER"
    fi
}

configUser(){
    if [ "${USERNAME}" = "root" ]; then
      user_home="/root"
    else
      user_home="/home/${USERNAME}"
      mkdir -p ${user_home} /workspaces/
      chown ${USERNAME}:${USERNAME} /workspaces/  || echo "Failed adjust ownership" >&2
      # add $user_home/.local/bin to system path
    fi
    PATH="${user_home}/bin:${user_home}/.local/bin:${user_home}/.local/script:$PATH"
    # code shim for Fedora Container without the code binary 
}