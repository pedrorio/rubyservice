# Design

## Context

See proposal.md. The current sequencer inserts into a result list while walking the hash. A job that is already present gets its dependency inserted immediately before it; otherwise the dependency and the job are appended. That produces `"bcda"` for `{"d" => "c", "b" => "a", "c" => "b", "a" => ""}`.

## Goals / Non-Goals

**Goals:**

- One deterministic order where every dependency precedes its job.
- Keep `"abc"` and `"acb"`.
- Keep self-dependency and the existing three-job cycle as the same error classes (those behaviours belong to other changes).

**Non-Goals:**

- Preserving the insertion-walk string `"afcbde"`.
- Changing the parser, the error messages, or the public `call(jobs_hash:)` shape.

## Decisions

- Use a stable FIFO Kahn order. Nodes are the hash keys in insertion order, then any non-empty dependency that is not itself a key, in the order those dependencies are first seen. An edge runs from the dependency to the job. The initial queue is the zero-indegree nodes in that node order. When a job's indegree falls to zero it is appended to the queue. Dependents of one node are registered in hash order.
- This yields `"afdcbe"` for the six-job hash, `"abcd"` for the counterexample, `"acb"` for `b` depending on `c`, and `"ba"` for `{"a" => "b"}`.
- If the ordered result is shorter than the node list, a cycle remains. Raising `CircularReferenceError` for that case is required so this replacement does not drop the existing cycle failure. Full cycle coverage, including a cycle that never returns to the first job, is specified by `fix-cycle-detection`.
- Self-dependencies are rejected before the graph is built, so a self-loop stays `SelfDependencyError` rather than a cycle.
- Each job has at most one dependency, so the node count and the edge count are both linear in the number of jobs. The pass is O(n) time and O(n) extra space.
- Alternative considered: keep the insertion walk and special-case the counterexample. That still misses other orders and stays quadratic.

## Risks / Trade-offs

- Callers that locked `"afcbde"` see `"afdcbe"`. Both strings satisfy the challenge precedence rules. The spec and the unit example lock the new string.
- An undeclared dependency is still a node, appended after the keys. Dropping it would make "dependency before job" impossible for `{"a" => "b"}`. Including it is specified by `fix-job-list-input`.
