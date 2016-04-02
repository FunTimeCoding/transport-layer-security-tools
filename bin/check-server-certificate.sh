#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)

usage()
{
    echo "Local usage: ${0} LOCATOR CERTIFICATE_FILE"
}

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}/../lib/transport-layer-security-tools.sh"

LOCATOR="${1}"
CERTIFICATE_FILE="${2}"

if [ "${LOCATOR}" = "" ] || [ "${CERTIFICATE_FILE}" = "" ]; then
    usage

    exit 1
fi

gnutls-cli "${LOCATOR}" -p 443 --x509cafile "${CERTIFICATE_FILE}"
