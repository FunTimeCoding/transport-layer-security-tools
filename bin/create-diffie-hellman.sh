#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)

usage()
{
    echo "Local usage: ${0}"
}

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}/../lib/transport-layer-security-tools.sh"

OUTFILE="${DOMAIN_NAME}.dh.pem"

if [ -f "${OUTFILE}" ]; then
    echo "File already exists: ${OUTFILE}"
else
    ${CERTTOOL} --generate-dh-params --outfile "${OUTFILE}" --sec-param medium
    echo "Generated: ${OUTFILE}"
fi
