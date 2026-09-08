#!/bin/sh
# The target's own test: greet.sh must greet the given name and default to "world".
set -eu
here=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
out=$(sh "$here/../src/greet.sh" ystack)
[ "$out" = "hello, ystack" ] || { echo "FAIL: got '$out'"; exit 1; }
out=$(sh "$here/../src/greet.sh")
[ "$out" = "hello, world" ] || { echo "FAIL: default got '$out'"; exit 1; }

out=$(sh "$here/../src/greet.sh" -u ystack)
[ "$out" = "HELLO, YSTACK" ] || { echo "FAIL: -u ystack got '$out'"; exit 1; }

out=$(sh "$here/../src/greet.sh" -u)
[ "$out" = "HELLO, WORLD" ] || { echo "FAIL: -u got '$out'"; exit 1; }

errfile=$(mktemp "${TMPDIR:-/tmp}/greet.XXXXXX")
if out=$(sh "$here/../src/greet.sh" -x 2>"$errfile"); then
	rm -f "$errfile"
	echo "FAIL: -x did not exit non-zero"; exit 1
else
	status=$?
fi
err=$(cat "$errfile")
rm -f "$errfile"
[ -z "$out" ] || { echo "FAIL: -x stdout not empty, got '$out'"; exit 1; }
[ "$err" = "usage: greet.sh [-u] [name]" ] || { echo "FAIL: -x stderr got '$err'"; exit 1; }
[ "$status" -ne 0 ] || { echo "FAIL: -x exit status was 0"; exit 1; }

echo "ok - greet"
