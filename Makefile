.PHONY: cleanup act_test connect test_autogenerated test_scenarios test_global
baseImage ?= quay.io/fedora/fedora-minimal:latest
feature ?= setup

cleanup:
    rm -rdf /tmp/devcontainercli/ || true && rm -rdf /tmp/${feature} || true && docker rm -vf $$(docker ps -aq) || true

act_test: cleanup
    act workflow_dispatch --pull=false --workflows=.github/workflows/validate.yml --actor=$$GITHUB_USERNAME

connect: cleanup
    docker exec -it $$(docker ps -lq) bash

test_autogenerated: cleanup
    devcontainer features test --skip-scenarios -f ${feature} -i ${baseImage} .

test_scenarios: cleanup
    devcontainer features test -f ${feature} --skip-autogenerated --skip-duplicated .

test_global: cleanup
    devcontainer features test --global-scenarios-only .

test: test_global