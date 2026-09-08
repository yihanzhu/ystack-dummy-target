# ystack-dummy-target

A small, fresh, unrelated repository that exists only to serve as the **external target** for
ystack's portability proof (ystack issue #259, decision TR-1, question 1).

It has its own code, its own test, and its own CI. Nothing here is copied from ystack, and
nothing from ystack's personal paths, credentials, or operator approvals is inherited.

- `src/greet.sh` — the "product": prints a greeting.
- `test/greet.test.sh` — the target's own test.
- `.github/workflows/ci.yml` — the target's own CI (`ci` check on pushes and pull requests).
