. "$PSScriptRoot\common.ps1"

Enter-RepoRoot
Assert-FileExists ".env" "Local .env file"

python app.py
