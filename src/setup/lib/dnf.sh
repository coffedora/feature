#!/bin/bash
if ! dnf --version > /dev/null 2>&1; then
    ln -s $(ls /bin/dnf* | head -n 1) /bin/dnf
fi
dnfI() {
  if ! dnf --version > /dev/null 2>&1; then
    ln -s $(ls /bin/dnf* | head -n 1) /bin/dnf
  fi
  local DNF_INSTALLED=""
  local DNF_FAILED=""
  if [ -z "$@" && "$@" != "automatic" ]; then
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
  if [[ ${#DNF_COPR_LIST[@]} -gt 0 ]]; then
      for repo in "${DNF_COPR_LIST[@]}"; do
            # repo has the format name/project. Split it into variabkes name and project
            local name="$(echo $repo | cut -d'/' -f1)"
            local project="$(echo $repo | cut -d'/' -f2)"
            if [[ $name != https* && $project != *.repo ]]; then
                repo="https://copr.fedorainfracloud.org/coprs/${name}/${project}/repo/fedora-${FEDORA_VERSION}/${name}-${project}-fedora-${FEDORA_VERSION}.repo"
            fi
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
dnfRm(){
  local DNF_REMOVED=""
  local DNF_REMOVE_FAILED=""
  if [ "$DNF_REMOVE" != "automatic" ]; then
    map file -d ' ' DNF_REMOVE_LIST < <(echo "$DNF_REMOVE")
  else
    map file -d ' ' DNF_REMOVE_LIST < <(echo "$@")
  fi
  for package in "${DNF_REMOVE_LIST[@]}"; do
      dnf remove -y $package && DNF_REMOVED="${DNF_REMOVED} $package"|| DNF_REMOVE_FAILED="${DNF_REMOVE_FAILED} $package"
  done
  echo -e "Cleanup..."
  dnf clean all
  rm -rfd /var/cache/*
  echo -e "n\
  DNF_REMOVED: ${DNF_REMOVED}\n\
  DNF_REMOVE_FAILED: ${DNF_REMOVE_FAILED}\n\
  DNF_BINARY: $(ls /bin/dnf* | head -n 1)"
  echo -e "Done!"
}
dnfS(){
  if ! fzf --version> /dev/null 2>&1; then
    dnf install -y fzf
  fi
  # selection from fzf cuts the string until the "." and passes the result to dnf install 
  dnf search $@ | fzf | cut -d'.' -f1 | xargs dnf install  
}

dnfI $@