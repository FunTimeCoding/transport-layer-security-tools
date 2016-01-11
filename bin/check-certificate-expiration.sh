#!/bin/sh -e

usage()
{
    echo "Usage: ${0} FILE_NAME"
}

FILE_NAME="${1}"

if [ "${FILE_NAME}" = "" ]; then
    usage

    exit 1
fi

OPERATING_SYSTEM=$(uname)

if [ "${OPERATING_SYSTEM}" = "Darwin" ]; then
    CERTTOOL="gnutls-certtool"
else
    CERTTOOL="certtool"
fi

VALIDITY=$(${CERTTOOL} --certificate-info --infile "${FILE_NAME}" | grep Validity -A 2 | grep After | xargs)
VALIDITY="${VALIDITY#*: }"
EXPIRATION_TIME=$(gdate -d "${VALIDITY}" +"%s")
NOW=$(gdate +"%s")
SECONDS=$((${EXPIRATION_TIME} - ${NOW}))
DAYS=$((${SECONDS} / 60 / 60 / 24))
echo "${DAYS}"
