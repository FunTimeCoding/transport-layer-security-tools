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

AUTHORITY_PRIVATE_KEY="${FULLY_QUALIFIED_DOMAIN_NAME}.authority-private-key.pem"
AUTHORITY_CERTIFICATE="${FULLY_QUALIFIED_DOMAIN_NAME}.authority-certificate.pem"
SIGNING_PRIVATE_KEY="${FULLY_QUALIFIED_DOMAIN_NAME}.signing-private-key.pem"
${CERTTOOL} --generate-privkey --outfile ${SIGNING_PRIVATE_KEY}
REQUEST_FILE="${FULLY_QUALIFIED_DOMAIN_NAME}.signing-certificate.csr"
${CERTTOOL} --generate-request --template signing_template --load-privkey ${SIGNING_PRIVATE_KEY} --outfile ${REQUEST_FILE}
SIGNING_CERTIFICATE="${FULLY_QUALIFIED_DOMAIN_NAME}.signing-certificate.pem"
${CERTTOOL} --generate-certificate --load-request ${REQUEST_FILE} --load-ca-certificate ${AUTHORITY_CERTIFICATE} --load-ca-privkey ${AUTHORITY_PRIVATE_KEY} --template encryption_template --outfile ${SIGNING_CERTIFICATE}

chmod 600 ${SIGNING_CERTIFICATE}
