#!/bin/sh -e

usage()
{
    echo "Usage: ${0} AUTHORITY_CERTIFICATE ISSUED_CERTIFICATE"
}

AUTHORITY_CERTIFICATE="${1}"
ISSUED_CERTIFICATE="${2}"

if [ "${AUTHORITY_CERTIFICATE}" = "" ] || [ "${ISSUED_CERTIFICATE}" = "" ]; then
    usage

    exit 1
fi

OPERATING_SYSTEM=$(uname)

if [ "${OPERATING_SYSTEM}" = "Darwin" ]; then
    CERTTOOL="gnutls-certtool"
else
    CERTTOOL="certtool"
fi

${CERTTOOL} --verify --load-ca-certificate "${AUTHORITY_CERTIFICATE}" --infile "${ISSUED_CERTIFICATE}"
