#!/bin/bash

# The 'test/_global' folder is a special test folder that is not tied to a single feature.
#
# This test file is executed against a running container constructed
# from the value of 'color_and_hello' in the tests/_global/scenarios.json file.
#
# The value of a scenarios element is any properties available in the 'devcontainer.json'.
# Scenarios are useful for testing specific options in a feature, or to test a combination of features.
#
# This test can be run with the following command (from the root of this repo)
#    devcontainer features test --global-scenarios-only .
set -e
# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib
check "Can use DNF to install packages $(dnf --version)" [ "$(dnf --version)" ]
check "Minimum required packages" [ "$(which git)" ]
check "Minimum required packages" [ "$(which gh)" ]
# Check REMOTE_USER home directory and settings
check "Create vscode $(cat /etc/passwd)" [ "$(cat /etc/passwd | grep 'vscode')" ]
# check "Create home directory $(ls /home/vscode/)" [ "$(ls /home/vscode/)" ]
# echo -e "\n"
# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
