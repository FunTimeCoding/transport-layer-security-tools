#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)

usage()
{
    echo "Local usage: ${0} LOCATOR"
}

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}/../lib/transport-layer-security-tools.sh"

LOCATOR="${1}"

if [ "${LOCATOR}" = "" ]; then
    usage

    exit 1
fi

gnutls-cli --starttls --insecure --port 143 "${LOCATOR}"
