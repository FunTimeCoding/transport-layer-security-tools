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
${CERTTOOL} --generate-privkey --outfile ${AUTHORITY_PRIVATE_KEY}

AUTHORITY_CERTIFICATE="${FULLY_QUALIFIED_DOMAIN_NAME}.authority-certificate.pem"
${CERTTOOL} --generate-self-signed --template encryption_template --load-privkey ${AUTHORITY_PRIVATE_KEY} --outfile ${AUTHORITY_CERTIFICATE}

chmod 600 ${AUTHORITY_CERTIFICATE}
