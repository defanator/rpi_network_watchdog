#!/bin/bash -u

# shellcheck disable=SC1091
[ -e /etc/default/rpi_watchdog ] && . /etc/default/rpi_watchdog

log() {
    printf "%s\n" "$@"
}

_watchdog_setup() {
    log "started (gw=${DEFAULT_GATEWAY} interval=${INTERVAL} max_fails=${MAX_FAILS} ping_count=${PING_COUNT} reboot_delay=${REBOOT_DELAY})"
}

_watchdog_teardown() {
    log "exiting"
    exit 0
}

trap "_watchdog_teardown" SIGINT
trap "_watchdog_teardown" SIGTERM

_watchdog_setup

fails=0
reboot_pending=0
extra_msg=""

while true; do
    if ! ping -c "${PING_COUNT}" "${DEFAULT_GATEWAY}" >/dev/null 2>&1; then
        fails=$((fails + 1))
        last_attempt=1
    else
        last_attempt=0
        fails=0
        if (( reboot_pending > 0 )); then
            log "canceling reboot"
            shutdown -c
            reboot_pending=0
        fi
        extra_msg=""
    fi

    if (( fails > MAX_FAILS )); then
        if (( reboot_pending == 0 )); then
            extra_msg=", rebooting in ${REBOOT_DELAY} minute(s)"
            shutdown -r "+${REBOOT_DELAY}" "default gateway is unrechable"
            reboot_pending=1
        else
            extra_msg=", reboot pending"
        fi
    fi

    log "last_attempt=${last_attempt} fails=${fails}${extra_msg}"

    sleep "${INTERVAL}"
done
