param(
    [Parameter(Mandatory = $true)]
    [string] $ServerHost,

    [string] $DbHost,

    [string] $ApiHost,

    [int] $ApiPort = 5000,

    [string] $ApiBaseHttp,

    [string] $ApiBaseWs,

    [switch] $Https
)

. "$PSScriptRoot\common.ps1"

Enter-RepoRoot
Assert-FileExists ".env" "Local .env file"

if (-not $DbHost) {
    $DbHost = $ServerHost
}

if (-not $ApiHost) {
    $ApiHost = $ServerHost
}

function Build-BaseUrl {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Scheme,

        [Parameter(Mandatory = $true)]
        [string] $Host,

        [Parameter(Mandatory = $true)]
        [int] $Port
    )

    $defaultPort = if ($Scheme -eq "https" -or $Scheme -eq "wss") { 443 } else { 80 }
    if ($Port -eq $defaultPort) {
        return "${Scheme}://${Host}"
    }

    return "${Scheme}://${Host}:${Port}"
}

$httpScheme = if ($Https) { "https" } else { "http" }
$wsScheme = if ($Https) { "wss" } else { "ws" }

if (-not $ApiBaseHttp) {
    $ApiBaseHttp = Build-BaseUrl -Scheme $httpScheme -Host $ApiHost -Port $ApiPort
}

if (-not $ApiBaseWs) {
    $ApiBaseWs = Build-BaseUrl -Scheme $wsScheme -Host $ApiHost -Port $ApiPort
}

function Set-EnvFileValue {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Name,

        [Parameter(Mandatory = $true)]
        [string] $Value
    )

    $lines = [System.Collections.Generic.List[string]]::new()
    $lines.AddRange([string[]](Get-Content ".env"))
    $pattern = "^\s*#?\s*$([regex]::Escape($Name))\s*="
    $replacement = "$Name=$Value"

    for ($index = 0; $index -lt $lines.Count; $index++) {
        if ($lines[$index] -match $pattern) {
            $lines[$index] = $replacement
            Set-Content -Path ".env" -Value $lines -Encoding UTF8
            return
        }
    }

    $lines.Add($replacement)
    Set-Content -Path ".env" -Value $lines -Encoding UTF8
}

function Write-RuntimeConfig {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path
    )

    $directory = Split-Path -Parent $Path
    if (-not (Test-Path $directory -PathType Container)) {
        return
    }

    $config = [ordered]@{
        API_HOST = $ApiHost
        API_PORT = "$ApiPort"
        API_BASE_HTTP = $ApiBaseHttp
        API_BASE_WS = $ApiBaseWs
    }

    $config | ConvertTo-Json | Set-Content -Path $Path -Encoding UTF8
}

Set-EnvFileValue "DB_HOST" $DbHost
Set-EnvFileValue "API_HOST" $ApiHost
Set-EnvFileValue "API_PORT" "$ApiPort"
Set-EnvFileValue "API_BASE_HTTP" $ApiBaseHttp
Set-EnvFileValue "API_BASE_WS" $ApiBaseWs

Write-RuntimeConfig "web\config.json"
Write-RuntimeConfig "build\web\config.json"

Write-Host "Configured location:"
Write-Host "  DB_HOST=$DbHost"
Write-Host "  API_BASE_HTTP=$ApiBaseHttp"
Write-Host "  API_BASE_WS=$ApiBaseWs"
