#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}"; pwd)

usage()
{
    echo "Local usage: ${0}"
}

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
crl_signing_key" > ${TEMPLATE}

${CERTTOOL} --generate-privkey --outfile "${SIGNING_PRIVATE_KEY}"
${CERTTOOL} --generate-request --template "${TEMPLATE}" --load-privkey "${SIGNING_PRIVATE_KEY}" --outfile "${SIGNING_REQUEST_FILE}"
${CERTTOOL} --generate-certificate --load-request "${SIGNING_REQUEST_FILE}" --load-ca-certificate "${AUTHORITY_CERTIFICATE}" --load-ca-privkey "${AUTHORITY_PRIVATE_KEY}" --template "${TEMPLATE}" --outfile "${SIGNING_CERTIFICATE}"
rm "${SIGNING_REQUEST_FILE}"
rm "${TEMPLATE}"
