#!/bin/sh -e

# TODO: This should probably go into directory-tools. Or the domain information should be guessed.
ldapwhoami -H ldap:// -x -ZZ -D cn=admin,dc=shiin,dc=org -W
