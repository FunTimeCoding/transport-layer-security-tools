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

${CERTTOOL} --generate-privkey --outfile "${AUTHORITY_PRIVATE_KEY}"
${CERTTOOL} --generate-self-signed --template "${TEMPLATE}" --load-privkey "${AUTHORITY_PRIVATE_KEY}" --outfile "${AUTHORITY_CERTIFICATE}"
rm "${TEMPLATE}"
