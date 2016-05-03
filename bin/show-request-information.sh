#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)

usage()
{
    echo "Local usage: ${0} CERTIFICATE_REQUEST"
}

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}/../lib/transport-layer-security-tools.sh"

CERTIFICATE_REQUEST="${1}"

if [ "${CERTIFICATE_REQUEST}" = "" ]; then
    usage

    exit 1
fi

${CERTTOOL} --crq-info --infile "${CERTIFICATE_RQUEST}"
