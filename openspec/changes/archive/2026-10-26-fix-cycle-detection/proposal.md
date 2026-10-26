# Proposal

## Why

Cycle detection only fails when a dependency walk returns to the job being checked or to that job's direct dependency. `{"a" => "b", "b" => "c", "c" => "d", "d" => "c"}` recurses until `SystemStackError`. That error is not a `StandardError`, so `Service.call` does not turn it into a `Failure`.

## What Changes

- Any cycle, including one downstream of the first job, returns a `Failure` whose value is `OTB::JobsSequencer::CircularReferenceError`.
- The call does not raise `SystemStackError`.
- The existing three-job cycle stays a failure of that same class.

## Capabilities

### New Capabilities

### Modified Capabilities

- `job-sequencing`: A cycle that never returns to the first job or its direct dependency is a failure.

## Impact

- `lib/jobs_sequencer.rb` (covered by the linear order in `fix-topological-order`, which already reports a leftover cycle)
- `spec/lib/job_sequencer_spec.rb`
- `README.md` description of which chains fail
