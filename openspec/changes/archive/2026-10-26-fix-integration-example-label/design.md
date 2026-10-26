# Design

## Context

See proposal.md. The second `describe` in `spec/lib/integration_spec.rb` quotes the circular list from the last example. Its body calls `JobsParser` with `a =>`.

## Goals / Non-Goals

**Goals:**

- A reader of the example sees the input that the example runs.

**Non-Goals:**

- Changing the parsed string, the expected sequence, or the circular-dependency example further down the file.

## Decisions

- Set the description to the single-job structure from the challenge: `a =>`, and the result is the sequence `a`.
- Leave the call as `a =>` with the space after `=>`.

## Risks / Trade-offs

- None for runtime behaviour. The example already passes; only its label is wrong.
