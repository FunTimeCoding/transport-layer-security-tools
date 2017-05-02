#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)

usage()
{
    echo "Generate a node private key and certificate signing request."
    echo "Local usage: ${0} [--with-address] DOMAIN_LABELS"
    echo "Example: ${0} foo # for foo.example.org"
    echo "Example: ${0} bar.foo # for bar.foo.example.org"
}

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}/../lib/transport-layer-security-tools.sh"
DOMAIN_LABELS="${1}"

if [ "${DOMAIN_LABELS}" = "" ]; then
    usage

    exit 1
fi

NODE_NAME="${DOMAIN_LABELS}.${DOMAIN_NAME}"
NODE_PRIVATE_KEY="${PRIVATE_DIRECTORY}/${NODE_NAME}.node-private-key.pem"

if [ ! -f "${NODE_PRIVATE_KEY}" ]; then
    ${CERTTOOL} --generate-privkey --outfile "${NODE_PRIVATE_KEY}"
fi

NODE_REQUEST_FILE="${PRIVATE_DIRECTORY}/${NODE_NAME}.node-certificate.csr"

if [ ! -f "${NODE_REQUEST_FILE}" ]; then
    echo "organization = \"${ORGANIZATION}\"
unit = \"${ORGANIZATIONAL_UNIT}\"
state = \"${STATE}\"
country = ${COUNTRY_CODE}
cn = \"${NODE_NAME}\"
dns_name = \"${NODE_NAME}\"
expiration_days = 365
tls_www_server
encryption_key" > "${TEMPLATE}"

    ${CERTTOOL} --generate-request --load-privkey "${NODE_PRIVATE_KEY}" --template "${TEMPLATE}" --outfile "${NODE_REQUEST_FILE}"
fi
