# job-sequencing

## ADDED Requirements

### Requirement: Every cycle is a failure
Any cyclic dependency MUST make the sequencer return a failure, including a cycle that does not return to the first job or to that job's direct dependency. The failure value MUST be an OTB::JobsSequencer::CircularReferenceError whose message is "Jobs can’t have circular dependencies". The call MUST return that failure and MUST NOT raise.

#### Scenario: Cycle downstream of the first job
- **WHEN** the sequencer is called with {"a" => "b", "b" => "c", "c" => "d", "d" => "c"}
- **THEN** the result is a failure whose value is an OTB::JobsSequencer::CircularReferenceError with that message
