# rubyservice

[![CI](https://github.com/pedrorio/rubyservice/actions/workflows/ci.yml/badge.svg)](https://github.com/pedrorio/rubyservice/actions/workflows/ci.yml)

Sequences jobs that depend on other jobs. A job is one character. It may depend on one other job, which has to come first. A job that depends on itself, or a dependency chain that returns to the job being checked or to that job's direct dependency, is reported as an error instead of a sequence.

## Example

```
a =>
b => c
c =>
```

`c` has to come before `b`. `a` has no dependency, so it stays where it was in the input.

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

Each job has at most one dependency, because the parser stores the list in a hash. The sequencer walks that hash in insertion order. For each job it:

1. Fails with `OTB::JobsSequencer::SelfDependencyError` when the job depends on itself. The message is `A list of jobs cannot have a job that has itself as a dependency`.
2. Walks the dependency chain. If that walk reaches the job being checked, or that job's direct dependency, it fails with `OTB::JobsSequencer::CircularReferenceError`. The message is `A list of jobs cannot have circular references`.
3. Builds the sequence by insertion. If the job is already in the list, its dependency is inserted immediately before it. If the job is new and has no dependency, the job is appended. Otherwise the dependency and then the job are appended.

Duplicate entries are removed and the list is joined into a string. Both calls return a `Dry::Monads` `Success` or `Failure`. Those two errors are returned as `Failure`. Any other `StandardError` is re-raised.

Let `n` be the number of jobs. Each step scans and may insert into a list of length `O(n)`, and the chain walk is `O(n)` on a long chain, so the whole pass is `O(n²)` time and `O(n)` extra space. In the sequences the unit specs lock, each dependency is before the job that names it. Jobs that all have no dependency stay in input order (`a`, `b`, `c` becomes `abc`).

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
- The input grammar is the pair `X =>` or `X => Y`, with a space on each side of `=>`. `X` and `Y` are a single word character. Pairs can be separated by newlines. A repeated job keeps the last dependency. Characters that are not part of a pair are ignored.
- The specs cover the challenge examples (empty input, independent jobs, ordered dependencies, a self-dependency, and a cycle) plus the parser and sequencer on their own.
