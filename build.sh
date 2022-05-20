#!/bin/bash
set -e

FONT_RED='\033[1;31m'
FONT_GREEN='\033[1;32m'
FONT_YELLOW='\033[1;33m'
FONT_BLUE='\033[1;34m'
FONT_PURPLE='\033[1;35m'
FONT_CYAN='\033[1;36m'
FONT_RESET='\033[0m'

function send_mesage() {
    local message_color message_type message_text
    message_color="${1}"
    message_type="${2:-UNDEF}"
    message_text="${3}"

    echo -e "${message_color} $(date '+%F %T') [${message_type}] ${message_text} ${FONT_RESET}"
}

function echo_error() {
    local message
    message="${1}"
    send_mesage "${FONT_RED}" 'ERROR' "${message}"
}

function echo_warn() {
    local message
    message="${1}"
    send_mesage "${FONT_YELLOW}" 'WARN ' "${message}"
}

function echo_info() {
    local message
    message="${1}"
    send_mesage "${FONT_CYAN}" 'INFO ' "${message}"
}

function echo_debug() {
    local message
    message="${1}"
    if [ "${DEBUG}" == 'true' ]; then
        send_mesage "${FONT_BLUE}" 'DEBUG' "${message}"
    fi
}

function echo_success() {
    local message
    message="${1}"
    send_mesage "${FONT_GREEN}" ' OK  ' "${message}"
}


############################## MAIN ##############################
DFX_VERSIONS="${1}"
NODE_INSTALL_VERSION="${2:-16}"
PUSH="${3:-false}"
CLEAN="${4:-false}"

file_list="Dockerfile scripts/dfx_run scripts/dfxctl"

for f in ${file_list}; do
    f="${f#./}"
    if ! [ -s "./${f}" ]; then
        echo_error "Can't find ./${f}" >&2
        exit 1
    fi
done

if [ -n "${DFX_VERSIONS}" ]; then
    for dfx in ${DFX_VERSIONS}; do
        dfx_ars="--build-arg DFX_VERSION=${dfx}"

        echo_info "[BUILD] docker build ${dfx_ars} --build-arg NODE_INSTALL_VERSION=${NODE_INSTALL_VERSION} --build-arg RUN_INTERNET_IDENTITY= -t identitylabs/dfxctl:${dfx} ." >&2
        docker build ${dfx_ars} --build-arg NODE_INSTALL_VERSION=${NODE_INSTALL_VERSION} --build-arg RUN_INTERNET_IDENTITY= -t identitylabs/dfxctl:${dfx} .

        echo_info "[BUILD] docker build ${dfx_ars} --build-arg NODE_INSTALL_VERSION=${NODE_INSTALL_VERSION} --build-arg RUN_INTERNET_IDENTITY=true -t identitylabs/dfxctl:${dfx}-ii ." >&2
        docker build ${dfx_ars} --build-arg NODE_INSTALL_VERSION=${NODE_INSTALL_VERSION} --build-arg RUN_INTERNET_IDENTITY=true -t identitylabs/dfxctl:${dfx}-ii .

        if [ "${PUSH}" == 'true' ]; then
            echo_info "[PUSH ] docker push identitylabs/dfxctl:${dfx}" >&2
            docker push identitylabs/dfxctl:${dfx}      

            echo_info "[PUSH ] docker push identitylabs/dfxctl:${dfx}-ii" >&2
            docker push identitylabs/dfxctl:${dfx}-ii
        fi

        if [ "${CLEAN}" == 'true' ]; then
            echo_warn "[CLEAN] docker rmi identitylabs/dfxctl:${dfx}-ii" >&2
            docker rmi identitylabs/dfxctl:${dfx}-ii

            echo_warn "[CLEAN] docker rmi identitylabs/dfxctl:${dfx}" >&2
            docker rmi identitylabs/dfxctl:${dfx}
        fi
    done
fi
