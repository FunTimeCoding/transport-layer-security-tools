#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)
WITH_ADDRESS=false

usage()
{
    echo "Generate a wildcard certificate using the intermediate certificate."
    echo "Local usage: ${0} [--with-address] [DOMAIN_LABELS]"
    echo "Example: ${0} # for *.example.org"
    echo "Example: ${0} foo # for *.foo.example.org"
    echo "Example: ${0} bar.foo # for *.bar.foo.example.org"
}

if [ "${1}" = --with-address ]; then
    shift
    WITH_ADDRESS=true
fi

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}/../lib/transport-layer-security-tools.sh"
DOMAIN_LABELS="${1}"

if [ "${DOMAIN_LABELS}" = "" ]; then
    WILDCARD_NAME="${DOMAIN_NAME}"
else
    WILDCARD_NAME="${DOMAIN_LABELS}.${DOMAIN_NAME}"
fi

WILDCARD_PRIVATE_KEY="${PRIVATE_DIRECTORY}/${WILDCARD_NAME}.wildcard-private-key.pem"

if [ ! -f "${WILDCARD_PRIVATE_KEY}" ]; then
    ${CERTTOOL} --generate-privkey --outfile "${WILDCARD_PRIVATE_KEY}"
fi

WILDCARD_CERTIFICATE="${PRIVATE_DIRECTORY}/${WILDCARD_NAME}.wildcard-certificate.crt"

if [ ! -f "${WILDCARD_CERTIFICATE}" ]; then
    INTERMEDIATE_SERIAL=$(cat "${INTERMEDIATE_SERIAL_FILE}")
    USER_NAME=$(whoami)
    # tls_www_server - This certificate will be used for a TLS server.
    # encryption_key - This certificate will be used to encrypt data. Needed in TLS RSA cipher-suites. Its preferred to use different keys for encryption and signing.
    echo "organization = \"${ORGANIZATION}\"
unit = \"${ORGANIZATIONAL_UNIT}\"
state = \"${STATE}\"
country = ${COUNTRY_CODE}
cn = \"*.${WILDCARD_NAME}\"
dns_name = \"*.${WILDCARD_NAME}\"
serial = ${INTERMEDIATE_SERIAL}
expiration_days = 365
uid = \"${USER_NAME}\"
tls_www_server
encryption_key" > "${TEMPLATE}"

    if [ "${WITH_ADDRESS}" = true ]; then
        ADDRESS=$(dig +short "${WILDCARD_NAME}")

        if [ "${ADDRESS}" = "" ]; then
            echo "Could not determine the address for ${WILDCARD_NAME}."

            exit 1
        fi

        echo "ip_address = \"${ADDRESS}\"" >> "${TEMPLATE}"
    fi

    WILDCARD_REQUEST_FILE="${WILDCARD_NAME}.wildcard-certificate.csr"
    ${CERTTOOL} --generate-request --load-privkey "${WILDCARD_PRIVATE_KEY}" --template "${TEMPLATE}" --outfile "${WILDCARD_REQUEST_FILE}"
    ${CERTTOOL} --generate-certificate --load-request "${WILDCARD_REQUEST_FILE}" --load-ca-privkey "${INTERMEDIATE_PRIVATE_KEY}" --load-ca-certificate "${INTERMEDIATE_CERTIFICATE}" --template "${TEMPLATE}" --outfile "${WILDCARD_CERTIFICATE}"
    NEXT_INTERMEDIATE_SERIAL=$(echo "${INTERMEDIATE_SERIAL} + 1" | bc)
    NEXT_INTERMEDIATE_SERIAL=$(printf "%03d" "${NEXT_INTERMEDIATE_SERIAL}")
    echo "${NEXT_INTERMEDIATE_SERIAL}" > "${INTERMEDIATE_SERIAL_FILE}"
    rm "${TEMPLATE}"
    rm "${WILDCARD_REQUEST_FILE}"
fi

WILDCARD_BUNDLE="${PRIVATE_DIRECTORY}/${WILDCARD_NAME}.wildcard-bundle.pem"

if [ ! -f "${WILDCARD_BUNDLE}" ]; then
    touch "${WILDCARD_BUNDLE}"
    chmod 600 "${WILDCARD_BUNDLE}"
    cat "${WILDCARD_PRIVATE_KEY}" >> "${WILDCARD_BUNDLE}"
    cat "${WILDCARD_CERTIFICATE}" >> "${WILDCARD_BUNDLE}"
fi
