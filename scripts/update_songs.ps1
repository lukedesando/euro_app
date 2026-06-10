param(
    [Parameter(Mandatory = $true)]
    [int] $Year,

    [switch] $DryRun,
    [switch] $Yes,
    [switch] $Insecure
)

. "$PSScriptRoot\common.ps1"

Enter-RepoRoot
Assert-FileExists ".env" "Local .env file"

$Arguments = @("GetSongs.py", $Year)
if ($DryRun) {
    $Arguments += "--dry-run"
}
if ($Yes) {
    $Arguments += "--yes"
}
if ($Insecure) {
    $Arguments += "--insecure"
}

python @Arguments
