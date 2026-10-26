# job-sequencing

## MODIFIED Requirements

### Requirement: Recorded sequences for dependent jobs
The sequencer MUST return a success string for the dependent hashes below. In each string a listed dependency appears before the job that names it, and each distinct job appears once.

#### Scenario: c before b
- **WHEN** the sequencer is called with {"a" => "", "b" => "c", "c" => ""}
- **THEN** the result is a success whose value is "acb"

#### Scenario: Six jobs
- **WHEN** the sequencer is called with {"a" => "", "b" => "c", "c" => "f", "d" => "a", "e" => "b", "f" => ""}
- **THEN** the result is a success whose value is "afdcbe"
- **AND** f occurs before c, c before b, b before e, and a before d

## ADDED Requirements

### Requirement: A dependency always precedes its job
The sequencer MUST place every non-empty dependency before the job that names it, including when that dependency is listed later than the job.

#### Scenario: Dependency listed after the job
- **WHEN** the sequencer is called with {"d" => "c", "b" => "a", "c" => "b", "a" => ""}
- **THEN** the result is a success whose value is "abcd"
