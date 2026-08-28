#!/usr/bin/env bash
#
# Build the web app for the hosted deployment.
#
# Reached through `yarn vercel:build`, not called directly. That matters: the
# platform's build command does not run in the repository root — plain
# `bash ci/vercel-build.sh` came back "No such file or directory" even though
# the file was in the cloned commit — while yarn locates the workspace root on
# its own and runs scripts from there. So yarn finds the repository, and the
# build command hands over the directory it started in as VERCEL_CWD, since
# that is where outputDirectory gets resolved.
set -euo pipefail

HERE="${VERCEL_CWD:-$PWD}"
OUT="$HERE/vercel-static"

echo "--- invoked from : $HERE"
echo "--- building in  : $PWD"
echo "--- output to    : $OUT"

rm -rf "$OUT"
export COREPACK_ENABLE_DOWNLOAD_PROMPT=0
# Absolute, so the bundle lands here whatever the webpack config makes of its
# own location.
export LICHTBLICK_OUT="$OUT"

corepack yarn webpack --mode production --progress --config web/webpack.config.ts

if [[ ! -f "$OUT/index.html" ]]; then
  echo "!! expected $OUT/index.html, which is not there. Around here:"
  ls -a "$HERE" || true
  find "$PWD" -maxdepth 3 -name index.html -not -path '*/node_modules/*' -not -path '*/e2e/*' || true
  exit 1
fi
echo "--- $(find "$OUT" -type f | wc -l) files in $OUT"
