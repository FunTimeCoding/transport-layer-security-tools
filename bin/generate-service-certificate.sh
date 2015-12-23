#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}"; pwd)

usage()
{
    echo "Local usage: ${0} SERVICE_NAME"
}

. "${SCRIPT_DIRECTORY}/../lib/transport-layer-security.sh"

SERVICE_NAME="${1}"

if [ "${SERVICE_NAME}" = "" ]; then
    usage

    exit 1
fi

# TODO: Make these values dynamic.
COMMON_NAME="Alexander Reitzel"
# Certificate serial number. Increment each time a new certificate is generated.
SERIAL="001"

SERVICE_PRIVATE_KEY="${SERVICE_NAME}.${FULLY_QUALIFIED_DOMAIN_NAME}.service-private-key.pem"
SERVICE_REQUEST_FILE="${SERVICE_NAME}.${FULLY_QUALIFIED_DOMAIN_NAME}.service-certificate.csr"
SERVICE_CERTIFICATE="${SERVICE_NAME}.${FULLY_QUALIFIED_DOMAIN_NAME}.service-certificate.pem"
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

if [ -f "${SERVICE_PRIVATE_KEY}" ]; then
    echo "Key exists: ${SERVICE_PRIVATE_KEY}"
else
    ${CERTTOOL} --generate-privkey --outfile "${SERVICE_PRIVATE_KEY}"
fi

if [ -f "${SERVICE_REQUEST_FILE}" ]; then
    echo "CSR exists: ${SERVICE_REQUEST_FILE}"
else
    ${CERTTOOL} --generate-request --template "${TEMPLATE}" --load-privkey "${SERVICE_PRIVATE_KEY}" --outfile "${SERVICE_REQUEST_FILE}"
fi

if [ -f "${SERVICE_CERTIFICATE}" ]; then
    echo "Certificate exists: ${SERVICE_CERTIFICATE}"
else
    ${CERTTOOL} --generate-certificate --load-request "${SERVICE_REQUEST_FILE}" --load-ca-certificate "${SIGNING_CERTIFICATE}" --load-ca-privkey "${SIGNING_PRIVATE_KEY}" --template "${TEMPLATE}" --outfile "${SERVICE_CERTIFICATE}"
fi

rm "${SERVICE_REQUEST_FILE}"
rm "${TEMPLATE}"
