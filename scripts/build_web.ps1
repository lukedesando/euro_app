param(
    [switch] $PubGet
)

. "$PSScriptRoot\common.ps1"

Enter-RepoRoot
Assert-FileExists $FlutterExe "Flutter executable"

& "$PSScriptRoot\generate_config.ps1"

if ($PubGet) {
    & $FlutterExe build web
} else {
    & $FlutterExe build web --no-pub
}
