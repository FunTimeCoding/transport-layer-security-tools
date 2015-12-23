#!/bin/sh -e

usage()
{
    echo "Usage: ${0} FULLY_QUALIFIED_DOMAIN_NAME"
}

FULLY_QUALIFIED_DOMAIN_NAME="${1}"

if [ "${FULLY_QUALIFIED_DOMAIN_NAME}" = "" ]; then
    usage

    exit 1
fi

OPERATING_SYSTEM=$(uname)

if [ "${OPERATING_SYSTEM}" = "Darwin" ]; then
    CERTTOOL="gnutls-certtool"
else
    CERTTOOL="certtool"
fi

TEMPLATE="../template/signing_template"
AUTHORITY_PRIVATE_KEY="${FULLY_QUALIFIED_DOMAIN_NAME}.authority-private-key.pem"
AUTHORITY_CERTIFICATE="${FULLY_QUALIFIED_DOMAIN_NAME}.authority-certificate.pem"
SIGNING_PRIVATE_KEY="${FULLY_QUALIFIED_DOMAIN_NAME}.signing-private-key.pem"
REQUEST_FILE="${FULLY_QUALIFIED_DOMAIN_NAME}.signing-certificate.csr"
SIGNING_CERTIFICATE="${FULLY_QUALIFIED_DOMAIN_NAME}.signing-certificate.pem"

ORGANIZATION="Shiin Organization"
ORGANIZATIONAL_UNIT="Software Development"
STATE="Baden-Wuerttemberg"
COUNTRY_CODE="DE"
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
${CERTTOOL} --generate-request --template "${TEMPLATE}" --load-privkey "${SIGNING_PRIVATE_KEY}" --outfile "${REQUEST_FILE}"
${CERTTOOL} --generate-certificate --load-request "${REQUEST_FILE}" --load-ca-certificate "${AUTHORITY_CERTIFICATE}" --load-ca-privkey "${AUTHORITY_PRIVATE_KEY}" --template "${TEMPLATE}" --outfile "${SIGNING_CERTIFICATE}"
