#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Build UI and copy to admin static directory

.DESCRIPTION
    This script builds the Vue.js UI project and copies the built files
    to the Go admin service's static directory for embedding.

.EXAMPLE
    .\build-ui.ps1
#>

param(
    [switch]$SkipInstall,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

if ($Help) {
    Write-Host @"
Go-LDAP-Admin UI Build Script

Usage: .\build-ui.ps1 [options]

Options:
    -SkipInstall    Skip npm install step
    -Help           Show this help message
"@
    exit 0
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$UIDir = Join-Path $ScriptDir "go-ldap-admin-ui"
$AdminDir = Join-Path $ScriptDir "go-ldap-admin"
$StaticDir = Join-Path $AdminDir "public\static\dist"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Go-LDAP-Admin UI Build Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[Step 1] Checking UI directory..." -ForegroundColor Yellow
if (-not (Test-Path (Join-Path $UIDir "package.json"))) {
    Write-Host "Error: UI directory not found at $UIDir" -ForegroundColor Red
    exit 1
}
Write-Host "UI directory found: $UIDir" -ForegroundColor Green

Push-Location $UIDir

if (-not $SkipInstall) {
    Write-Host ""
    Write-Host "[Step 2] Installing dependencies..." -ForegroundColor Yellow
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: npm install failed" -ForegroundColor Red
        Pop-Location
        exit 1
    }
} else {
    Write-Host ""
    Write-Host "[Step 2] Skipping npm install..." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[Step 3] Building UI..." -ForegroundColor Yellow
npm run build:prod
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: npm run build:prod failed" -ForegroundColor Red
    Pop-Location
    exit 1
}

Pop-Location

Write-Host ""
Write-Host "[Step 4] Cleaning old static files..." -ForegroundColor Yellow
if (Test-Path $StaticDir) {
    Remove-Item -Recurse -Force $StaticDir
}

Write-Host ""
Write-Host "[Step 5] Copying built files to admin static directory..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path $StaticDir -Force | Out-Null

$DistDir = Join-Path $UIDir "dist"
Copy-Item -Path "$DistDir\*" -Destination $StaticDir -Recurse -Force

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Build completed successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "UI files have been copied to:" -ForegroundColor White
Write-Host "  $StaticDir" -ForegroundColor Gray
Write-Host ""
Write-Host "You can now build the admin service:" -ForegroundColor White
Write-Host "  cd go-ldap-admin; go build" -ForegroundColor Gray
Write-Host ""
