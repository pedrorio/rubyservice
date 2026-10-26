# Tasks

## 1. Downstream cycle

- [x] 1.1 Add a sequencer example for `{"a" => "b", "b" => "c", "c" => "d", "d" => "c"}` expecting a `Failure` of `CircularReferenceError` and the message `Jobs can’t have circular dependencies`. Verify the example raises `SystemStackError` before the order change.
- [x] 1.2 Report that cycle as `CircularReferenceError` from the sequencer (no recursion). Verify the new example and the existing three-job cycle example both return a `Failure`.
- [x] 1.3 Describe in README.md that any cycle is a failure. Verify the README no longer limits detection to a chain that returns to the job being checked.
