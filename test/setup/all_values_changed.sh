#!/bin/bash

# This test file will be executed against one of the scenarios devcontainer.json test that
# includes the 'color' feature with "favorite": "green" option.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "Fedora OS Release" [ $(cat /etc/os-release | grep "ID=fedora") ]
check "DNF Available" [ "$(dnf --version)" ]
check "Go $(go version)" [ "$(go version)" ]
check "Create user" [ $(cat /etc/passwd | grep vscode) ]
check "Create home" [ $(ls /home | grep vscode) ]
check "Brew in Path $(echo $PATH)" [ "$(echo $PATH | grep "brew")" ]
# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults