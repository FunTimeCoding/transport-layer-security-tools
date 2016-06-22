#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)
WITH_ADDRESS=false

usage()
{
    echo "Generate a node certificate using the intermediate certificate. Nodes can be services or clients."
    echo "Local usage: ${0} [--with-address] [DOMAIN_LABELS]"
    echo "Example: ${0} # for example.org, the configured DOMAIN_NAME"
    echo "Example: ${0} foo # for foo.example.org"
    echo "Example: ${0} bar.foo # for bar.foo.example.org"
}

if [ "${1}" = --with-address ]; then
    shift
    WITH_ADDRESS=true
fi

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}/../lib/transport-layer-security-tools.sh"
DOMAIN_LABELS="${1}"

if [ "${DOMAIN_LABELS}" = "" ]; then
    NODE_NAME="${DOMAIN_NAME}"
else
    NODE_NAME="${DOMAIN_LABELS}.${DOMAIN_NAME}"
fi

NODE_PRIVATE_KEY="${PRIVATE_DIRECTORY}/${NODE_NAME}.node-private-key.pem"

if [ ! -f "${NODE_PRIVATE_KEY}" ]; then
    ${CERTTOOL} --generate-privkey --outfile "${NODE_PRIVATE_KEY}"
fi

NODE_CERTIFICATE="${PRIVATE_DIRECTORY}/${NODE_NAME}.node-certificate.crt"

if [ ! -f "${NODE_CERTIFICATE}" ]; then
    NODE_REQUEST_FILE="${PRIVATE_DIRECTORY}/${NODE_NAME}.node-certificate.csr"
    INTERMEDIATE_SERIAL=$(cat "${INTERMEDIATE_SERIAL_FILE}")

    if [ "${WITH_ADDRESS}" = true ]; then
        ADDRESS=$(dig +short "${NODE_NAME}")

        if [ "${ADDRESS}" = "" ]; then
            echo "Could not determine the address for ${NODE_NAME}."

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
cn = \"${NODE_NAME}\"
dns_name = \"${NODE_NAME}\"
serial = ${INTERMEDIATE_SERIAL}
expiration_days = 365
uid = \"${USER_NAME}\"
tls_www_server
encryption_key" > "${TEMPLATE}"

    if [ "${WITH_ADDRESS}" = true ]; then
        echo "ip_address = \"${ADDRESS}\"" >> "${TEMPLATE}"
    fi

    ${CERTTOOL} --generate-request --load-privkey "${NODE_PRIVATE_KEY}" --template "${TEMPLATE}" --outfile "${NODE_REQUEST_FILE}"
    ${CERTTOOL} --generate-certificate --load-request "${NODE_REQUEST_FILE}" --load-ca-privkey "${INTERMEDIATE_PRIVATE_KEY}" --load-ca-certificate "${INTERMEDIATE_CERTIFICATE}" --template "${TEMPLATE}" --outfile "${NODE_CERTIFICATE}"
    NEXT_INTERMEDIATE_SERIAL=$(echo "${INTERMEDIATE_SERIAL} + 1" | bc)
    NEXT_INTERMEDIATE_SERIAL=$(printf "%03d" "${NEXT_INTERMEDIATE_SERIAL}")
    echo "${NEXT_INTERMEDIATE_SERIAL}" > "${INTERMEDIATE_SERIAL_FILE}"
    rm "${TEMPLATE}"
    rm "${NODE_REQUEST_FILE}"
fi

NODE_BUNDLE="${PRIVATE_DIRECTORY}/${NODE_NAME}.node-bundle.pem"

if [ ! -f "${NODE_BUNDLE}" ]; then
    touch "${NODE_BUNDLE}"
    chmod 600 "${NODE_BUNDLE}"
    cat "${NODE_PRIVATE_KEY}" >> "${NODE_BUNDLE}"
    cat "${NODE_CERTIFICATE}" >> "${NODE_BUNDLE}"
fi
