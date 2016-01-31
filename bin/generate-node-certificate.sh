#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)
WITH_ADDRESS=false

usage()
{
    echo "Generate a node certificate using the intermediate certificate. Nodes can be services or clients."
    echo "Local usage: ${0} [--with-address] NODE_NAME"
    echo "Example: ${0} ldap"
}

if [ "${1}" = "--with-address" ]; then
    shift
    WITH_ADDRESS=true
fi

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}/../lib/transport-layer-security.sh"
NODE_NAME="${1}"

if [ "${NODE_NAME}" = "" ]; then
    usage

    exit 1
fi

cd "${PRIVATE_DIRECTORY}" || (echo "Directory '${PRIVATE_DIRECTORY}' not found." && exit 1)
SERIAL_FILE="${DOMAIN_NAME}.node_certificate_serial.txt"

if [ ! -f "${SERIAL_FILE}" ]; then
    echo "001" > "${SERIAL_FILE}"
fi

SERIAL=$(cat "${SERIAL_FILE}")
COMMON_NAME="${NODE_NAME}.${DOMAIN_NAME}"

if [ "${WITH_ADDRESS}" = true ]; then
    ADDRESS=$(dig +short "${COMMON_NAME}")

    if [ "${ADDRESS}" = "" ]; then
        echo "Could not determine the address for ${COMMON_NAME}."

        exit 1
    fi
fi

USER_NAME=$(whoami)
# tls_www_server - This certificate will be used for a TLS server.
# encryption_key - This certificate will be used to encrypt data. Needed in TLS RSA cipher-suites. Its preferred to use different keys for encryption and signing.
echo "organization = \"${ORGANIZATION}\"
unit = \"${ORGANIZATIONAL_UNIT}\"
state = \"${STATE}\"
country = ${COUNTRY_CODE}
cn = \"${COMMON_NAME}\"
serial = ${SERIAL}
expiration_days = 365
uid = \"${USER_NAME}\"
dns_name = \"${DOMAIN_NAME}\"
tls_www_server
encryption_key" > "${TEMPLATE}"

if [ "${WITH_ADDRESS}" = true ]; then
    echo "ip_address = \"${ADDRESS}\"" >> "${TEMPLATE}"
fi

NODE_PRIVATE_KEY="${NODE_NAME}.${DOMAIN_NAME}.node-private-key.pem"
NODE_CERTIFICATE="${NODE_NAME}.${DOMAIN_NAME}.node-certificate.crt"

if [ -f "${NODE_PRIVATE_KEY}" ]; then
    echo "NODE_PRIVATE_KEY already exists: ${NODE_PRIVATE_KEY}"
else
    ${CERTTOOL} --generate-privkey --outfile "${NODE_PRIVATE_KEY}"
fi

if [ -f "${NODE_CERTIFICATE}" ]; then
    echo "NODE_CERTIFICATE already exists: ${NODE_CERTIFICATE}"
else
    NODE_REQUEST_FILE="${NODE_NAME}.${DOMAIN_NAME}.node-certificate.csr"
    ${CERTTOOL} --generate-request --template "${TEMPLATE}" --load-privkey "${NODE_PRIVATE_KEY}" --outfile "${NODE_REQUEST_FILE}"
    ${CERTTOOL} --generate-certificate --load-request "${NODE_REQUEST_FILE}" --load-ca-certificate "${INTERMEDIATE_CERTIFICATE}" --load-ca-privkey "${INTERMEDIATE_PRIVATE_KEY}" --template "${TEMPLATE}" --outfile "${NODE_CERTIFICATE}"
    rm "${NODE_REQUEST_FILE}"
fi

NEXT_SERIAL=$(echo "${SERIAL} + 1" | bc)
NEXT_SERIAL=$(printf "%03d" "${NEXT_SERIAL}")
echo "${NEXT_SERIAL}" > "${SERIAL_FILE}"
rm "${TEMPLATE}"
