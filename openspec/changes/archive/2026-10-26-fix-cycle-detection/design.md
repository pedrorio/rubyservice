# Design

## Context

See proposal.md. `circular_dependency?` recurses along the hash and raises only when the next dependency is the job being checked or that job's direct dependency. A cycle further along the chain never hits that condition.

## Goals / Non-Goals

**Goals:**

- `{"a" => "b", "b" => "c", "c" => "d", "d" => "c"}` returns a `Failure` of `CircularReferenceError`.
- The existing `b → c → f → b` list still returns that failure.

**Non-Goals:**

- Changing the error message text (that is `fix-error-messages-and-docs`). This requirement names the message the constant will have once that change lands, so the two specs agree.
- Treating a self-dependency as a cycle. A self-loop stays `SelfDependencyError`.

## Decisions

- Detect cycles by the leftover nodes of the FIFO order in `fix-topological-order`: if the ordered list is shorter than the node list, raise `CircularReferenceError`. That covers a cycle anywhere in the graph, with no recursion.
- Check self-dependencies first, in hash order, so `{"a" => "a"}` is still a self-dependency even though a self-loop is also a cycle.
- Alternative considered: rescue `SystemStackError` in `Service.call`. That would hide the unbounded recursion and would also swallow unrelated stack overflows.

## Risks / Trade-offs

- The message string in this requirement matches the challenge wording. Implement the message in the same pass as `fix-error-messages-and-docs` so the new example does not lock the old sentence.
