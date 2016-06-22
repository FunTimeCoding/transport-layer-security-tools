#!/bin/sh -e

FILE_NAME="${1}"

if [ "${FILE_NAME}" = "" ]; then
    echo "Usage: ${0} FILE_NAME"

    exit 1
fi

OPERATING_SYSTEM=$(uname)

if [ "${OPERATING_SYSTEM}" = Darwin ]; then
    CERTTOOL=gnutls-certtool
else
    CERTTOOL=certtool
fi

${CERTTOOL} --certificate-info --infile "${FILE_NAME}"
