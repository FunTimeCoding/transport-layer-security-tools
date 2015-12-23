#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)

usage()
{
    echo "Local usage: ${0}"
}

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}/../lib/transport-layer-security.sh"

# TODO: Make these values dynamic.
COMMON_NAME="${ORGANIZATION} Certificate Authority"
# Certificate serial number. Increment each time a new certificate is generated.
SERIAL="001"

DIRECTORY="private"
cd "${DIRECTORY}" || (echo "Directory not found: ${DIRECTORY}" && exit 1)

# ca - This is a CA certificate.
# cert_signing_key - Certificate will be used to sign other certificates.
# crl_signing_key - Certificate will be used to sign CRLs.
echo "organization = \"${ORGANIZATION}\"
unit = \"${ORGANIZATIONAL_UNIT}\"
state = \"${STATE}\"
country = ${COUNTRY_CODE}
cn = \"${COMMON_NAME}\"
serial = ${SERIAL}
expiration_days = 365
ca
cert_signing_key
crl_signing_key" > "${TEMPLATE}"

if [ -f "${SIGNING_PRIVATE_KEY}" ]; then
    echo "Key exists: ${SIGNING_PRIVATE_KEY}"
else
    ${CERTTOOL} --generate-privkey --outfile "${SIGNING_PRIVATE_KEY}"
fi

if [ -f "${SIGNING_REQUEST_FILE}" ]; then
    echo "CSR exists: ${SIGNING_REQUEST_FILE}"
else
    ${CERTTOOL} --generate-request --template "${TEMPLATE}" --load-privkey "${SIGNING_PRIVATE_KEY}" --outfile "${SIGNING_REQUEST_FILE}"
fi

if [ -f "${SIGNING_CERTIFICATE}" ]; then
    echo "Certificate exists: ${SIGNING_CERTIFICATE}"
else
    ${CERTTOOL} --generate-certificate --load-request "${SIGNING_REQUEST_FILE}" --load-ca-certificate "${AUTHORITY_CERTIFICATE}" --load-ca-privkey "${AUTHORITY_PRIVATE_KEY}" --template "${TEMPLATE}" --outfile "${SIGNING_CERTIFICATE}"
fi

rm "${SIGNING_REQUEST_FILE}"
rm "${TEMPLATE}"
