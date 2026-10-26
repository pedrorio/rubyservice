# Tasks

## 1. Order

- [x] 1.1 Add a sequencer example for `{"d" => "c", "b" => "a", "c" => "b", "a" => ""}` expecting `"abcd"`, and change the six-job example from `"afcbde"` to `"afdcbe"`. Verify both fail before the implementation change.
- [x] 1.2 Replace the insertion walk with the stable FIFO order from design.md. Verify the new examples pass and the existing `"abc"` and `"acb"` examples still pass.
- [x] 1.3 Describe that order and its linear cost in README.md. Verify the README no longer describes the insertion walk.
