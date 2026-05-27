param(
    [string] $HostName,
    [int] $Port = 0
)

. "$PSScriptRoot\common.ps1"

Enter-RepoRoot

function Get-EnvFileValue {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Name
    )

    $line = Get-Content ".env" | Where-Object { $_ -match "^\s*$Name\s*=" } | Select-Object -First 1
    if ($line -match "^\s*[^=]+\s*=\s*(.+)\s*$") {
        return $Matches[1].Trim()
    }

    return $null
}

if (-not $HostName) {
    $HostName = Get-EnvFileValue "API_HOST"
    if (-not $HostName) {
        $HostName = Get-EnvFileValue "DB_HOST"
    }
}

if ($Port -eq 0) {
    $portValue = Get-EnvFileValue "API_PORT"
    if (-not $portValue) {
        $portValue = Get-EnvFileValue "APP_PORT"
    }
    if (-not $portValue) {
        $portValue = Get-EnvFileValue "DB_PORT"
    }
    if (-not $portValue) {
        $portValue = "5000"
    }

    $Port = [int] $portValue
}

if (-not $HostName) {
    throw "No host was provided and API_HOST/DB_HOST could not be read from .env."
}

$uri = "http://${HostName}:${Port}/health"
Invoke-RestMethod -Uri $uri
