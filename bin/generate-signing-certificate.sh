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

cd private
${CERTTOOL} --generate-privkey --outfile "${SIGNING_PRIVATE_KEY}"
${CERTTOOL} --generate-request --template "${TEMPLATE}" --load-privkey "${SIGNING_PRIVATE_KEY}" --outfile "${REQUEST_FILE}"
${CERTTOOL} --generate-certificate --load-request "${REQUEST_FILE}" --load-ca-certificate "${AUTHORITY_CERTIFICATE}" --load-ca-privkey "${AUTHORITY_PRIVATE_KEY}" --template "${TEMPLATE}" --outfile "${SIGNING_CERTIFICATE}"

chmod 600 "${SIGNING_CERTIFICATE}"
