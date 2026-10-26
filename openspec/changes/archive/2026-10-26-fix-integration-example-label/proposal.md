# Proposal

## Why

One integration example is described with the circular-dependency list `a =>`, `b => c`, `c => f`, `d => a`, `e =>`, `f => b`. The example itself only parses `a =>` and expects the sequence `a`.

## What Changes

- The example description names the single job `a =>`, which is the input it runs.
- The assertion stays `a`.

## Capabilities

### New Capabilities

### Modified Capabilities

## Impact

- `spec/lib/integration_spec.rb` description string only.
- The single-job behaviour is already required by `job-sequencing` ("Independent jobs keep input order", scenario "Single job"). This change does not alter that requirement.
