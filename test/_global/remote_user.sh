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
check "user required packages (gh)" [ "$(which gh)" ]
# Check REMOTE_USER home directory and settings
check "Create user coffe" [ $(cat /etc/passwd | grep coffe) ]
check "Create home" [ $(ls /home | grep coffe) ]
check "Go $(go version)" [ "$(go version)" ]
check "Brew in Path $(echo $PATH)" [ "$(echo $PATH | grep "brew")" ]
check "WSL Config Created" [ $(cat /etc/wsl.conf | grep coffe) ]
# check "Create home directory $(ls /home/vscode/)" [ "$(ls /home/vscode/)" ]
echo -e "\n"
# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
