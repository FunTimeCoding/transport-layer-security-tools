# TransportLayerSecurityTools

## Usage

Generate authority and intermediate keys and certificates. Keep them very private.

```sh
./bin/generate-authority-certificates.sh
```

Then generate node encryption keys and certificates.

```sh
./bin/generate-node-certificate.sh ldap
```

Show certificate information.

```sh
./bin/show-certificate-info.sh private/example.org.authority-certificate.crt
./bin/show-certificate-info.sh private/example.org.intermediate-certificate.crt
./bin/show-certificate-info.sh private/ldap.example.org.node-certificate.crt
```

Show private key information.

```sh
./bin/show-key-info.sh private/example.org.authority-private-key.pem
./bin/show-key-info.sh private/example.org.intermediate-private-key.pem
./bin/show-ldap.example.org.node-private-key.pem
```

Verify that a certificate was issued by an authority.

```sh
verify-issued-certificate.sh private/example.org.authority-certificate.crt private/example.org.intermediate-certificate.crt
```

Use alternative config file with different settings.

```sh
./bin/generate-authority-certificates.sh -c ~/.tls-tools-alternative.conf
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
