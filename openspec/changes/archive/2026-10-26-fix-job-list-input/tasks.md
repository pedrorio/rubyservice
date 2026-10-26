# Tasks

## 1. Parser contract

- [x] 1.1 Add parser examples for a repeated job, surrounding text, `a=>b`, a blank line, a literal backslash-n line, and a trailing newline. Add a sequencer example for `{"a" => "b"}` expecting `"ba"`. Verify the repeated-job, noise, and backslash-n examples fail for the current reason (they succeed today) before changing the parser.
- [x] 1.2 Accept only one pair per line and reject a repeated job. Verify the new failure examples and the existing empty, independent, chain, and mixed examples pass when those fixtures use newline characters.
- [x] 1.3 Rewrite integration and parser fixtures that used a literal backslash and `n` so they contain newline characters. Verify `bundle exec rspec` passes those files.
- [x] 1.4 Describe the line grammar, duplicate rejection, and undeclared-dependency order in README.md. Verify the README no longer says surrounding text is ignored or that a repeated job keeps the last dependency.
