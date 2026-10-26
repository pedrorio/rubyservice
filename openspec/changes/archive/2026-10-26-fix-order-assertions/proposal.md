# Proposal

## Why

The integration order checks, and the matching unit checks, use `/c*b/`, `/f*c/`, `/b*e/`, and `/a*d/`. In Ruby those patterns mean "zero or more `c`, then `b`" and so on, so `/c*b/` matches any string that contains `b`. They do not show that `c` comes before `b`. The exact strings `"acb"` and `"afcbde"` are what actually lock order today.

## What Changes

- Order examples compare indexes: the earlier job's index is strictly less than the later job's index.
- The three-job list still requires the index of `c` to be less than the index of `b`.
- The six-job list requires the index of `f` before `c`, `c` before `b`, `b` before `e`, and `a` before `d`.

## Capabilities

### New Capabilities

### Modified Capabilities

- `job-sequencing`: "Before" is a strictly lower character index, which a pattern such as `/c*b/` does not establish.

## Impact

- `spec/lib/integration_spec.rb`
- `spec/lib/job_sequencer_spec.rb`
