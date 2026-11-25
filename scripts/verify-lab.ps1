# Checks that the lab files of a release are complete and the data is unchanged. Reads files only; starts no agent.
#   pwsh -NoProfile -File scripts/verify-lab.ps1 [-Stage 0..4]     the last release you pulled (default: 4)
param([ValidateRange(0, 4)][int]$Stage = 4)
Set-Location (Join-Path $PSScriptRoot '..')
. "$PSScriptRoot/lib/check.ps1"

$skills = '.github/skills'
# Have <path>: yes when the file or folder exists
function Have($path) { if (Test-Path $path) { 'yes' } else { "missing $path" } }
function Failed-Checksums($folder, $list) {
  $bad = 0
  foreach ($line in Get-Content $list) {
    $hash, $name = $line -split '  ', 2
    if ((Get-FileHash "$folder/$name" -Algorithm SHA256).Hash -ne $hash.ToUpper()) { $bad++ }
  }
  $bad
}
function Count-Matching($pattern, $text) { (Select-String -Path $pattern -SimpleMatch $text -List).Count }

# Release 0: the data
Check 'transcripts' 121 (Get-ChildItem data/transcripts/*.json).Count
Check 'triage agent files' 3 (Get-ChildItem data/triage-agent/*.md).Count
# Every transcript must match the checksum recorded when the data was built.
Check 'checksums' 0 (Failed-Checksums 'data/transcripts' 'data/transcripts.sha256')
# Counted straight from the files, not by the agent.
Check 'runs whose final answer is not JSON' 6 (Count-Matching 'data/transcripts/*.json' '"final_is_json": false')
Check 'runs that used the Bash tool' 4 (Count-Matching 'data/transcripts/*.json' '"tool": "Bash"')

# Release 1: section 1
if ($Stage -ge 1) {
  Check 'section 1 prompts' yes (Have 'prompts/01-measurable-target')
  Check 'skill failure-modes' yes (Have "$skills/failure-modes/SKILL.md")
}
# Release 2: section 2
if ($Stage -ge 2) {
  Check 'section 2 prompts' yes (Have 'prompts/02-eval-set')
  Check 'skill eval-case' yes (Have "$skills/eval-case/SKILL.md")
}
# Release 3: section 3
if ($Stage -ge 3) {
  Check 'section 3 prompts' yes (Have 'prompts/03-metrics')
  Check 'skill eval-checks' yes (Have "$skills/eval-checks/SKILL.md")
  Check 'skill judge' yes (Have "$skills/judge/SKILL.md")
  Check 'reference cases' 12 (Get-Content data/reference/cases.jsonl).Count
}
# Release 4: section 4 and the second run set
if ($Stage -ge 4) {
  Check 'section 4 prompts' yes (Have 'prompts/04-regressions')
  Check 'skill regression-check' yes (Have "$skills/regression-check/SKILL.md")
  Check 'after runs' 15 (Get-ChildItem data/after/*.json).Count
  Check 'after checksums' 0 (Failed-Checksums 'data/after' 'data/after.sha256')
  Check 'after runs that tried a shell command' 6 (Count-Matching 'data/after/*.json' '"tool": "Bash"')
}

Finish-Checks
