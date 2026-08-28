#!/usr/bin/env bash
#
# Build the web app for the hosted deployment.
#
# This lives in a script rather than vercel.json because two earlier deploys
# failed at the last step — the build reported success while the output
# directory was nowhere to be found — and a one-line build command left no way
# to see what had actually been written. If the output goes missing again, the
# listing below says where it went.
set -euo pipefail

OUT="$PWD/vercel-static"
rm -rf "$OUT"

export COREPACK_ENABLE_DOWNLOAD_PROMPT=0
# Absolute, so the bundle lands here no matter how the config resolves paths.
export LICHTBLICK_OUT="$OUT"

# corepack, not plain yarn: the build image ships a global yarn that wins the
# PATH lookup, and the wrapper in .yarn refuses to run without COREPACK_ROOT.
corepack yarn web:build:prod

echo "--- build finished; cwd=$PWD"
if [[ ! -f "$OUT/index.html" ]]; then
  echo "!! expected $OUT/index.html, which is not there. What the build wrote:"
  find "$PWD" -maxdepth 3 -name index.html -not -path '*/node_modules/*' -not -path '*/e2e/*' || true
  find "$PWD" -maxdepth 3 -name '.webpack' -not -path '*/node_modules/*' || true
  ls -la "$PWD" "$PWD/web" || true
  exit 1
fi
echo "--- $(find "$OUT" -type f | wc -l) files in $OUT"
