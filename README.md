# TransportLayerSecurityTools

## Usage

First, generate a master key and certificate. Keep them very private. This is called a level 1 certificate. 

```sh
./bin/generate-authority-certificate.sh example.org
```

Then generate a signing key and certificate to be able to securely generate any amount of encryption keys and certificates. This is called a level 2 certificate.

```sh
./bin/generate-signing-certificate.sh example.org
```

Lastly, you can generate as many arbitrary encryption keys and certificates as you want. They are called level 3 certificates.

```sh
./bin/generate-arbitrary-certificate.sh example.org
```

Print and validate all generated certificates.

```sh
./bin/validate-certificate.sh private/example.org.authority-certificate.pem
./bin/validate-certificate.sh private/example.org.singing-certificate.pem
./bin/validate-certificate.sh private/example.org.arbitrary-certificate.pem
```
