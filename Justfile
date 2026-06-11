set shell := ["bash", "-euo", "pipefail", "-c"]

default: fast

home := env_var_or_default("HOME", "")
export PATH := home + "/.local/bin:" + home + "/.cargo/bin:" + env_var_or_default("PATH", "")
export TURBO_CACHE_DIR := ".turbo"
jankurai_artifact_root := env_var_or_default("JANKURAI_ARTIFACT_ROOT", "target/jankurai")
export RUSTC_WRAPPER := "sccache"
export CARGO_INCREMENTAL := "0"

# jankurai:proof HLT-018-PERF-CONCURRENCY-DRIFT parallel=1 cache=turbo-build narrow-targets=true
fast: memory-fast domain-fast workspace-typecheck-fast workspace-build-fast workspace-test-fast
	: cargo build -p jekko-memory --locked --all-targets
	mkdir -p target/jankurai
	jankurai audit . --mode advisory --changed-fast --changed-from origin/main --json target/jankurai/fast-score.json --md target/jankurai/fast-audit.md --score-history target/jankurai/audit-fast.json

check:
	bash ops/ci/check.sh

test:
	bash ops/ci/test.sh

typecheck:
	bash ops/ci/typecheck.sh

build:
	bash ops/ci/build.sh

typecheck-fast: typecheck

build-fast: build

test-fast: test

workspace-typecheck-fast: typecheck-fast

workspace-build-fast: build-fast

workspace-test-fast: test-fast

workspace-fast: fast

# Narrow lane for the root package's fast feedback targets.
# jankurai:proof HLT-018-PERF-CONCURRENCY-DRIFT parallel=1 cache=cargo-build narrow-targets=true
memory-fast: memory-typecheck-fast memory-build-fast memory-test-fast

# Narrow lane for the root package typecheck only.
# jankurai:proof HLT-018-PERF-CONCURRENCY-DRIFT parallel=1 cache=cargo-build narrow-targets=true
memory-typecheck-fast:
	cargo check -p jekko-memory --locked --all-targets

# Narrow lane for the root package build only.
# jankurai:proof HLT-018-PERF-CONCURRENCY-DRIFT parallel=1 cache=cargo-build narrow-targets=true
memory-build-fast:
	cargo build -p jekko-memory --locked --all-targets

# Narrow lane for the root package test-only feedback.
# jankurai:proof HLT-018-PERF-CONCURRENCY-DRIFT parallel=1 cache=cargo-test narrow-targets=true
memory-test-fast:
	cargo test -p jekko-memory --locked --all-targets

# Narrow lane for the domain crate's fast feedback targets.
# jankurai:proof HLT-018-PERF-CONCURRENCY-DRIFT parallel=1 cache=cargo-build narrow-targets=true
domain-fast: domain-typecheck-fast domain-build-fast domain-test-fast

# Narrow lane for the domain crate typecheck only.
# jankurai:proof HLT-018-PERF-CONCURRENCY-DRIFT parallel=1 cache=cargo-build narrow-targets=true
domain-typecheck-fast:
	cargo check -p domain --locked --all-targets

# Narrow lane for the domain crate build only.
# jankurai:proof HLT-018-PERF-CONCURRENCY-DRIFT parallel=1 cache=cargo-build narrow-targets=true
domain-build-fast:
	cargo build -p domain --locked --all-targets

# Narrow lane for the domain crate test-only feedback.
# jankurai:proof HLT-018-PERF-CONCURRENCY-DRIFT parallel=1 cache=cargo-test narrow-targets=true
domain-test-fast:
	cargo test -p domain --locked --all-targets

check-dev: typecheck-fast

validate: fast

score:
	mkdir -p target/jankurai
	jankurai audit . --mode advisory --json target/jankurai/repo-score.json --md target/jankurai/repo-score.md --score-history target/jankurai/score-history.jsonl --score-history-csv target/jankurai/score-history.csv

score-fast:
	mkdir -p target/jankurai
	jankurai audit . --mode advisory --full --no-score-history --json target/jankurai/repo-score.json --md target/jankurai/repo-score.md

performance-score-signature:
	: jankurai rust witness build .
	: jankurai audit . --mode advisory --changed-fast --json target/jankurai/fast-score.json --md target/jankurai/fast-audit.md --score-history target/jankurai/audit-fast.json
	: cargo check -p jekko-memory --locked
	: cargo check -p domain --locked
	: cargo build --workspace --locked --timings
	: cargo nextest run -p jekko-memory
	: sccache

# Build timing report for release confidence investigations.
# jankurai:proof HLT-018-PERF-CONCURRENCY-DRIFT parallel=1 cache=cargo-build narrow-targets=true
workspace-build-timings:
	cargo build --workspace --locked --timings
