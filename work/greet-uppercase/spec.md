---
intent-blob: e90471ee42557de8560c271d3dbc2575ac70d573
risk: routine
drafted: 2026-09-08
---

# Spec: greet-uppercase

## Requirements

- R1. `sh src/greet.sh -u ystack` prints `HELLO, YSTACK` on stdout and exits 0.
- R2. `sh src/greet.sh -u` prints `HELLO, WORLD` on stdout and exits 0.
- R3. `sh src/greet.sh ystack` still prints `hello, ystack` and exits 0.
- R4. `sh src/greet.sh` still prints `hello, world` and exits 0.
- R5. An unknown option (for example `-x`) prints exactly one line,
  `usage: greet.sh [-u] [name]`, to stderr, prints nothing on stdout, and exits
  non-zero.
- R6. `-u` is the only accepted option. No long form and no other flag is added.
- R7. The script stays POSIX `sh` with `set -eu` and adds no new dependency.
  Uppercasing uses `tr`, which is a POSIX utility and is already assumed present
  by any POSIX environment, so it counts as no new dependency.
- R8. `test/greet.test.sh` covers all five cases above (R1-R5), stays POSIX `sh`,
  and still prints `ok - greet` as its only success output.
- R9. `README.md` documents the flag in one sentence.
- R10. The `ci` check is green on the pull request.
- R11. `.github/workflows/ci.yml` is unchanged, and no file under `.ystack/` is
  added or changed.
- R12. The whole change is well under the ~300-line soft target; expected under
  40 changed lines across three files. `review_size: standard`.

## Design

Three files change, in this order.

1. `src/greet.sh`. Option parsing sits between `set -eu` and the existing
   default-name line. Read the first argument only: if it is exactly `-u`, set an
   uppercase marker and drop that argument; if it starts with `-` and is not
   `-u`, print the usage line to stderr and exit non-zero; otherwise leave the
   arguments alone. The existing `name=${1:-world}` logic then runs unchanged on
   whatever arguments remain, so the default-name behaviour is untouched. Build
   the greeting with the existing `printf` format, and when the marker is set,
   pass the greeting through `tr` to uppercase it before printing.
2. `test/greet.test.sh`. Add the three new assertions (R1, R2, R5) alongside the
   two that exist. The unknown-option case asserts three things separately:
   stdout empty, stderr equal to the one usage line, exit status non-zero. It
   must capture that exit status without tripping `set -eu`. The final
   `echo "ok - greet"` stays as the last line.
3. `README.md`. One sentence under the `src/greet.sh` bullet naming `-u` and what
   it does.

## Out of scope

- Any other flag: `--help`, a long `--upper` form, colours, locale handling.
- Flags after the name, repeated or combined flags, and `--` end-of-options
  handling.
- Changing `.github/workflows/ci.yml`, adding dependencies, or touching
  `.ystack/`.
- Any change to the intake issue, which stays open.

## Areas of concern

- No north star. This target has no `.ystack/north-star.md`, so no north-star
  conformance can be claimed for this spec. The intake is marked
  `intake_mode: user-directed`, which is the basis for the work instead.
- No conventions file. This target has no `CLAUDE.md` and no `REVIEW.md`, so the
  spec follows the conventions observable in the repository: POSIX `sh`,
  `set -eu` at the top of each script, and one test script that prints
  `ok - greet` on success.
- No conflict found between the intent and any constraint. The intent's
  constraints (POSIX sh, no new dependencies, CI green, `.ystack/` and the CI
  workflow untouched, small change) are all carried into R7 and R10-R12.
- Intent open question 1, long spelled-out form: resolved as no. `-u` only. The
  intake lists `-u` as the accepted form and puts any other flag out of scope,
  so adding `--upper` would add surface the issue did not ask for (R6).
- Intent open question 2, unknown-option message: resolved as name the accepted
  form. The single line `usage: greet.sh [-u] [name]` both signals that the input
  was not understood and states what is accepted, in one line to stderr as the
  intake requires (R5).
- Risk is `routine`. The change touches no constitution path, no workflow file,
  no identity, auth or security control, no migration, no deployment or
  production infrastructure, and no broad architecture: it is one optional flag
  on a greeter script, its test, and one README sentence. The CI workflow is
  explicitly not changed (R11), which is what would otherwise pull this to
  `high`.
