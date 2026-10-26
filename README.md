# rubyservice

[![CI](https://github.com/pedrorio/rubyservice/actions/workflows/ci.yml/badge.svg)](https://github.com/pedrorio/rubyservice/actions/workflows/ci.yml)

Sequences jobs that depend on other jobs. A job is one character. It may depend on one other job, which has to come first. A job that depends on itself, or a list that contains a cycle, is reported as an error instead of a sequence.

## Example

```
a =>
b => c
c =>
```

`c` has to come before `b`. `a` has no dependency. Ready jobs are taken in input order, so `a` stays first.

```ruby
require "jobs_parser"
require "jobs_sequencer"

jobs = OTB::JobsParser.call("a => \nb => c\nc => \n").success
OTB::JobsSequencer.call(jobs_hash: jobs).success
# => "acb"
```

The same call with a hash skips parsing:

```ruby
OTB::JobsSequencer.call(jobs_hash: { "a" => "", "b" => "c", "c" => "" }).success
# => "acb"
```

An empty string parses to `{}` and sequences to `""`.

## Algorithm

Each job has at most one dependency, because the parser stores one value per job. The sequencer builds a stable FIFO topological order:

1. Fails with `OTB::JobsSequencer::SelfDependencyError` when a job depends on itself. The message is `Jobs can’t depend on themselves`.
2. Takes the hash keys in insertion order, then any dependency that was never listed as its own job, in the order those dependencies are first seen.
3. Schedules a job only after its dependency. Jobs that are ready together start in that node order. A job that becomes ready later is appended to the queue.
4. Fails with `OTB::JobsSequencer::CircularReferenceError` when a cycle leaves any job unscheduled. The message is `Jobs can’t have circular dependencies`.

Both calls return a `Dry::Monads` `Success` or `Failure`. Those two errors are returned as `Failure`. Any other `StandardError` is re-raised.

Let `n` be the number of jobs. There is at most one edge per job, so the pass is `O(n)` time and `O(n)` extra space. In the locked sequences, each dependency is before the job that names it: `{"a" => "", "b" => "c", "c" => ""}` is `acb`, and `{"a" => "", "b" => "c", "c" => "f", "d" => "a", "e" => "b", "f" => ""}` is `afdcbe`. Jobs that all have no dependency stay in input order (`a`, `b`, `c` becomes `abc`). `{"d" => "c", "b" => "a", "c" => "b", "a" => ""}` is `abcd`. A dependency that is not itself a key is still emitted: `{"a" => "b"}` is `ba`.

## Install

Ruby 4.0.9 (`.ruby-version`).

```sh
bundle install
```

## Run

From a checkout:

```sh
bundle exec ruby -Ilib -e 'require "jobs_parser"; require "jobs_sequencer"; p OTB::JobsSequencer.call(jobs_hash: OTB::JobsParser.call("a => \nb => c\nc => \n").success).success'
```

Generate YARD HTML with `bundle exec yard doc`.

## Test

```sh
bundle exec rspec
bundle exec rubocop
```

GitHub Actions runs both on every push and pull request. `.overcommit.yml` is set up to run RuboCop, RSpec, and YARD coverage on commit.

## Design

- Parsing and sequencing are separate. `OTB::JobsParser` turns the string into a hash. `OTB::JobsSequencer` orders that hash. A caller that already has a hash uses the sequencer directly.
- `Service` validates the input with a dry-validation contract, then returns a success or a failure. The sequencer allows only its two dependency errors to become failures.
- The input grammar is one pair per line: `X =>` or `X => Y`, with a space on each side of `=>`. `X` and `Y` are a single word character. Lines are separated by newline characters, and a trailing newline is accepted. A repeated job is rejected. A line that is not a pair is rejected.
- The specs cover the challenge examples (empty input, independent jobs, ordered dependencies, a self-dependency, and a cycle) plus the parser and sequencer on their own.
