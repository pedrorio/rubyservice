# Proposal

## Why

The error strings are `A list of jobs cannot have a job that has itself as a dependency` and `A list of jobs cannot have circular references`. The challenge text is `jobs can’t depend on themselves` and `jobs can’t have circular dependencies`. The examples check the error class, not the message. The YARD examples call `JobsSequencer.call` with the jobs hash as a positional argument. The method expects `jobs_hash:`. The parser YARD example shows `Success('')` for an empty string and a quoted pair that is not a pair.

## What Changes

- **BREAKING:** `SelfDependencyError` message is `Jobs can’t depend on themselves`.
- **BREAKING:** `CircularReferenceError` message is `Jobs can’t have circular dependencies`.
- Examples assert those messages.
- YARD calls the sequencer with `jobs_hash:` and shows the success value. The empty parser example is an empty hash. The quoted-pair example is removed.

## Capabilities

### New Capabilities

### Modified Capabilities

- `job-sequencing`: The two dependency failures use the challenge sentences as their messages.

## Impact

- `lib/jobs_sequencer.rb` message constants
- `lib/jobs_parser.rb` and `lib/jobs_sequencer.rb` YARD examples
- `spec/lib/job_sequencer_spec.rb` and `spec/lib/integration_spec.rb`
- `README.md` quoted messages
