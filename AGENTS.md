# AGENTS.md

This file provides guidance to AI coding agents when working with code in this repository.

## What this project is

`code_manifest` is a Ruby gem that fetches files by glob patterns and generates a digest of those files. It is used to produce stable manifests of file sets for caching and change-detection purposes.

## Commands

```bash
bundle install

# Run all tests (RSpec)
bundle exec rspec

# Run a single spec file
bundle exec rspec spec/path/to/spec.rb
```

## Architecture

- `lib/code_manifest.rb` — public API; accepts glob patterns and returns matched files plus a digest
- `lib/code_manifest/` — internal helpers for glob resolution and hashing
- `spec/` — RSpec tests; `spec/fixtures/` holds sample file trees
