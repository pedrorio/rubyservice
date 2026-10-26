# job-sequencing

## ADDED Requirements

### Requirement: Before means a lower index
A job that must come before another job MUST have a strictly lower index in the success string than the later job.

#### Scenario: c before b
- **WHEN** the sequencer is called with {"a" => "", "b" => "c", "c" => ""}
- **THEN** the index of c in the success value is strictly less than the index of b

#### Scenario: Six-job precedence
- **WHEN** the sequencer is called with {"a" => "", "b" => "c", "c" => "f", "d" => "a", "e" => "b", "f" => ""}
- **THEN** the index of f is strictly less than the index of c
- **AND** the index of c is strictly less than the index of b
- **AND** the index of b is strictly less than the index of e
- **AND** the index of a is strictly less than the index of d
