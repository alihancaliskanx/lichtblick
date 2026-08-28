#!/usr/bin/env bash
#
# Build the web app for the hosted deployment.
#
# Written to run from anywhere. Four deploys failed because the build command
# does not necessarily start in the repository root — `bash ci/vercel-build.sh`
# came back "No such file or directory" even though the file was in the commit,
# which means the project's root directory points at a subfolder. Yarn hid this
# by walking up to the workspace root on its own, so the build kept succeeding
# while every relative path around it missed.
#
# So: remember where the caller stood, because that is where the platform will
# look for the output, then move to the repository root to do the work.
set -euo pipefail

OUT="$PWD/vercel-static"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "--- called from : $PWD"
echo "--- repo root   : $ROOT"
echo "--- output to   : $OUT"

rm -rf "$OUT"
cd "$ROOT"

export COREPACK_ENABLE_DOWNLOAD_PROMPT=0
# Absolute, so the bundle lands where we asked no matter how the webpack
# config resolves its own paths.
export LICHTBLICK_OUT="$OUT"

# corepack, not plain yarn: the build image ships a global yarn that wins the
# PATH lookup, and the wrapper in .yarn refuses to run without COREPACK_ROOT.
corepack yarn web:build:prod

if [[ ! -f "$OUT/index.html" ]]; then
  echo "!! expected $OUT/index.html, which is not there. What the build wrote:"
  find "$ROOT" -maxdepth 3 -name index.html -not -path '*/node_modules/*' -not -path '*/e2e/*' || true
  find "$ROOT" -maxdepth 3 -name '.webpack' -not -path '*/node_modules/*' || true
  exit 1
fi
echo "--- $(find "$OUT" -type f | wc -l) files in $OUT"
