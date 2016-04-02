#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)

usage()
{
    echo "Local usage: ${0} ISSUER_CERTIFICATE ISSUED_CERTIFICATE"
}

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}/../lib/transport-layer-security-tools.sh"

ISSUER_CERTIFICATE="${1}"
ISSUED_CERTIFICATE="${2}"

if [ "${ISSUER_CERTIFICATE}" = "" ] || [ "${ISSUED_CERTIFICATE}" = "" ]; then
    usage

    exit 1
fi

${CERTTOOL} --verify --load-ca-certificate "${ISSUER_CERTIFICATE}" --infile "${ISSUED_CERTIFICATE}"
