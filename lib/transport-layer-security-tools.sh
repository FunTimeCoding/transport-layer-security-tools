#!/bin/sh -e

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
# shellcheck source=/dev/null
. "${CONFIG}"

validate_config()
{
    if [ "${VERBOSE}" = true ]; then
        echo "validate_config"
    fi

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
    if [ "${VERBOSE}" = true ]; then
        echo "define_library_variables"
    fi

    OPERATING_SYSTEM=$(uname)

    if [ "${OPERATING_SYSTEM}" = "Darwin" ]; then
        export CERTTOOL="gnutls-certtool"
    else
        export CERTTOOL="certtool"
    fi

    export TEMPLATE="/tmp/certtool_template"
    export AUTHORITY_PRIVATE_KEY="${DOMAIN_NAME}.authority-private-key.pem"
    export AUTHORITY_CERTIFICATE="${DOMAIN_NAME}.authority-certificate.crt"
    export INTERMEDIATE_PRIVATE_KEY="${DOMAIN_NAME}.intermediate-private-key.pem"
    export INTERMEDIATE_CERTIFICATE="${DOMAIN_NAME}.intermediate-certificate.crt"

    if [ "${PRIVATE_DIRECTORY}" = "" ]; then
        export PRIVATE_DIRECTORY="private"
    fi
}

define_library_variables
