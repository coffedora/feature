#!/bin/bash
if ! dnf --version > /dev/null 2>&1; then
    ln -s $(ls /bin/dnf* | head -n 1) /bin/dnf
fi

dnfI() {
  local DNF_INSTALLED=""
  local DNF_FAILED=""
  if [ -z "$@" ]; then
    echo "No packages to install"
    return 0
  fi
  mapfile -d ' ' DNF_INSTALL  < <(echo "$@")

  for package in "${DNF_INSTALL[@]}"; do
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
dnfR(){
  local FEDORA_VERSION="$(cat /etc/os-release | grep -Po '(?<=VERSION_ID=)\d+')"
  mapfile -d ' ' REPO_URLS  < <(echo "$@")
  if [[ ${#REPO_URLS[@]} -gt 0 ]]; then
      for repo in "${REPO_URLS[@]}"; do
          repo="${repo//%FEDORA_VERSION%/${FEDORA_VERSION}}"
          wget "${repo}" -P "/etc/yum.repos.d/"
      done
    dnf upgrade -y
  fi
}
dnfL(){
  if ! fzf --version> /dev/null 2>&1; then
    dnf install -y fzf
  fi
  dnf list | fzf
}

dnfS(){
  if ! fzf --version> /dev/null 2>&1; then
    dnf install -y fzf
  fi
  dnf search $@ | fzf
}

dnfI $@
