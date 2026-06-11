#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"
bash ops/ci/typecheck.sh
bash ops/ci/build.sh
bash ops/ci/test.sh
