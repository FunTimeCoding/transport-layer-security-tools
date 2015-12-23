#!/bin/sh -e

grep -r TODO . | grep -v "${0}"
