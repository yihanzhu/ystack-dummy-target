#!/bin/sh
# The target's own test: greet.sh must greet the given name and default to "world".
set -eu
here=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
out=$(sh "$here/../src/greet.sh" ystack)
[ "$out" = "hello, ystack" ] || { echo "FAIL: got '$out'"; exit 1; }
out=$(sh "$here/../src/greet.sh")
[ "$out" = "hello, world" ] || { echo "FAIL: default got '$out'"; exit 1; }
echo "ok - greet"
