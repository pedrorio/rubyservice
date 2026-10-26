# job-sequencing

## Purpose

Turn a list of single-character jobs, each with at most one dependency, into one ordered sequence, and fail on a self-dependency or when a dependency chain returns to the job being checked or to its direct dependency.

## Requirements

### Requirement: Empty input
An empty job list MUST produce an empty sequence. The parser MUST accept an empty string and return a success value of an empty hash. The sequencer MUST accept that hash and return a success value of an empty string.

#### Scenario: No jobs
- **WHEN** the parser is called with an empty string
- **THEN** the result is a success whose value is an empty hash
- **AND** sequencing that hash returns a success whose value is an empty string

### Requirement: Job pair input
The parser MUST accept a non-empty string that contains at least one pair and return a success hash of those pairs. A pair is a word character, a space, `=>`, a space, and either one word character or nothing. A missing dependency MUST be stored as an empty string.

#### Scenario: Jobs with no dependencies
- **WHEN** the parser is called with "a => \nb => \nc => "
- **THEN** the result is a success whose value is {"a" => "", "b" => "", "c" => ""}

#### Scenario: Jobs that only have dependencies
- **WHEN** the parser is called with "a => b\nb => c\nc => d"
- **THEN** the result is a success whose value is {"a" => "b", "b" => "c", "c" => "d"}

#### Scenario: Mixed dependencies
- **WHEN** the parser is called with "a => b\nb => \nc => d"
- **THEN** the result is a success whose value is {"a" => "b", "b" => "", "c" => "d"}

#### Scenario: Real line breaks
- **WHEN** the parser is called with a string of "a =>", "b => c", and "c =>" separated by newlines
- **THEN** the result is a success whose value is {"a" => "", "b" => "c", "c" => ""}

#### Scenario: Repeated job
- **WHEN** the parser is called with "a => b a => c"
- **THEN** the result is a success whose value is {"a" => "c"}

#### Scenario: Text outside a pair
- **WHEN** the parser is called with "noise a => b noise"
- **THEN** the result is a success whose value is {"a" => "b"}

### Requirement: Reject malformed parser input
The parser MUST return a failure when the input is not a string. The parser MUST return a failure when a non-empty string contains no job pair.

#### Scenario: Nil input
- **WHEN** the parser is called with nil
- **THEN** the result is a failure

#### Scenario: Prose
- **WHEN** the parser is called with "hello world"
- **THEN** the result is a failure

### Requirement: Independent jobs keep input order
When every dependency is empty, the sequencer MUST return a success string of the jobs in hash insertion order, each job once.

#### Scenario: Single job
- **WHEN** the sequencer is called with {"a" => ""}
- **THEN** the result is a success whose value is "a"

#### Scenario: Three independent jobs
- **WHEN** the sequencer is called with {"a" => "", "b" => "", "c" => ""}
- **THEN** the result is a success whose value is "abc"

### Requirement: Recorded sequences for dependent jobs
The sequencer MUST return a success string for the dependent hashes below. In each string a listed dependency appears before the job that names it, and each distinct job appears once.

#### Scenario: c before b
- **WHEN** the sequencer is called with {"a" => "", "b" => "c", "c" => ""}
- **THEN** the result is a success whose value is "acb"

#### Scenario: Six jobs
- **WHEN** the sequencer is called with {"a" => "", "b" => "c", "c" => "f", "d" => "a", "e" => "b", "f" => ""}
- **THEN** the result is a success whose value is "afcbde"
- **AND** f occurs before c, c before b, b before e, and a before d

### Requirement: Self-dependency
When a job's dependency is that same job, the sequencer MUST return a failure. The failure value MUST be an OTB::JobsSequencer::SelfDependencyError whose message is "A list of jobs cannot have a job that has itself as a dependency".

#### Scenario: A job depends on itself
- **WHEN** the sequencer is called with {"a" => "", "b" => "", "c" => "c"}
- **THEN** the result is a failure whose value is an OTB::JobsSequencer::SelfDependencyError with that message

### Requirement: Circular dependency
When walking a job's dependency chain reaches that job or its immediate dependency, the sequencer MUST return a failure. The failure value MUST be an OTB::JobsSequencer::CircularReferenceError whose message is "A list of jobs cannot have circular references".

#### Scenario: A three-job cycle
- **WHEN** the sequencer is called with {"a" => "", "b" => "c", "c" => "f", "d" => "a", "e" => "", "f" => "b"}
- **THEN** the result is a failure whose value is an OTB::JobsSequencer::CircularReferenceError with that message

### Requirement: Sequencer input must be a hash
The sequencer MUST return a failure when `jobs_hash` is not a Hash, and a success when it is a Hash.

#### Scenario: A string is rejected
- **WHEN** the sequencer is called with jobs_hash set to "hello world"
- **THEN** the result is a failure

#### Scenario: A hash is accepted
- **WHEN** the sequencer is called with {a: ""}
- **THEN** the result is a success
