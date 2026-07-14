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

function Get-PrimaryIPv4Address {
    $route = Get-NetRoute -DestinationPrefix "0.0.0.0/0" -AddressFamily IPv4 |
        Sort-Object RouteMetric, ifMetric |
        Select-Object -First 1

    if (-not $route) {
        throw "Could not determine the primary IPv4 route for this machine."
    }

    $ipAddress = Get-NetIPAddress -AddressFamily IPv4 -InterfaceIndex $route.InterfaceIndex |
        Where-Object {
            $_.IPAddress -notlike "127.*" -and
            $_.IPAddress -notlike "169.254.*"
        } |
        Select-Object -ExpandProperty IPAddress -First 1

    if (-not $ipAddress) {
        throw "Could not determine the primary IPv4 address for this machine."
    }

    return $ipAddress
}
