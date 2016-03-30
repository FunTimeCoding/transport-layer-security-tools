#!/bin/sh -e

usage()
{
    echo "Usage: ${0} ISSUER_CERTIFICATE ISSUED_CERTIFICATE"
}

ISSUER_CERTIFICATE="${1}"
ISSUED_CERTIFICATE="${2}"

if [ "${ISSUER_CERTIFICATE}" = "" ] || [ "${ISSUED_CERTIFICATE}" = "" ]; then
    usage

    exit 1
fi

OPERATING_SYSTEM=$(uname)

if [ "${OPERATING_SYSTEM}" = "Darwin" ]; then
    CERTTOOL="gnutls-certtool"
else
    CERTTOOL="certtool"
fi

${CERTTOOL} --verify --load-ca-certificate "${ISSUER_CERTIFICATE}" --infile "${ISSUED_CERTIFICATE}"
