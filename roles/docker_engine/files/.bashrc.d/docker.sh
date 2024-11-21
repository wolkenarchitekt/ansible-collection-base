#!/usr/bin/env bash
docker_machine_prompt() {
    if [ -n "${DOCKER_MACHINE_NAME}" ]; then
        SHIP="$(printf '\xF0\x9F\x9A\xA2')"
        echo -ne " $SHIP $DOCKER_MACHINE_NAME"
    fi
}
