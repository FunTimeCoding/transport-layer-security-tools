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

${CERTTOOL} --key-info --infile "${FILE_NAME}"
