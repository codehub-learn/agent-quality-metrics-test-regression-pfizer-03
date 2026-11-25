# Back to a clean start: removes what you created in eval/. The data in data/ is never touched.
#   pwsh -NoProfile -File scripts/reset-lab.ps1          dry run: lists what would be deleted
#   pwsh -NoProfile -File scripts/reset-lab.ps1 -Yes     deletes it
param([switch]$Yes)
Set-Location (Join-Path $PSScriptRoot '..')
if (-not (Test-Path eval)) { Write-Host 'Nothing to reset: eval/ does not exist.'; return }
if ($Yes) {
  Remove-Item -Recurse -Force eval
  Write-Host 'eval/ removed. Run scripts/verify-lab.ps1 to check the data.'
} else {
  Write-Host 'Dry run. These files in eval/ would be deleted:'
  Get-ChildItem eval -Recurse -File | ForEach-Object { $_.FullName.Substring((Get-Location).Path.Length + 1) -replace '\\', '/' }
  Write-Host 'Run again with -Yes to delete them.'
}
