#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)
WITH_ADDRESS=false

usage()
{
    echo "Generate a wildcard certificate using the intermediate certificate."
    echo "Local usage: ${0} [--with-address]"
    echo "Example: ${0}"
}

if [ "${1}" = --with-address ]; then
    shift
    WITH_ADDRESS=true
fi

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}/../lib/transport-layer-security-tools.sh"

cd "${PRIVATE_DIRECTORY}" || (echo "Directory '${PRIVATE_DIRECTORY}' not found." && exit 1)
SERIAL_FILE="${DOMAIN_NAME}.certificate_serial.txt"

if [ ! -f "${SERIAL_FILE}" ]; then
    echo 001 > "${SERIAL_FILE}"
fi

SERIAL=$(cat "${SERIAL_FILE}")
COMMON_NAME="*.${DOMAIN_NAME}"

if [ "${WITH_ADDRESS}" = true ]; then
    ADDRESS=$(dig +short "${DOMAIN_NAME}")

    if [ "${ADDRESS}" = "" ]; then
        echo "Could not determine the address for ${DOMAIN_NAME}."

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
dns_name = \"${DOMAIN_NAME}\"
serial = ${SERIAL}
expiration_days = 365
uid = \"${USER_NAME}\"
tls_www_server
encryption_key" > "${TEMPLATE}"

if [ "${WITH_ADDRESS}" = true ]; then
    echo "ip_address = \"${ADDRESS}\"" >> "${TEMPLATE}"
fi

WILDCARD_PRIVATE_KEY="${DOMAIN_NAME}.wildcard-private-key.pem"
WILDCARD_CERTIFICATE="${DOMAIN_NAME}.wildcard-certificate.crt"

if [ -f "${WILDCARD_PRIVATE_KEY}" ]; then
    echo "WILDCARD_PRIVATE_KEY already exists: ${WILDCARD_PRIVATE_KEY}"
else
    ${CERTTOOL} --generate-privkey --outfile "${WILDCARD_PRIVATE_KEY}"
fi

if [ -f "${WILDCARD_CERTIFICATE}" ]; then
    echo "WILDCARD_CERTIFICATE already exists: ${WILDCARD_CERTIFICATE}"
else
    WILDCARD_REQUEST_FILE="${DOMAIN_NAME}.wildcard-certificate.csr"
    ${CERTTOOL} --generate-request --load-privkey "${WILDCARD_PRIVATE_KEY}" --template "${TEMPLATE}" --outfile "${WILDCARD_REQUEST_FILE}"
    ${CERTTOOL} --generate-certificate --load-request "${WILDCARD_REQUEST_FILE}" --load-ca-privkey "${INTERMEDIATE_PRIVATE_KEY}" --load-ca-certificate "${INTERMEDIATE_CERTIFICATE}" --template "${TEMPLATE}" --outfile "${WILDCARD_CERTIFICATE}"
    rm "${WILDCARD_REQUEST_FILE}"
fi

NEXT_SERIAL=$(echo "${SERIAL} + 1" | bc)
NEXT_SERIAL=$(printf "%03d" "${NEXT_SERIAL}")
echo "${NEXT_SERIAL}" > "${SERIAL_FILE}"
rm "${TEMPLATE}"
