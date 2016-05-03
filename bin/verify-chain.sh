#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)

usage()
{
    echo "Local usage: ${0} AUTHORITY_CERTIFICATE CHAIN"
}

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}/../lib/transport-layer-security-tools.sh"

AUTHORITY_CERTIFICATE="${1}"
CHAIN="${2}"

if [ "${AUTHORITY_CERTIFICATE}" = "" ] || [ "${CHAIN}" = "" ]; then
    usage

    exit 1
fi

${CERTTOOL} --verify-chain --load-ca-certificate "${AUTHORITY_CERTIFICATE}" --infile "${CHAIN}"
