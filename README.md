# TransportLayerSecurityTools

## Usage

First, generate authority and intermediate keys and certificates. Keep them very private.

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
