# job-sequencing

## MODIFIED Requirements

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

## ADDED Requirements

### Requirement: An undeclared dependency is ordered
A dependency that was never listed as its own job MUST appear once in the sequence, before the job that names it.

#### Scenario: Only the dependent job is listed
- **WHEN** the sequencer is called with {"a" => "b"}
- **THEN** the result is a success whose value is "ba"
