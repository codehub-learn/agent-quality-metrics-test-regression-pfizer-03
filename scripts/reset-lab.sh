#!/usr/bin/env bash
# Back to a clean start: removes what you created in eval/. The data in data/ is never touched.
#   bash scripts/reset-lab.sh          dry run: lists what would be deleted
#   bash scripts/reset-lab.sh --yes    deletes it
set -euo pipefail
cd "$(dirname "$0")/.."
if [ ! -d eval ]; then echo "Nothing to reset: eval/ does not exist."; exit 0; fi
if [ "${1:-}" = "--yes" ]; then
  rm -rf eval
  echo "eval/ removed. Run scripts/verify-lab.sh to check the data."
else
  echo "Dry run. These files in eval/ would be deleted:"
  find eval -type f
  echo "Run again with --yes to delete them."
fi
