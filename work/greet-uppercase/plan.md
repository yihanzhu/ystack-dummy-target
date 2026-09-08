---
spec-blob: 29a3c099e56da4b0ff67ddb6172518c9f7f3ddda
drafted: 2026-09-08
---

# Plan: greet-uppercase

## Files that change

- `src/greet.sh` (5 lines today). Add option parsing between `set -eu` (line 3)
  and `name=${1:-world}` (line 4), and uppercase the greeting when the flag is
  set. About 10 added lines.
- `test/greet.test.sh` (9 lines today). Add the `-u` cases and the unknown-option
  case. About 12 added lines.
- `README.md`. One sentence about `-u` under the `src/greet.sh` bullet (line 9).
  1 line.

`.github/workflows/ci.yml` does not change. Nothing under `.ystack/` is added or
changed. `review_size: standard` — the whole change is expected well under 40
changed lines across those three files.

## Order of work

1. Parse the first argument in `src/greet.sh`, between `set -eu` and
   `name=${1:-world}`. Use `${1:-}` so an empty argument list is safe under
   `set -u`. If the first argument is exactly `-u`, set an uppercase marker and
   `shift`. If it starts with `-` and is not `-u`, print
   `usage: greet.sh [-u] [name]` to stderr and `exit 2`. Otherwise change
   nothing. (R5, R6, R7)
2. Build the greeting with the existing `printf 'hello, %s\n' "$name"` line. When
   the marker is set, pipe that output through `tr '[:lower:]' '[:upper:]'`,
   which is POSIX. Leave `name=${1:-world}` as it is, so the no-flag paths are
   byte-for-byte unchanged. (R1, R2, R3, R4, R7)
3. Extend `test/greet.test.sh` with the R1 case (`-u ystack` → `HELLO, YSTACK`),
   the R2 case (`-u` → `HELLO, WORLD`), and the R5 unknown-option case. The
   script runs under `set -eu`, so a failing command would abort it: capture the
   status deliberately, either with an
   `if out=$(...); then fail; else status=$?; fi` shape or by wrapping the call
   in `set +e` / `set -e`. Capture stderr without writing into the repository:
   read it into a variable inside that shape with
   `err=$(sh "$here/../src/greet.sh" -x 2>&1 >/dev/null)`, or use a temp file
   from `mktemp "${TMPDIR:-/tmp}/greet.XXXXXX"` and remove it afterwards with an
   explicit `rm -f` or a `trap`. Never redirect to a bare relative path such as
   `2>err`: the test must leave the working tree clean. Assert three things
   separately: stdout is empty, stderr is exactly the one usage line, status is
   non-zero. Keep `echo "ok - greet"` as the last line and the only success
   output. (R1, R2, R5, R8)
4. Add one sentence to `README.md` under the `src/greet.sh` bullet saying that
   `-u` prints the greeting in uppercase. (R9)
5. Run `sh test/greet.test.sh` locally. That is exactly the command the `ci` job
   runs. (R8, R10)
6. Commit and open the implementation pull request with `Closes #1` in the body.
   This is the one PR that closes the intake: ystack's chain rule keeps the
   intake open through intent, spec and plan (those used `Tracks #1`), and the
   implementation PR closes it on merge. Confirm the `ci` check is green and that
   the diff touches only the three files. (R10, R11, R12)

## Risks

- **`set -u` with no arguments.** Reading `$1` directly when the caller passes
  nothing would abort the script. The parse must use `${1:-}`. This is the
  easiest way to break R4 while making R1 pass.
- **`tr` and locale.** `[:lower:]`/`[:upper:]` are POSIX character classes and
  behave correctly for the ASCII inputs in the spec. Non-ASCII names are not in
  scope, so no locale handling is needed.
- **A name that starts with `-`.** It is rejected as an unknown option. The spec
  accepts this: `--` end-of-options handling is explicitly out of scope.
- **Riskiest step: step 3.** Capturing a non-zero exit status inside a script
  running under `set -eu` is where this goes wrong. A bare
  `out=$(... ) ; status=$?` aborts before `status` is read. Use the `if`
  form or a scoped `set +e`, and check that the test still fails loudly when the
  script is wrong (temporarily break `src/greet.sh` once to confirm).
- **Stray files left by the tests.** Redirecting stderr to a relative path drops
  an untracked file into the repository root when CI runs the test script. Keep
  stderr in a variable or a `mktemp` file under `${TMPDIR:-/tmp}` that the test
  removes; the last Proof bullet plus a clean `git status` catches a slip.
- **Rejected alternative: a `getopts` loop.** It would handle flag ordering,
  bundling and repeats — all out of scope. Only one flag, only in first position,
  is in scope, so a `getopts` loop adds surface the spec did not ask for. A
  single first-argument check is smaller and easier to review.

## Proof

Run from the repository root:

- `sh src/greet.sh -u ystack` → `HELLO, YSTACK`, exit 0. (R1)
- `sh src/greet.sh -u` → `HELLO, WORLD`, exit 0. (R2)
- `sh src/greet.sh ystack` → `hello, ystack`, exit 0. (R3)
- `sh src/greet.sh` → `hello, world`, exit 0. (R4)
- `sh src/greet.sh -x; echo $?` → nothing on stdout, `usage: greet.sh [-u] [name]`
  on stderr, and a non-zero status printed. (R5)
- `sh test/greet.test.sh` → `ok - greet` and nothing else, exit 0. (R8)
- The pull request's `ci` check is green. (R10)
- `git diff --stat main` lists only `src/greet.sh`, `test/greet.test.sh` and
  `README.md`. (R11, R12)
