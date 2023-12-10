#!/bin/bash
# TLDR: all settings on default and remoteUser is root. 
# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'color' Feature with no options.
#
# For more information, see: https://github.com/devcontainers/cli/blob/main/docs/features/test.md
#
# Eg:
# {
#    "image": "<..some-base-image...>",
#    "features": {
#      "setup": {}
#    },
#    "remoteUser": "root"
# }
#
# Thus, the value of all options will fall back to the default value in the
# Feature's 'devcontainer-feature.json'.
# For the 'color' feature, that means the default favorite color is 'red'.
#
# These scripts are run as 'root' by default. Although that can be changed
# with the '--remote-user' flag.
# 
# This test can be run with the following command:
#
#    devcontainer features test    \ 
#               --features color   \
#               --remote-user root \
#               --skip-scenarios   \
#               --base-image mcr.microsoft.com/devcontainers/base:ubuntu \
#               /path/to/this/repo
set -e
# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib
# Feature-specific tests
# Check system settings outside remoteUser home directory
check "GO in path" [ "$(go version)" ]
check "GO Tools installed" [ "$(templ version)" ]
check "GO Tools installed" [ "$(go-blueprint version)" ]
# check "Create user correct" [ $(cat /etc/passwd | grep "coffe:x:1000:1000") ]
echo -e "\n"
# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
