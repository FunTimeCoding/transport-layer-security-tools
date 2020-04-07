#!/bin/sh -e

FILE_NAME="${1}"

if [ "${FILE_NAME}" = "" ]; then
    echo "Usage: ${0} FILE_NAME"

    exit 1
fi

OPERATING_SYSTEM=$(uname)

if [ "${OPERATING_SYSTEM}" = Darwin ]; then
    CERTTOOL='gnutls-certtool'
    DATE='gdate'
else
    CERTTOOL='certtool'
    DATE='date'
fi

VALIDITY=$(${CERTTOOL} --certificate-info --infile "${FILE_NAME}" | grep Validity -A 2 | grep After | xargs)
VALIDITY="${VALIDITY#*: }"
EXPIRE_TIME=$(${DATE} -d "${VALIDITY}" +"%s")
NOW=$(${DATE} +"%s")
EXPIRE_SECONDS=$(echo "${EXPIRE_TIME} - ${NOW}" | bc)
EXPIRE_DAYS=$(echo "${EXPIRE_SECONDS} / 60 / 60 / 24" | bc)
echo "${EXPIRE_DAYS}"

echo "The OpenSSL way. TODO: Decide on which to rely on?"
openssl x509 -enddate -noout -in "${FILE_NAME}"
