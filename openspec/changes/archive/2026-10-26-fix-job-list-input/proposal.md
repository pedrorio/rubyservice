# Proposal

## Why

The parser keeps the last pair for a repeated job (`"a => b a => c"` becomes `{"a" => "c"}`) and ignores text that is not a pair (`"noise a => b noise"` becomes `{"a" => "b"}`). A dependency that was never declared as its own job is still emitted (`{"a" => "b"}` sequences to `"ba"`). None of these are locked by examples. The integration strings use a literal backslash and `n`, not a newline. Newlines work too, because the scanner only looks for pairs. A pair needs spaces around `=>`.

## What Changes

- **BREAKING:** A job listed more than once is a failure that reports that a job must be listed once. The last pair no longer wins.
- **BREAKING:** Text that is not a pair, a missing space around `=>`, a blank line between pairs, and a literal backslash-`n` used as a separator are failures that report that the input must be empty or is in invalid format.
- A job list is one pair per line, separated by newline characters. A trailing newline after the last pair is accepted. An empty string stays an empty hash.
- `{"a" => "b"}` still sequences to `"ba"`.
- Specs and the README use real newlines in job lists.

## Capabilities

### New Capabilities

### Modified Capabilities

- `job-sequencing`: Line grammar replaces last-wins and ignored surrounding text, and an undeclared dependency is still ordered before its job.

## Impact

- `lib/jobs_parser.rb`
- `spec/lib/jobs_parser_spec.rb`
- `spec/lib/integration_spec.rb` fixtures
- `README.md` grammar and example strings
