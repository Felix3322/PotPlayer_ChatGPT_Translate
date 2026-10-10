param(
    [string]$BuildDir = $PSScriptRoot,
    [string]$ReleaseSuffix = '',
    [string]$VersionOverride = '',
    [string]$OutputDir = ''
)

$ErrorActionPreference = 'Stop'

function Get-IsccPath {
    $command = Get-Command ISCC.exe -ErrorAction SilentlyContinue
    if ($command -and (Test-Path $command.Source)) {
        return $command.Source
    }

    $candidates = @(
        'C:\Program Files (x86)\Inno Setup 6\ISCC.exe',
        'C:\Program Files\Inno Setup 6\ISCC.exe'
    )

    foreach ($candidate in $candidates) {
        if (Test-Path $candidate) {
            return $candidate
        }
    }

    throw 'Inno Setup Compiler (ISCC.exe) not found.'
}

$projectRoot = (Resolve-Path (Join-Path $BuildDir '..')).Path
$outputDirectory = if ([string]::IsNullOrWhiteSpace($OutputDir)) {
    Join-Path $projectRoot 'releases\latest'
} else {
    [System.IO.Path]::GetFullPath($OutputDir)
}
$outputBaseName = if ([string]::IsNullOrWhiteSpace($OutputDir)) { 'installer' } else { 'installer-inno' }
$outputExe = Join-Path $outputDirectory ($outputBaseName + '.exe')

Write-Host 'Preparing generated Inno installer data...'
$version = & (Join-Path $BuildDir 'prepare_installer.ps1') -ProjectRoot $projectRoot -BuildDir $BuildDir -ReleaseSuffix $ReleaseSuffix -VersionOverride $VersionOverride -PassThruVersion
if ([string]::IsNullOrWhiteSpace($version)) {
    throw 'Failed to determine plugin version.'
}
$version = $version.Trim()
$numericVersion = ($version -split '-', 2)[0]
if ($numericVersion -notmatch '^\d+\.\d+\.\d+$') { throw "Invalid installer numeric version: $version" }

$iscc = Get-IsccPath
Write-Host "Using ISCC: $iscc"

New-Item -ItemType Directory -Path (Split-Path -Parent $outputExe) -Force | Out-Null

$scriptPath = Join-Path $BuildDir 'installer.iss'
Write-Host 'Building Inno Setup installer...'
& $iscc '/Qp' ("/DPluginVersion=$version") ("/DPluginNumericVersion=$numericVersion") ("/O$outputDirectory") ("/F$outputBaseName") $scriptPath
if ($LASTEXITCODE -ne 0) {
    throw 'Inno Setup build failed.'
}

Write-Host "Installer build finished: $outputExe"
