param(
    [string] $ServerHost,

    [string] $DbHost = "localhost",

    [string] $ApiHost = "api.desando.org",

    [string] $ApiBaseHttp = "https://api.desando.org",

    [string] $ApiBaseWs = "wss://api.desando.org",

    [int] $ApiPort = 5000,

    [int] $WebPort = 8000,

    [switch] $PubGet,

    [switch] $RestartBackend,

    [switch] $RestartWeb,

    [switch] $SkipBuild,

    [switch] $SkipLocalHealthCheck
)

. "$PSScriptRoot\common.ps1"

Enter-RepoRoot

if (-not $ServerHost) {
    $ServerHost = Get-PrimaryIPv4Address
}

function Get-PortProcessIds {
    param(
        [Parameter(Mandatory = $true)]
        [int] $Port
    )

    $connections = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
    if (-not $connections) {
        return @()
    }

    return $connections | Select-Object -ExpandProperty OwningProcess -Unique
}

function Stop-PortListeners {
    param(
        [Parameter(Mandatory = $true)]
        [int] $Port,

        [Parameter(Mandatory = $true)]
        [string] $Label
    )

    $processIds = Get-PortProcessIds -Port $Port
    if (-not $processIds -or $processIds.Count -eq 0) {
        Write-Host "$Label was not running on port $Port."
        return
    }

    foreach ($processId in $processIds) {
        try {
            Stop-Process -Id $processId -Force -ErrorAction Stop
            Write-Host "Stopped $Label process on port $Port (PID $processId)."
        } catch {
            throw "Failed to stop $Label on port $Port (PID $processId): $($_.Exception.Message)"
        }
    }
}

function Ensure-BackgroundScript {
    param(
        [Parameter(Mandatory = $true)]
        [string] $ScriptPath,

        [Parameter(Mandatory = $true)]
        [string] $Label,

        [Parameter(Mandatory = $true)]
        [int] $Port,

        [string[]] $ArgumentList = @()
    )

    $processIds = Get-PortProcessIds -Port $Port
    if ($processIds -and $processIds.Count -gt 0) {
        Write-Host "$Label is already listening on port $Port."
        return
    }

    Start-Process `
        -FilePath "powershell.exe" `
        -ArgumentList @(
            "-NoProfile",
            "-ExecutionPolicy", "Bypass",
            "-File", $ScriptPath
        ) + $ArgumentList `
        -WorkingDirectory $RepoRoot `
        -WindowStyle Hidden | Out-Null

    Start-Sleep -Seconds 2

    $updatedProcessIds = Get-PortProcessIds -Port $Port
    if (-not $updatedProcessIds -or $updatedProcessIds.Count -eq 0) {
        throw "$Label did not start listening on port $Port."
    }

    Write-Host "$Label started on port $Port."
}

Write-Host "Publishing public event mode..."
Write-Host "  ServerHost=$ServerHost"
Write-Host "  DbHost=$DbHost"
Write-Host "  API_BASE_HTTP=$ApiBaseHttp"
Write-Host "  API_BASE_WS=$ApiBaseWs"

& "$PSScriptRoot\configure_location.ps1" `
    -ServerHost $ServerHost `
    -DbHost $DbHost `
    -ApiHost $ApiHost `
    -ApiPort $ApiPort `
    -ApiBaseHttp $ApiBaseHttp `
    -ApiBaseWs $ApiBaseWs

if (-not $SkipBuild) {
    if ($PubGet) {
        & "$PSScriptRoot\build_web.ps1" -PubGet
    } else {
        & "$PSScriptRoot\build_web.ps1"
    }
} else {
    Write-Host "Skipping web build."
}

if ($RestartBackend) {
    Stop-PortListeners -Port $ApiPort -Label "Backend"
}

if ($RestartWeb) {
    Stop-PortListeners -Port $WebPort -Label "Web server"
}

Ensure-BackgroundScript -ScriptPath (Join-Path $PSScriptRoot "run_backend.ps1") -Label "Backend" -Port $ApiPort
Ensure-BackgroundScript -ScriptPath (Join-Path $PSScriptRoot "serve_web.ps1") -Label "Web server" -Port $WebPort -ArgumentList @("-Port", "$WebPort")

if (-not $SkipLocalHealthCheck) {
    $health = & "$PSScriptRoot\health_check.ps1" -HostName "127.0.0.1" -Port $ApiPort
    Write-Host "Local API health:" ($health | ConvertTo-Json -Compress)
}

Write-Host ""
Write-Host "Public event mode is ready."
Write-Host "Refresh https://eurovision.desando.org in the browser."
Write-Host "If the page still looks stale, do one hard refresh to bypass the Flutter service worker cache."
