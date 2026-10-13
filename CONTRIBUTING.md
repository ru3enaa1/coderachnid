# Contributing to coderachnid

Thanks for helping make the sieve finer.

## What makes a good contribution

A pitfall or rule is accepted when it is:

1. **Real.** It happened in an actual project. Say when it was confirmed. Anticipated
   traps are welcome if they are marked as anticipated.
2. **Actionable.** It leads with the rule as an instruction, then the symptom, then
   the cause.
3. **Checkable.** It names the test, script, assertion or command that catches it.
4. **General.** It contains no names of people, companies, customers, private
   repositories, personal paths, hostnames, keys or internal URLs.
5. **In the right place.** Universal rules go into a skill's `SKILL.md`. Stack-specific
   ones go into that skill's `references/<stack>.md`.

## Style

- English, plain and direct. Short sentences.
- Keep each `SKILL.md` under about 150 lines and move detail into `references/`.
- A skill's `description` decides when it activates. State *when to use it* first, then
  what it does.
- No content copied from other plugins or skill packs. Cite an idea instead of copying
  its text.

## Pull requests

1. One topic per pull request.
2. Update `CHANGELOG.md` under "Unreleased".
   If you add or remove a skill, update the `skills` badge in `README.md` and run
   `node assets/build-assets.mjs` to regenerate the banners. `check-skills.sh` fails
   until both match.
3. Explain how you checked that the skill activates for the intended task, and does not
   activate for an unrelated one.

## Versioning

[Semantic Versioning](https://semver.org): new skills or references bump the minor
version, wording fixes bump the patch version, and renamed or removed skills bump the
major version.
