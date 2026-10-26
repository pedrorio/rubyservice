# Tasks

## 1. Messages and examples

- [x] 1.1 Assert the challenge messages on the self-dependency and circular-dependency examples. Verify those assertions fail while the constants still hold the old sentences.
- [x] 1.2 Set the two message constants to `Jobs can’t depend on themselves` and `Jobs can’t have circular dependencies`. Verify the message examples pass.
- [x] 1.3 Correct the YARD examples: sequencer calls pass `jobs_hash:`, the empty parser example is an empty hash, and the quoted pair example is a real pair. Verify `bundle exec yard doc --no-stats` exits 0.
- [x] 1.4 Quote the new messages in README.md. Verify the README no longer quotes the old sentences.
