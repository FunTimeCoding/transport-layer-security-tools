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

SIGNING_PRIVATE_KEY="${FULLY_QUALIFIED_DOMAIN_NAME}.signing-private-key.pem"
SIGNING_CERTIFICATE="${FULLY_QUALIFIED_DOMAIN_NAME}.signing-certificate.pem"
ARBITRARY_PRIVATE_KEY="${FULLY_QUALIFIED_DOMAIN_NAME}.arbitrary-private-key.pem"
${CERTTOOL} --generate-privkey --outfile ${ARBITRARY_PRIVATE_KEY}
REQUEST_FILE="${FULLY_QUALIFIED_DOMAIN_NAME}.arbitrary-certificate.csr"
${CERTTOOL} --generate-request --template encryption_template --load-privkey ${ARBITRARY_PRIVATE_KEY} --outfile ${REQUEST_FILE}
ARBITRARY_CERTIFICATE="${FULLY_QUALIFIED_DOMAIN_NAME}.arbitrary-certificate.pem"
${CERTTOOL} --generate-certificate --load-request ${REQUEST_FILE} --load-ca-certificate ${SIGNING_CERTIFICATE} --load-ca-privkey ${SIGNING_PRIVATE_KEY} --template encryption_template --outfile ${ARBITRARY_CERTIFICATE}

chmod 600 ${ARBITRARY_CERTIFICATE}
