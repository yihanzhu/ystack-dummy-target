#!/bin/sh
# Prints a greeting for the given name (default: world).
set -eu
upper=
case ${1:-} in
	-u)
		upper=1
		shift
		;;
	-?*)
		echo "usage: greet.sh [-u] [name]" >&2
		exit 2
		;;
esac
name=${1:-world}
if [ -n "$upper" ]; then
	printf 'hello, %s\n' "$name" | tr '[:lower:]' '[:upper:]'
else
	printf 'hello, %s\n' "$name"
fi
