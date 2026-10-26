# Design

## Context

See proposal.md. The exact unit strings already force a total order for two hashes. The pattern matchers do not.

## Goals / Non-Goals

**Goals:**

- The order examples fail if the named job is missing or sits at a later index.

**Non-Goals:**

- Changing the sequence those examples produce. The six-job string itself changes only in `fix-topological-order`.

## Decisions

- Replace `should match(/c*b/)` and the sibling patterns with `index` comparisons (`index('c') < index('b')`, and the same for `f`/`c`, `b`/`e`, and `a`/`d`).
- Keep the exact-string examples. Index checks and exact strings answer different questions: the index check is the precedence contract, and the exact string is the stable order.

## Risks / Trade-offs

- An index comparison raises if the character is absent. The examples also assert the string length, so a missing job still fails the group.
