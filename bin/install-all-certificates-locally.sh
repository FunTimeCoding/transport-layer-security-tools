#!/bin/sh -e

cp private/*.crt /usr/local/share/ca-certificates
sudo update-ca-certificates --fresh
