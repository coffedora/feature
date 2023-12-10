#!/bin/bash
set -e
# User Script variables
USERNAME="${USERNAME:-"automatic"}"
USER_UID="${USERUID:-"automatic"}"
USER_GID="${USERGID:-"automatic"}"
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
setUser(){
# Create or update a non-root user to match UID/GID.
group_name="${USERNAME}"
if id -u ${USERNAME} > /dev/null 2>&1; then
    # User exists, update if needed
    if [ "${USER_GID}" != "automatic" ] && [ "$USER_GID" != "$(id -g $USERNAME)" ]; then
        group_name="$(id -gn $USERNAME)"
        groupmod --gid $USER_GID ${group_name}
        usermod --gid $USER_GID $USERNAME
    fi
    if [ "${USER_UID}" != "automatic" ] && [ "$USER_UID" != "$(id -u $USERNAME)" ]; then
        usermod --uid $USER_UID $USERNAME
    fi
else
    # Create user
    if [ "${USER_GID}" = "automatic" ]; then
        groupadd $USERNAME
    else
        groupadd --gid $USER_GID $USERNAME
    fi
    if [ "${USER_UID}" = "automatic" ]; then
        useradd --gid $USERNAME -m $USERNAME
    else
        useradd --uid $USER_UID --gid $USERNAME -m $USERNAME
    fi
    passwd -d ${USERNAME}
fi
# Add sudo support for non-root user
if [ "${USERNAME}" != "root" ] && [ "${EXISTING_NON_ROOT_USER}" != "${USERNAME}" ]; then
    usermod -aG wheel ${USERNAME}
    echo $USERNAME ALL=\(wheel\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME
    chmod 0440 /etc/sudoers.d/$USERNAME
    EXISTING_NON_ROOT_USER="${USERNAME}"
    passwd -d ${USERNAME}
    mkdir -p /workspaces/
    chown ${USERNAME}:${USERNAME} /workspaces/
    echo "EXISTING_NON_ROOT_USER: $EXISTING_NON_ROOT_USER"
fi
}

configUser(){
    if [ "${USERNAME}" = "root" ]; then
      user_home="/root"
    else
      user_home="/home/${USERNAME}"
      mkdir -p ${user_home}
      # add $user_home/.local/bin to system path
    fi
    PATH="${user_home}/bin:${user_home}/.local/bin:${user_home}/.local/script:$PATH"
    chown -R ${USERNAME}:${group_name} /workspaces
    # code shim for Fedora Container without the code binary 
}
appInstallerShimGen(){
#check if HOMEBREW is in path
cat << 'EOF' > /usr/local/bin/app
#!/bin/sh
if [ "$(id -u)" -ne 0 ]; then
   if [[ $PATH == *"/home/linuxbrew/.linuxbrew/bin"* ]]; then
      echo -e "Running homebrew as user"
      brew $@
      exit $?
   else
      echo -e "homebrew is not in path, run app Shim with sudo"
      sudo "$0" "$@"
      exit $?
   fi
fi
if [ "$(command -v microdnf)" ]; then
    echo -e "Running microdnf -y $@ as root"
    microdnf -y $@
    exit $?
fi
if [ "$(command -v dnf)" ]; then
    echo -e "Running dnf -y $@ as root"
    dnf -y $@
    exit $?
fi
EOF
}
codeShimGen(){
    cat << 'EOF' > /usr/local/bin/code
#!/bin/sh

get_in_path_except_current() {
    which -a "$1" | grep -A1 "$0" | grep -v "$0"
}
workpath="."
code="$(get_in_path_except_current code)"
if [ -n "$@" ]; then
    workpath=$@
fi
if [ -n "$code" ]; then
    exec "$code" "$workpath" 
elif [ "$(command -v code-insiders)" ]; then
    exec code-insiders "$workpath"
else
    echo "code or code-insiders is not installed" >&2
    exit 127
fi
EOF
    chmod +x /usr/local/bin/code
}
wslConfGen(){
if  [[ $WSL_READY != "true" ]]; then
    echo "Skip WSL Interop Settings"
else
    echo "WSL Interop Settings"
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
    fi
fi
}
# Main script bootstraps the environment and then executes
detectUser
setUser
configUser
codeShimGen
appInstallerShimGen
wslConfGen
echo -e 'Done!'