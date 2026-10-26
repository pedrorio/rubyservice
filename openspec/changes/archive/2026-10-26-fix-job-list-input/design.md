# Design

## Context

See proposal.md. `JobsParser` scans `/(\w) => (\w|)/` anywhere in the string. The last match for a job key overwrites earlier ones. Characters that do not form a pair are skipped. `String#split("\n")` is not used.

## Goals / Non-Goals

**Goals:**

- One pair per line, with a space on each side of `=>`.
- Reject duplicates, surrounding text, a missing space, a blank line between pairs, and a literal backslash-`n` separator.
- Accept an empty string and a single trailing newline.
- Keep sequencing `{"a" => "b"}` to `"ba"`.

**Non-Goals:**

- Dropping an undeclared dependency from the sequence.
- Accepting more than one dependency per job.

## Decisions

- A line matches `\A(\w) => (\w)?\z`. The space after `=>` is required. The dependency character is optional, and a missing one is stored as `""`.
- Split on `"\n"`. Ruby drops trailing empty fields, so `"a => \n"` is one pair. A blank line between pairs leaves an empty field and fails the line pattern.
- A non-empty string that splits to no lines (for example `"\n"`) fails the format check.
- Format failures use the existing validation message `must be empty or is in invalid format`. A duplicate job name, checked only after every line matches, uses `a job must be listed once`.
- The sequencer node list from `fix-topological-order` appends a dependency that is not a key, so `{"a" => "b"}` stays `"ba"` without a parser change.
- Alternative considered: keep scanning and only document last-wins. The challenge lists are line-oriented, and last-wins hides conflicting instructions.

## Risks / Trade-offs

- Existing examples written with a literal backslash and `n` inside single quotes become failures. Those fixtures move to double-quoted newlines.
- `"a =>"` without the space after `=>` is a failure. The challenge lines and the current examples include that space.
