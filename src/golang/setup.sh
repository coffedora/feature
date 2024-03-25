#!/bin/bash
# User Script variables
set -e
USERNAME="${USERNAME:-"automatic"}"
USER_UID="${USERUID:-"automatic"}"
USER_GID="${USERGID:-"automatic"}"
INSTALL_HOMEBREW="${INSTALLHOMEBREW:-"automatic"}"
dnfInstall() {
    ln -s $(ls /bin/dnf* | head -n 1) /bin/dnf
    local DNF_INSTALLED=""
    local DNF_FAILED=""
    local dnfPackages=""
    # skip if $@" is "automatic" or empty exit function
    if [ "$@" = "" ]; then
        echo -e "No packages to install"
        return 0
    fi
    mapfile -d ' ' dnfPackages < <(echo "$@")
    for package in "${dnfPackages[@]}"; do
        dnf install -y $package && DNF_INSTALLED="${DNF_INSTALLED} $package" || DNF_FAILED="${DNF_FAILED} $package"
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

detectUser() {
    # If in automatic mode, determine if a user already exists, if not use vscode
    if [ "${USERNAME}" = "automatic" ]; then
        if [ "${_REMOTE_USER}" != "root" ]; then
            USERNAME="${_REMOTE_USER}"
            break
        else
            USERNAME=""
            POSSIBLE_USERS=("devcontainer" "vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
            for CURRENT_USER in "${POSSIBLE_USERS[@]}"; do
                if id -u ${CURRENT_USER} >/dev/null 2>&1; then
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
createUser() {
    # Create or update a non-root user to match UID/GID.
    group_name="${USERNAME}"
    if id -u ${USERNAME} >/dev/null 2>&1; then
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
        echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USERNAME
        chmod 0440 /etc/sudoers.d/$USERNAME || echo "Failed chmod" >&2
        EXISTING_NON_ROOT_USER="${USERNAME}"
        passwd -d ${USERNAME} || echo "Failed remove passwd" >&2
        echo "EXISTING_NON_ROOT_USER: $EXISTING_NON_ROOT_USER"
    fi
}

configUser() {
    if [ "${USERNAME}" = "root" ]; then
        user_home="/root"
    else
        user_home="/home/${USERNAME}"
        mkdir -p ${user_home} /workspaces/
        ln -s /workspaces ${user_home}/Workspace
        chown -R ${USERNAME}:${USERNAME} /home/* || echo "Failed adjust home ownership" >&2
        chown -R ${USERNAME}:${USERNAME} /workspaces/ || echo "Failed adjust workspaces ownership" >&2
        chown -R ${USERNAME}:${USERNAME} /usr/locale/bin || echo "Failed adjust usr/locale/bin usrownership" >&2
        # add $user_home/.local/bin to system path
    fi
    PATH="${user_home}/bin:${user_home}/.local/bin:${user_home}/.local/script:$PATH"
    # code shim for Fedora Container without the code binary
}
languageSupport() {
    # Install language support
    if [ "$@" == "automatic" ]; then
        source ./lang/*.sh || $(echo -e "could not load languageSupport files")
    elif [[ "$@" =~ ^https://.*\.sh$ ]]; then
        curl -sSL "$@" -o temp.sh && source temp.sh || $(echo -e "Failed to download and load language support from $lang")
        rm temp.sh
    else
       source ./lang/$@.sh
    fi
}
homebrewSupport() {
    local homebrew_formulae="gcc starship tailwindcss"
    if  [[ $INSTALL_HOMEBREW == "false" ]]; then
        echo "Skip Homebrew installation"
    else
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        (echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"')>> /etc/bash.bashrc
        (echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') > /etc/profile.d/brew.sh
        chown -R ${USERNAME}:${USERNAME} /home/linuxbrew/.linuxbrew  
    fi
}
wslConfig() {
if  [[ $@ == "false" ]]; then
    echo "Skip WSL Interop Settings"
else
echo "WSL Interop Settings"
dnf install -y docker
cat << 'EOF' > /etc/wsl.conf
[boot]
systemd=true
# Set a command to run when a new WSL instance launches. This example starts the Docker container service.
command = service docker start
# Automatically mount Windows drive when the distribution is launched
[automount]
# Set to true will automount fixed drives (C:/ or D:/) with DrvFs under the root directory set above. Set to false means drives won't be mounted automatically, but need to be mounted manually or with fstab.
enabled = true
# Sets the directory where fixed drives will be automatically mounted. This example changes the mount location, so your C-drive would be /c, rather than the default /mnt/c. 
root = /mnt/
# Sets the `/etc/fstab` file to be processed when a WSL distribution is launched.
mountFsTab = true
# Network host settings that enable the DNS server used by WSL 2. This example changes the hostname, sets generateHosts to false, preventing WSL from the default behavior of auto-generating /etc/hosts, and sets generateResolvConf to false, preventing WSL from auto-generating /etc/resolv.conf, so that you can create your own (ie. nameserver 1.1.1.1).
[network]
# hostname to be used for WSL distribution. Windows hostname is default
hostname = wsl
generateHosts = true
generateResolvConf = true
# Set whether WSL supports interop process like launching Windows apps and adding path variables. Setting these to false will block the launch of Windows processes and block adding $PATH environment variables.
[interop]
# Setting this key will determine whether WSL will support launching Windows processes.
enabled = true
# Setting this key will determine whether WSL will add Windows path elements to the $PATH environment variable.
appendWindowsPath = true
EOF
   if [ "${USERNAME}" != "root" ]; then
        #append on  .wsl.conf with default values to enable login with default user
        echo "[user]" >> /etc/wsl.conf
        echo "default=${USERNAME}" >> /etc/wsl.conf
        # create workspace directory in root and make root and $USERNAME the owner
    fi
fi
}
