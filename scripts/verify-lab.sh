#!/usr/bin/env bash
# Checks that the lab files of a release are complete and the data is unchanged. Reads files only; starts no agent.
#   bash scripts/verify-lab.sh [stage]      stage 0 to 4 = the last release you pulled (default: 4)
set -uo pipefail
cd "$(dirname "$0")/.."
source scripts/lib/check.sh

STAGE="${1:-4}"
case "$STAGE" in 0|1|2|3|4) ;; *) echo "stage must be 0 to 4" >&2; exit 2 ;; esac
SKILLS=".github/skills"
# have <path>: prints yes when the file or folder exists
have() { if [ -e "$1" ]; then echo yes; else echo "missing $1"; fi; }

# Release 0: the data
check "transcripts" 121 "$(ls data/transcripts/*.json | wc -l | tr -d ' ')"
check "triage agent files" 3 "$(ls data/triage-agent/*.md | wc -l | tr -d ' ')"
# Every transcript must match the checksum recorded when the data was built.
check "checksums" 0 "$(cd data/transcripts && shasum -a 256 -c ../transcripts.sha256 2>&1 | grep -c ': FAILED')"
# Counted straight from the files, not by the agent.
check "runs whose final answer is not JSON" 6 "$(grep -l '"final_is_json": false' data/transcripts/*.json | wc -l | tr -d ' ')"
check "runs that used the Bash tool" 4 "$(grep -l '"tool": "Bash"' data/transcripts/*.json | wc -l | tr -d ' ')"

# Release 1: section 1
if [ "$STAGE" -ge 1 ]; then
  check "section 1 prompts" yes "$(have prompts/01-measurable-target)"
  check "skill failure-modes" yes "$(have $SKILLS/failure-modes/SKILL.md)"
fi
# Release 2: section 2
if [ "$STAGE" -ge 2 ]; then
  check "section 2 prompts" yes "$(have prompts/02-eval-set)"
  check "skill eval-case" yes "$(have $SKILLS/eval-case/SKILL.md)"
fi
# Release 3: section 3
if [ "$STAGE" -ge 3 ]; then
  check "section 3 prompts" yes "$(have prompts/03-metrics)"
  check "skill eval-checks" yes "$(have $SKILLS/eval-checks/SKILL.md)"
  check "skill judge" yes "$(have $SKILLS/judge/SKILL.md)"
  check "reference cases" 12 "$(wc -l < data/reference/cases.jsonl | tr -d ' ')"
fi
# Release 4: section 4 and the second run set
if [ "$STAGE" -ge 4 ]; then
  check "section 4 prompts" yes "$(have prompts/04-regressions)"
  check "skill regression-check" yes "$(have $SKILLS/regression-check/SKILL.md)"
  check "after runs" 15 "$(ls data/after/*.json | wc -l | tr -d ' ')"
  check "after checksums" 0 "$(cd data/after && shasum -a 256 -c ../after.sha256 2>&1 | grep -c ': FAILED')"
  check "after runs that tried a shell command" 6 "$(grep -l '"tool": "Bash"' data/after/*.json | wc -l | tr -d ' ')"
fi

finish
