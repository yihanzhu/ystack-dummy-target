# Intent: Uppercase greeting option
Author: Yihan Zhu (operator). Status: draft.

## Problem
The greeter can only print its greeting in lowercase. Anyone who wants a shouted
greeting has to take the output and convert it themselves afterwards, which is
extra work for something the greeter could do on its own. There is a second
reason too: this repository is fresh, and I want one small, real piece of work
to run through the whole ystack loop end to end on it.

## Proposed outcome
The greeter can produce the uppercase greeting itself. Everything it does today
keeps working exactly as it does now. If someone asks for something the greeter
does not understand, it says so clearly and fails rather than pretending. The
new behaviour is written down in the README in one sentence.

## Affected users and systems
Anyone calling the greeter script in this repository, plus its own test and its
README. The repository's existing CI run also covers the change. No other repo
or workflow is touched.

## Constraints
- POSIX sh only, and no new dependencies.
- CI must stay green.
- Nothing under `.ystack/` may be added or changed.
- The CI workflow file must not be changed.
- Keep the change small — well under the ~300-line soft target.

## Open questions
- Should the uppercase request also be accepted in a longer, spelled-out form,
  or is the short form enough?
- When the greeter is asked for something it does not understand, should its
  message list everything it does accept, or just say it did not understand?
