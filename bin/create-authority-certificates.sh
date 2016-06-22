#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)

usage()
{
    echo "Generate an authority and an intermediate certificate for generating node certificates."
    echo "Local usage: ${0}"
}

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}/../lib/transport-layer-security-tools.sh"

if [ ! -f "${AUTHORITY_PRIVATE_KEY}" ]; then
    ${CERTTOOL} --generate-privkey --outfile "${AUTHORITY_PRIVATE_KEY}"
fi

if [ ! -f "${AUTHORITY_CERTIFICATE}" ]; then
    AUTHORITY_SERIAL=$(cat "${AUTHORITY_SERIAL_FILE}")
    # ca - This is a CA certificate.
    # cert_signing_key - Certificate will be used to sign other certificates.
    # crl_signing_key - Certificate will be used to sign CRLs.
    echo "organization = \"${ORGANIZATION}\"
unit = \"${ORGANIZATIONAL_UNIT}\"
state = \"${STATE}\"
country = ${COUNTRY_CODE}
cn = \"${ORGANIZATION} Certificate Authority\"
serial = ${AUTHORITY_SERIAL}
expiration_days = 365
ca
cert_signing_key
crl_signing_key" > "${TEMPLATE}"
    ${CERTTOOL} --generate-self-signed --load-privkey "${AUTHORITY_PRIVATE_KEY}" --template "${TEMPLATE}" --outfile "${AUTHORITY_CERTIFICATE}"
    NEXT_AUTHORITY_SERIAL=$(echo "${AUTHORITY_SERIAL} + 1" | bc)
    NEXT_AUTHORITY_SERIAL=$(printf "%03d" "${NEXT_AUTHORITY_SERIAL}")
    echo "${NEXT_AUTHORITY_SERIAL}" > "${AUTHORITY_SERIAL_FILE}"
    cat "${AUTHORITY_CERTIFICATE}" > "${CERTIFICATE_CHAIN}"
    rm "${TEMPLATE}"
fi

if [ ! -f "${INTERMEDIATE_PRIVATE_KEY}" ]; then
    ${CERTTOOL} --generate-privkey --outfile "${INTERMEDIATE_PRIVATE_KEY}"
fi

if [ ! -f "${INTERMEDIATE_CERTIFICATE}" ]; then
    AUTHORITY_SERIAL=$(cat "${AUTHORITY_SERIAL_FILE}")
    echo "organization = \"${ORGANIZATION}\"
unit = \"${ORGANIZATIONAL_UNIT}\"
state = \"${STATE}\"
country = ${COUNTRY_CODE}
cn = \"${ORGANIZATION} Intermediate\"
serial = ${AUTHORITY_SERIAL}
expiration_days = 365
ca
cert_signing_key
crl_signing_key" > "${TEMPLATE}"
    INTERMEDIATE_REQUEST_FILE="${PRIVATE_DIRECTORY}/${DOMAIN_NAME}.intermediate-certificate.csr"
    ${CERTTOOL} --generate-request --load-privkey "${INTERMEDIATE_PRIVATE_KEY}" --template "${TEMPLATE}" --outfile "${INTERMEDIATE_REQUEST_FILE}"
    ${CERTTOOL} --generate-certificate --load-request "${INTERMEDIATE_REQUEST_FILE}" --load-ca-privkey "${AUTHORITY_PRIVATE_KEY}" --load-ca-certificate "${AUTHORITY_CERTIFICATE}" --template "${TEMPLATE}" --outfile "${INTERMEDIATE_CERTIFICATE}"
    NEXT_AUTHORITY_SERIAL=$(echo "${AUTHORITY_SERIAL} + 1" | bc)
    NEXT_AUTHORITY_SERIAL=$(printf "%03d" "${NEXT_AUTHORITY_SERIAL}")
    echo "${NEXT_AUTHORITY_SERIAL}" > "${AUTHORITY_SERIAL_FILE}"
    cat "${INTERMEDIATE_CERTIFICATE}" >> "${CERTIFICATE_CHAIN}"
    rm "${TEMPLATE}"
    rm "${INTERMEDIATE_REQUEST_FILE}"
fi
