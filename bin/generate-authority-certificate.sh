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

${CERTTOOL} --generate-privkey --outfile "${AUTHORITY_PRIVATE_KEY}"
${CERTTOOL} --generate-self-signed --template "${TEMPLATE}" --load-privkey "${AUTHORITY_PRIVATE_KEY}" --outfile "${AUTHORITY_CERTIFICATE}"
