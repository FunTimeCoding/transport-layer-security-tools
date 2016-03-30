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
cd "${PRIVATE_DIRECTORY}" || (echo "Directory '${PRIVATE_DIRECTORY}' not found." && exit 1)
# ca - This is a CA certificate.
# cert_signing_key - Certificate will be used to sign other certificates.
# crl_signing_key - Certificate will be used to sign CRLs.
echo "organization = \"${ORGANIZATION}\"
unit = \"${ORGANIZATIONAL_UNIT}\"
state = \"${STATE}\"
country = ${COUNTRY_CODE}
cn = \"${ORGANIZATION} Certificate Authority\"
serial = 001
expiration_days = 365
ca
cert_signing_key
crl_signing_key" > "${TEMPLATE}"

if [ -f "${AUTHORITY_PRIVATE_KEY}" ]; then
    echo "AUTHORITY_PRIVATE_KEY already exists: ${AUTHORITY_PRIVATE_KEY}"
else
    ${CERTTOOL} --generate-privkey --outfile "${AUTHORITY_PRIVATE_KEY}"
fi

if [ -f "${AUTHORITY_CERTIFICATE}" ]; then
    echo "AUTHORITY_CERTIFICATE already exists: ${AUTHORITY_CERTIFICATE}"
else
    ${CERTTOOL} --generate-self-signed --load-privkey "${AUTHORITY_PRIVATE_KEY}" --template "${TEMPLATE}" --outfile "${AUTHORITY_CERTIFICATE}"
fi

cat "${AUTHORITY_CERTIFICATE}" > "${CERTIFICATE_CHAIN}"

echo "organization = \"${ORGANIZATION}\"
unit = \"${ORGANIZATIONAL_UNIT}\"
state = \"${STATE}\"
country = ${COUNTRY_CODE}
cn = \"${ORGANIZATION} Intermediate\"
serial = 001
expiration_days = 365
ca
cert_signing_key
crl_signing_key" > "${TEMPLATE}"

if [ -f "${INTERMEDIATE_PRIVATE_KEY}" ]; then
    echo "INTERMEDIATE_PRIVATE_KEY already exists: ${INTERMEDIATE_PRIVATE_KEY}"
else
    ${CERTTOOL} --generate-privkey --outfile "${INTERMEDIATE_PRIVATE_KEY}"
fi

if [ -f "${INTERMEDIATE_CERTIFICATE}" ]; then
    echo "INTERMEDIATE_CERTIFICATE already exists: ${INTERMEDIATE_CERTIFICATE}"
else
    INTERMEDIATE_REQUEST_FILE="${DOMAIN_NAME}.intermediate-certificate.csr"
    ${CERTTOOL} --generate-request --load-privkey "${INTERMEDIATE_PRIVATE_KEY}" --template "${TEMPLATE}" --outfile "${INTERMEDIATE_REQUEST_FILE}"
    ${CERTTOOL} --generate-certificate --load-request "${INTERMEDIATE_REQUEST_FILE}" --load-ca-privkey "${AUTHORITY_PRIVATE_KEY}" --load-ca-certificate "${AUTHORITY_CERTIFICATE}" --template "${TEMPLATE}" --outfile "${INTERMEDIATE_CERTIFICATE}"
    rm "${INTERMEDIATE_REQUEST_FILE}"
fi

cat "${INTERMEDIATE_CERTIFICATE}" >> "${CERTIFICATE_CHAIN}"

rm "${TEMPLATE}"
