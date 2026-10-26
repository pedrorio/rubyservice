# job-sequencing

## MODIFIED Requirements

### Requirement: Self-dependency
When a job's dependency is that same job, the sequencer MUST return a failure. The failure value MUST be an OTB::JobsSequencer::SelfDependencyError whose message is "Jobs can’t depend on themselves".

#### Scenario: A job depends on itself
- **WHEN** the sequencer is called with {"a" => "", "b" => "", "c" => "c"}
- **THEN** the result is a failure whose value is an OTB::JobsSequencer::SelfDependencyError with that message

### Requirement: Circular dependency
When walking a job's dependency chain reaches that job or its immediate dependency, the sequencer MUST return a failure. The failure value MUST be an OTB::JobsSequencer::CircularReferenceError whose message is "Jobs can’t have circular dependencies".

#### Scenario: A three-job cycle
- **WHEN** the sequencer is called with {"a" => "", "b" => "c", "c" => "f", "d" => "a", "e" => "", "f" => "b"}
- **THEN** the result is a failure whose value is an OTB::JobsSequencer::CircularReferenceError with that message
