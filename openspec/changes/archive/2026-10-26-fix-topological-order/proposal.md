# Proposal

## Why

The sequencer walks the hash and inserts each dependency into a growing list. That pass is quadratic, and it does not always put a dependency first: `{"d" => "c", "b" => "a", "c" => "b", "a" => ""}` returns `"bcda"`, with `b` before `a`.

## What Changes

- Order jobs so that every dependency appears before the job that names it.
- **BREAKING:** The six-job list `{"a" => "", "b" => "c", "c" => "f", "d" => "a", "e" => "b", "f" => ""}` sequences to `"afdcbe"`. The previous locked string `"afcbde"` still satisfies the precedence constraints, but it is not the stable order.
- `{"d" => "c", "b" => "a", "c" => "b", "a" => ""}` sequences to `"abcd"`.
- Independent jobs stay in input order (`"abc"`, `"acb"`).
- The pass is linear in the number of jobs, because each job has at most one dependency.

## Capabilities

### New Capabilities

### Modified Capabilities

- `job-sequencing`: Dependent jobs have one stable order, and a dependency listed later in the input still comes first.

## Impact

- `lib/jobs_sequencer.rb`
- `spec/lib/job_sequencer_spec.rb`
- `README.md` algorithm section
- `openspec/specs/job-sequencing/spec.md` once this change is synced
