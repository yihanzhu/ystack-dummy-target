#!/bin/sh
# Prints a greeting for the given name (default: world).
set -eu
name=${1:-world}
printf 'hello, %s\n' "$name"
