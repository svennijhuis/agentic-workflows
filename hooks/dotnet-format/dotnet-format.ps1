# postToolUse: format a C# file right after the agent edits or creates it.
$ErrorActionPreference = 'Stop'
$hook = [Console]::In.ReadToEnd() | ConvertFrom-Json
if ($hook.toolName -notin 'edit', 'create', 'str_replace_editor', 'write') { exit 0 }
$toolArgs = $hook.toolArgs
if ($toolArgs -is [string]) { $toolArgs = $toolArgs | ConvertFrom-Json }
$path = if ($toolArgs.path) { $toolArgs.path } else { $toolArgs.file_path }
if (-not $path -or $path -notlike '*.cs' -or -not (Test-Path -LiteralPath $path)) { exit 0 }
$file = (Resolve-Path -LiteralPath $path).Path
# Nearest project above the file is the workspace; format needs one when the cwd has several.
$dir = Split-Path -Parent $file
$proj = $null
while ($dir -and -not $proj) {
  $proj = Get-ChildItem -LiteralPath $dir -Filter '*.csproj' -File | Select-Object -First 1
  $dir = Split-Path -Parent $dir
}
if (-not $proj) { exit 0 }
dotnet format $proj.FullName --no-restore --include $file 2>&1 | Write-Host
exit 0
