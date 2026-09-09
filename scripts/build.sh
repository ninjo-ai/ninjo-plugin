#!/usr/bin/env bash
# Build the two archives from plugins/ninjo:
#   dist/ninjo-plugin.zip   the whole plugin (Claude: --plugin-dir, custom upload, org settings)
#   dist/ninjo-skills.zip   skills/ only (ChatGPT: the Skills step of the Ninjo app submission)
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
rm -rf dist && mkdir -p dist
claude plugin validate ./plugins/ninjo --strict
claude plugin validate . --strict
(cd plugins/ninjo && zip -qr "$ROOT/dist/ninjo-plugin.zip" . -x '*.DS_Store')
(cd plugins/ninjo && zip -qr "$ROOT/dist/ninjo-skills.zip" skills -x '*.DS_Store')
ls -l dist
