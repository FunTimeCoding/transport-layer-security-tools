#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)

usage()
{
    echo "Install a Lighttpd configuration file."
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

BUNDLE_FILE="${FULLY_QUALIFIED_DOMAIN_NAME}.wildcard-bundle.pem"
sudo cp "private/${BUNDLE_FILE}" /etc/lighttpd
sudo chmod 640 "/etc/lighttpd/${BUNDLE_FILE}"
sudo chown root:www-data "/etc/lighttpd/${BUNDLE_FILE}"
CONFIG_FILE="${FULLY_QUALIFIED_DOMAIN_NAME}.conf"
echo "\$SERVER[\"socket\"] == \":443\" {
    ssl.pemfile = \"/etc/lighttpd/${BUNDLE_FILE}\"
}" > "${CONFIG_FILE}"
sudo cp "${CONFIG_FILE}" /etc/lighttpd/conf-available
sudo ln -s "/etc/lighttpd/conf-available/${CONFIG_FILE}" "/etc/lighttpd/conf-enabled/${CONFIG_FILE}"
rm "${CONFIG_FILE}"
sudo service lighttpd restart
