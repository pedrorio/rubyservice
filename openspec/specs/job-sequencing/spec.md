# job-sequencing

## Purpose

Turn a list of single-character jobs, each with at most one dependency, into one ordered sequence. Every dependency comes before the job that names it. Fail on a self-dependency or on any cycle.

## Requirements

### Requirement: Empty input
An empty job list MUST produce an empty sequence. The parser MUST accept an empty string and return a success value of an empty hash. The sequencer MUST accept that hash and return a success value of an empty string.

#### Scenario: No jobs
- **WHEN** the parser is called with an empty string
- **THEN** the result is a success whose value is an empty hash
- **AND** sequencing that hash returns a success whose value is an empty string

### Requirement: Job pair input
The parser MUST accept a non-empty list of newline-separated lines and return a success hash of those pairs. Each line MUST be one word character, a space, `=>`, a space, and either one word character or nothing. An omitted dependency MUST be stored as an empty string. A repeated job name MUST fail. A line that is not a pair MUST fail.

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
- **WHEN** the parser is called with the lines "a => ", "b => c", and "c => " separated by newline characters
- **THEN** the result is a success whose value is {"a" => "", "b" => "c", "c" => ""}

#### Scenario: Trailing newline
- **WHEN** the parser is called with "a => " followed by one newline character
- **THEN** the result is a success whose value is {"a" => ""}

#### Scenario: Repeated job
- **WHEN** the parser is called with "a => b\na => c"
- **THEN** the result is a failure that reports that a job must be listed once

#### Scenario: Text outside a pair
- **WHEN** the parser is called with "noise a => b noise"
- **THEN** the result is a failure that reports that the input must be empty or is in invalid format

#### Scenario: Missing spaces around the arrow
- **WHEN** the parser is called with "a=>b"
- **THEN** the result is a failure that reports that the input must be empty or is in invalid format

#### Scenario: Blank line between pairs
- **WHEN** the parser is called with "a => ", then a blank line, then "b => "
- **THEN** the result is a failure that reports that the input must be empty or is in invalid format

#### Scenario: A backslash and the letter n are not a newline
- **WHEN** the parser is called with a single line that contains "a => " then a backslash, the letter n, then "b => "
- **THEN** the result is a failure that reports that the input must be empty or is in invalid format

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
- **THEN** the result is a success whose value is "afdcbe"
- **AND** f occurs before c, c before b, b before e, and a before d

### Requirement: A dependency always precedes its job
The sequencer MUST place every non-empty dependency before the job that names it, including when that dependency is listed later than the job.

#### Scenario: Dependency listed after the job
- **WHEN** the sequencer is called with {"d" => "c", "b" => "a", "c" => "b", "a" => ""}
- **THEN** the result is a success whose value is "abcd"

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

### Requirement: An undeclared dependency is ordered
A dependency that was never listed as its own job MUST appear once in the sequence, before the job that names it.

#### Scenario: Only the dependent job is listed
- **WHEN** the sequencer is called with {"a" => "b"}
- **THEN** the result is a success whose value is "ba"

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

### Requirement: Every cycle is a failure
Any cyclic dependency MUST make the sequencer return a failure, including a cycle that does not return to the first job or to that job's direct dependency. The failure value MUST be an OTB::JobsSequencer::CircularReferenceError whose message is "Jobs can’t have circular dependencies". The call MUST return that failure and MUST NOT raise.

#### Scenario: Cycle downstream of the first job
- **WHEN** the sequencer is called with {"a" => "b", "b" => "c", "c" => "d", "d" => "c"}
- **THEN** the result is a failure whose value is an OTB::JobsSequencer::CircularReferenceError with that message

### Requirement: Sequencer input must be a hash
The sequencer MUST return a failure when `jobs_hash` is not a Hash, and a success when it is a Hash.

#### Scenario: A string is rejected
- **WHEN** the sequencer is called with jobs_hash set to "hello world"
- **THEN** the result is a failure

#### Scenario: A hash is accepted
- **WHEN** the sequencer is called with {a: ""}
- **THEN** the result is a success
