# TransportLayerSecurityTools

## Usage

Generate authority and intermediate keys and certificates. Keep them very private.

```sh
./bin/generate-authority-certificates.sh
```

Then you can generate as many node encryption keys and certificates as you want.

```sh
./bin/generate-node-certificate.sh ldap
```

Print and validate all generated certificates.

```sh
./bin/validate-certificate.sh private/example.org.authority-certificate.crt
./bin/validate-certificate.sh private/example.org.intermediate-certificate.crt
./bin/validate-certificate.sh private/ldap.example.org.node-certificate.crt
```

Use a alternative config file with different settings.

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
