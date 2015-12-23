# TransportLayerSecurityTools

## Usage

First, generate a master key and certificate and keep them very private. This is also called level 1 certificate.

```sh
./generate-authority-key.sh example.org
```

Then generate a signing key to be able to securely generate any amount of encryption keys. This is also called level 2 certificate.

```sh
./generate-signing-key.sh example.org
```

Lastly, you can generate as many arbitrary encryption certificates as you want. They are then called level 3 certificates.

```sh
./generate-arbitrary-key.sh example.org
```

Print and validate all generated certificates.

```sh
./validate-certificate.sh example.org.authority-certificate.pem
./validate-certificate.sh example.org.singing-certificate.pem
./validate-certificate.sh example.org.arbitrary-certificate.pem
```
