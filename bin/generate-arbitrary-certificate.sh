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

TEMPLATE="../template/encryption_template"
SIGNING_PRIVATE_KEY="${FULLY_QUALIFIED_DOMAIN_NAME}.signing-private-key.pem"
SIGNING_CERTIFICATE="${FULLY_QUALIFIED_DOMAIN_NAME}.signing-certificate.pem"
ARBITRARY_PRIVATE_KEY="${FULLY_QUALIFIED_DOMAIN_NAME}.arbitrary-private-key.pem"
REQUEST_FILE="${FULLY_QUALIFIED_DOMAIN_NAME}.arbitrary-certificate.csr"
ARBITRARY_CERTIFICATE="${FULLY_QUALIFIED_DOMAIN_NAME}.arbitrary-certificate.pem"

ORGANIZATION="Shiin Organization"
ORGANIZATIONAL_UNIT="Software Development"
STATE="Baden-Wuerttemberg"
COUNTRY_CODE="DE"
COMMON_NAME="${ORGANIZATION} Certificate Authority"
# Certificate serial number. Increment each time a new certificate is generated.
SERIAL="001"
ADDRESS=$(arp -n "${FULLY_QUALIFIED_DOMAIN_NAME}" | sed "s/.*(\([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\)).*/\1/g")
USER_NAME=$(whoami)

DIRECTORY="private"
cd "${DIRECTORY}" || (echo "Directory not found: ${DIRECTORY}" && exit 1)

# tls_www_server - This certificate will be used for a TLS server.
# encryption_key - This certificate will be used to encrypt data. Needed in TLS RSA cipher-suites. Its preferred to use different keys for encryption and signing.

echo "organization = \"${ORGANIZATION}\"
unit = \"${ORGANIZATIONAL_UNIT}\"
state = \"${STATE}\"
country = ${COUNTRY_CODE}
cn = \"${COMMON_NAME}\"
serial = ${SERIAL}
expiration_days = 365
uid = \"${USER_NAME}\"
dns_name = \"${FULLY_QUALIFIED_DOMAIN_NAME}\"
ip_address = \"${ADDRESS}\"
tls_www_server
encryption_key" > ${TEMPLATE}

${CERTTOOL} --generate-privkey --outfile "${ARBITRARY_PRIVATE_KEY}"
${CERTTOOL} --generate-request --template "${TEMPLATE}" --load-privkey "${ARBITRARY_PRIVATE_KEY}" --outfile "${REQUEST_FILE}"
${CERTTOOL} --generate-certificate --load-request "${REQUEST_FILE}" --load-ca-certificate "${SIGNING_CERTIFICATE}" --load-ca-privkey "${SIGNING_PRIVATE_KEY}" --template "${TEMPLATE}" --outfile "${ARBITRARY_CERTIFICATE}"
