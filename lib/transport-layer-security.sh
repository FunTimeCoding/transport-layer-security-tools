#!/bin/sh -e

OPERATING_SYSTEM=$(uname)

if [ "${OPERATING_SYSTEM}" = "Darwin" ]; then
    export CERTTOOL="gnutls-certtool"
else
    export CERTTOOL="certtool"
fi

# TODO: Make this value dynamic.
export FULLY_QUALIFIED_DOMAIN_NAME="shiin.org"

export TEMPLATE="/tmp/certtool_template"

export AUTHORITY_PRIVATE_KEY="${FULLY_QUALIFIED_DOMAIN_NAME}.authority-private-key.pem"
export AUTHORITY_CERTIFICATE="${FULLY_QUALIFIED_DOMAIN_NAME}.authority-certificate.pem"

export SIGNING_PRIVATE_KEY="${FULLY_QUALIFIED_DOMAIN_NAME}.signing-private-key.pem"
export SIGNING_REQUEST_FILE="${FULLY_QUALIFIED_DOMAIN_NAME}.signing-certificate.csr"
export SIGNING_CERTIFICATE="${FULLY_QUALIFIED_DOMAIN_NAME}.signing-certificate.pem"

export ORGANIZATION="Shiin Organization"
export ORGANIZATIONAL_UNIT="Software Development"
export STATE="Baden-Wuerttemberg"
export COUNTRY_CODE="DE"
