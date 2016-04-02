# TransportLayerSecurityTools

## Usage

Create authority and intermediate keys and certificates. Keep them very private.

```sh
bin/create-authority-certificates.sh
```

Create node encryption keys and certificates. Requires authority certificates first.

```sh
bin/create-node-certificate.sh ldap
```

Check that an issued certificate was signed by a specific instance.

```sh
bin/check-issued-certificate.sh private/example.org.authority-certificate.crt private/example.org.intermediate-certificate.crt
bin/check-issued-certificate.sh private/example.org.intermediate-certificate.crt private/ldap.example.org.intermediate-certificate.crt
```

Show certificate information.

```sh
bin/show-certificate-info.sh private/example.org.authority-certificate.crt
bin/show-certificate-info.sh private/example.org.intermediate-certificate.crt
bin/show-certificate-info.sh private/ldap.example.org.node-certificate.crt
```

Show private key information.

```sh
bin/show-key-info.sh private/example.org.authority-private-key.pem
bin/show-key-info.sh private/example.org.intermediate-private-key.pem
bin/show-key-info.sh private/ldap.example.org.node-private-key.pem
```

Use alternative config file with different settings.

```sh
bin/create-authority-certificates.sh -c ~/.tls-tools-alternative.conf
```


## Setup

Create a settings file named `~/.transport-layer-security-tools.conf`.

```sh
DOMAIN_NAME="example.org"
ORGANIZATION="Example Organization"
ORGANIZATIONAL_UNIT="Software Development"
STATE="Example State"
COUNTRY_CODE="EC"
```

Optionally specify the directory where to store keys and certificates.

```sh
PRIVATE_DIRECTORY="/home/example/tls"
```
