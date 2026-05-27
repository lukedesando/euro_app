$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$DefaultFlutterRoot = "C:\Users\luked\Documents\GitHub\flutter"
$FlutterRoot = if ($env:FLUTTER_ROOT) { $env:FLUTTER_ROOT } else { $DefaultFlutterRoot }
$FlutterExe = Join-Path $FlutterRoot "bin\flutter.bat"
$DartExe = Join-Path $FlutterRoot "bin\cache\dart-sdk\bin\dart.exe"

function Enter-RepoRoot {
    Set-Location $RepoRoot
}

function Assert-FileExists {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path,

        [Parameter(Mandatory = $true)]
        [string] $Description
    )

    if (-not (Test-Path $Path -PathType Leaf)) {
        throw "$Description was not found at: $Path"
    }
}

function Assert-DirectoryExists {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path,

        [Parameter(Mandatory = $true)]
        [string] $Description
    )

    if (-not (Test-Path $Path -PathType Container)) {
        throw "$Description was not found at: $Path"
    }
}
