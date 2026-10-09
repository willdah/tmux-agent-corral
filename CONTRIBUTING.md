# Contributing

1. Fork, branch from `main`, make the change.
2. `./smoke-test` prints `ok`, and `shellcheck -S warning` is clean on any script you touched.
3. Open a PR whose title is a conventional commit (`fix: ...`, `feat(panel): ...`); the release bump is read from it.

For anything bigger than a fix, open an issue first.
