# TransportLayerSecurityTools

## Usage

This section explains how to use this project.

Create authority and intermediate keys and certificates. Keep them very private.

```sh
bin/create-authority-certificates.sh
```

Create node encryption keys and certificates. Requires authority certificates first.

```sh
bin/create-node-certificate.sh ldap
```

Check that a server has a valid private key. This is the main use case of SSL.

```sh
bin/check-server-certificate.sh ldap.example.org /tmp/ca_certs.pem
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
bin/create-authority-certificates.sh --config ~/.tls-tools-alternative.conf
```

Install certificates on a Debian system running Dnsmasq and Lighttpd.

```sh
bin/install-all-certificates-locally.sh
bin/install-dnsmasq-config.sh example-service.example-hostname
bin/install-lighttpd-config.sh example-service.example-hostname
```


## Setup

Install dependencies on Debian.

```sh
sudo apt-get -qq install realpath gnutls-bin bc
```

Copy the example config file.

```sh
cp example-config.conf ~/.transport-layer-security-tools.conf
```
