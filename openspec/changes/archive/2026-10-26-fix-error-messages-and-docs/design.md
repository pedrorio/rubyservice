# Design

## Context

See proposal.md. Specs and examples assert the error class. The constants hold longer sentences than the challenge. YARD shows `JobsSequencer.call({'a' => ''})`, while `Service.call` treats a bare hash as the contract input. The contract requires `jobs_hash`.

## Goals / Non-Goals

**Goals:**

- The two messages are the challenge sentences, as complete sentences with the challenge apostrophe.
- Documented examples use the keyword the method accepts.

**Non-Goals:**

- Accepting a positional hash as a second calling convention.
- Changing which class is returned for each case.

## Decisions

- Set `SelfDependencyError::MESSAGE` to `Jobs can’t depend on themselves` and `CircularReferenceError::MESSAGE` to `Jobs can’t have circular dependencies`. The apostrophe is U+2019, the character in the challenge text.
- Assert `failure.message` in the unit and integration examples.
- Sequencer YARD: `OTB::JobsSequencer.call(jobs_hash: { 'a' => '' }).success` and the other hashes the same way. Parser YARD: `call('')` is `Success({})`, and `call("a => ")` is `Success({ 'a' => '' })`.
- Alternative considered: keep the long sentences because the class is what callers rescue. The challenge states the error text, and nothing asserts the old sentences.

## Risks / Trade-offs

- Callers comparing the old message strings will not match. The class names stay.
