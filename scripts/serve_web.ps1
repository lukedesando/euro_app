param(
    [int] $Port = 8000
)

. "$PSScriptRoot\common.ps1"

Enter-RepoRoot
$BuildWebPath = Join-Path $RepoRoot "build\web"
Assert-DirectoryExists $BuildWebPath "Flutter web build output"

Set-Location $BuildWebPath
python -m http.server $Port
