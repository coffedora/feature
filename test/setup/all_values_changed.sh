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
check "Create vscode" [ $(cat /etc/passwd | grep vscode) ]
check "Create home directory " [ "$(ls /home/vscode/.local/)" ]
# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults