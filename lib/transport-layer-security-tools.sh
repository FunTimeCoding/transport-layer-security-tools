#!/bin/sh -e

if [ "$(command -v realpath || true)" = "" ]; then
    echo "Command not found: realpath"

    exit 1
fi

function_exists()
{
    declare -f -F "${1}" > /dev/null

    return $?
}

CONFIG="${HOME}/.transport-layer-security-tools.conf"

while true; do
    case ${1} in
        --config)
            CONFIG=${2-}
            shift 2
            ;;
        --help)
            echo "Global usage: [--help][--config CONFIG]"

            if function_exists usage; then
                usage
            fi

            exit 0
            ;;
        *)
            break
            ;;
    esac
done

OPTIND=1

if [ -f "${CONFIG}" ]; then
    CONFIG=$(realpath "${CONFIG}")
else
    echo "Config missing: ${CONFIG}"

    exit 1;
fi

# shellcheck source=/dev/null
. "${CONFIG}"

validate_config()
{
    if [ "${DOMAIN_NAME}" = "" ]; then
        echo "DOMAIN_NAME not set."

        exit 1;
    fi

    if [ "${ORGANIZATION}" = "" ]; then
        echo "ORGANIZATION not set."

        exit 1;
    fi

    if [ "${ORGANIZATIONAL_UNIT}" = "" ]; then
        echo "ORGANIZATIONAL_UNIT not set."

        exit 1;
    fi

    if [ "${STATE}" = "" ]; then
        echo "STATE not set."

        exit 1;
    fi

    if [ "${COUNTRY_CODE}" = "" ]; then
        echo "COUNTRY_CODE not set."

        exit 1;
    fi
}

validate_config

define_library_variables()
{
    OPERATING_SYSTEM=$(uname)

    if [ "${OPERATING_SYSTEM}" = Darwin ]; then
        CERTTOOL=gnutls-certtool
    else
        CERTTOOL=certtool
    fi

    export CERTTOOL
    TEMPLATE=/tmp/certtool_template
    export TEMPLATE

    if [ "${PRIVATE_DIRECTORY}" = "" ]; then
        PRIVATE_DIRECTORY=private
    fi

    export PRIVATE_DIRECTORY

    if [ ! -d "${PRIVATE_DIRECTORY}" ]; then
        echo "Directory not found: ${PRIVATE_DIRECTORY}"

        exit 1
    fi

    AUTHORITY_PRIVATE_KEY="${PRIVATE_DIRECTORY}/${DOMAIN_NAME}.authority-private-key.pem"
    export AUTHORITY_PRIVATE_KEY

    AUTHORITY_CERTIFICATE="${PRIVATE_DIRECTORY}/${DOMAIN_NAME}.authority-certificate.crt"
    export AUTHORITY_CERTIFICATE

    INTERMEDIATE_PRIVATE_KEY="${PRIVATE_DIRECTORY}/${DOMAIN_NAME}.intermediate-private-key.pem"
    export INTERMEDIATE_PRIVATE_KEY

    INTERMEDIATE_CERTIFICATE="${PRIVATE_DIRECTORY}/${DOMAIN_NAME}.intermediate-certificate.crt"
    export INTERMEDIATE_CERTIFICATE

    CERTIFICATE_CHAIN="${PRIVATE_DIRECTORY}/${DOMAIN_NAME}.certificate-chain.pem"
    export CERTIFICATE_CHAIN

    # The serial number is counted for the issuer name.
    # The issuer is the C=DE,O=... string.
    AUTHORITY_SERIAL_FILE="${PRIVATE_DIRECTORY}/next-authority-serial.txt"
    export AUTHORITY_SERIAL_FILE

    if [ ! -f "${AUTHORITY_SERIAL_FILE}" ]; then
        echo 001 > "${AUTHORITY_SERIAL_FILE}"
    fi

    AUTHORITY_SERIAL=$(cat "${AUTHORITY_SERIAL_FILE}")
    export AUTHORITY_SERIAL

    INTERMEDIATE_SERIAL_FILE="${PRIVATE_DIRECTORY}/next-intermediate-serial.txt"
    export INTERMEDIATE_SERIAL_FILE


    if [ ! -f "${INTERMEDIATE_SERIAL_FILE}" ]; then
        echo 001 > "${INTERMEDIATE_SERIAL_FILE}"
    fi

    INTERMEDIATE_SERIAL=$(cat "${INTERMEDIATE_SERIAL_FILE}")
    export INTERMEDIATE_SERIAL
}

define_library_variables
