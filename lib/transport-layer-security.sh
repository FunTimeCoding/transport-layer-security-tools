#!/bin/sh -e

SCRIPT_DIR=$(cd "$(dirname "${0}")"; pwd)
CONFIG=""
VERBOSE=false

function_exists()
{
    declare -f -F "${1}" > /dev/null

    return $?
}

while true; do
    case ${1} in
        -c|--config)
            CONFIG=${2-}
            shift 2
            ;;
        -h|--help)
            echo "Global usage: [-v|--verbose][-d|--debug][-h|--help][-c|--config CONFIG]"
            function_exists usage && usage

            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            echo "Verbose mode enabled."
            shift
            ;;
        -d|--debug)
            set -x
            shift
            ;;
        *)
            break
            ;;
    esac
done

OPTIND=1

find_config()
{
    if [ "${VERBOSE}" = true ]; then
        echo "find_config"
    fi

    if [ "${CONFIG}" = "" ]; then
        CONFIG="${HOME}/.transport-layer-security-tools.conf"
    fi

    if [ ! "$(command -v realpath 2>&1)" = "" ]; then
        REALPATH_CMD="realpath"
    else
        if [ ! "$(command -v grealpath 2>&1)" = "" ]; then
            REALPATH_CMD="grealpath"
        else
            echo "Required tool (g)realpath not found."

            exit 1
        fi
    fi

    CONFIG=$(${REALPATH_CMD} "${CONFIG}")

    if [ ! -f "${CONFIG}" ]; then
        echo "Config missing: ${CONFIG}"

        exit 1;
    fi
}

find_config

. "${CONFIG}"

validate_config()
{
    if [ "${VERBOSE}" = true ]; then
        echo "validate_config"
    fi

    if [ "${FULLY_QUALIFIED_DOMAIN_NAME}" = "" ]; then
        echo "FULLY_QUALIFIED_DOMAIN_NAME not set."

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

    if [ "${OPERATING_SYSTEM}" = "Darwin" ]; then
        export CERTTOOL="gnutls-certtool"
    else
        export CERTTOOL="certtool"
    fi

    export TEMPLATE="/tmp/certtool_template"
    export AUTHORITY_PRIVATE_KEY="${FULLY_QUALIFIED_DOMAIN_NAME}.authority-private-key.pem"
    export AUTHORITY_CERTIFICATE="${FULLY_QUALIFIED_DOMAIN_NAME}.authority-certificate.pem"
    export SIGNING_PRIVATE_KEY="${FULLY_QUALIFIED_DOMAIN_NAME}.signing-private-key.pem"
    export SIGNING_REQUEST_FILE="${FULLY_QUALIFIED_DOMAIN_NAME}.signing-certificate.csr"
    export SIGNING_CERTIFICATE="${FULLY_QUALIFIED_DOMAIN_NAME}.signing-certificate.pem"
}

define_library_variables
