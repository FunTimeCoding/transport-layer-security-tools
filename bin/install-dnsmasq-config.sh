#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)
WITH_ADDRESS=false

usage()
{
    echo "Install Dnsmasq configuration file."
    echo "Local usage: ${0} [DOMAIN_LABELS]"
    echo "Example: ${0} # for example.org"
    echo "Example: ${0} foo # for foo.example.org"
    echo "Example: ${0} bar.foo # for bar.foo.example.org"
}

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}/../lib/transport-layer-security-tools.sh"
DOMAIN_LABELS="${1}"

if [ "${DOMAIN_LABELS}" = "" ]; then
    FULLY_QUALIFIED_DOMAIN_NAME="${DOMAIN_NAME}"
else
    FULLY_QUALIFIED_DOMAIN_NAME="${DOMAIN_LABELS}.${DOMAIN_NAME}"
fi

ADDRESS=$(ip addr list eth0 | grep "inet " | cut -d ' ' -f6 | cut -d / -f1)
FILE_NAME="${FULLY_QUALIFIED_DOMAIN_NAME}.conf"
echo "address=/${FULLY_QUALIFIED_DOMAIN_NAME}/${ADDRESS}" > "${FILE_NAME}"
sudo cp "${FILE_NAME}" /etc/dnsmasq.d
rm "${FILE_NAME}"
sudo service dnsmasq restart
