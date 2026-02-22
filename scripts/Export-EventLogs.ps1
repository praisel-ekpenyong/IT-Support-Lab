<#
.SYNOPSIS
    Exports recent error events from the System and Application logs to CSV.

.DESCRIPTION
    Uses Get-WinEvent to query the System and Application event logs for
    Error-level events (Level 2).  By default the last 24 hours are
    queried; use -Hours to change the look-back window.

    The CSV file is written to the current directory with a timestamped
    filename, e.g. ErrorEvents_20250101_120000.csv.

    This script is intended for IT support lab and portfolio use.

.PARAMETER Hours
    Number of hours to look back from now.  Default is 24.

.PARAMETER OutputDirectory
    Directory where the CSV file will be saved.  Defaults to the current
    working directory.

.EXAMPLE
    .\Export-EventLogs.ps1
    Exports error events from the last 24 hours.

.EXAMPLE
    .\Export-EventLogs.ps1 -Hours 48
    Exports error events from the last 48 hours.

.EXAMPLE
    .\Export-EventLogs.ps1 -Hours 8 -OutputDirectory C:\Reports
    Exports the last 8 hours of errors to C:\Reports.

.NOTES
    Author : IT Support Lab
    Version: 1.0
    Purpose: Lab / Demo script for IT support portfolio
#>

#Requires -RunAsAdministrator

[CmdletBinding()]
param(
    [ValidateRange(1, 8760)]
    [int]$Hours = 24,

    [ValidateScript({ Test-Path $_ -PathType Container })]
    [string]$OutputDirectory = $PWD
)

# ── Configuration ────────────────────────────────────────────────────
$logNames  = @('System', 'Application')
$startTime = (Get-Date).AddHours(-$Hours)

Write-Host "`n=== Event Log Export ===" -ForegroundColor Cyan
Write-Host "Time range : $($startTime.ToString('yyyy-MM-dd HH:mm:ss')) to $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host "Log names  : $($logNames -join ', ')"
Write-Host "Filter     : Error (Level 2)`n"

# ── Query events ─────────────────────────────────────────────────────
$allEvents = @()

foreach ($logName in $logNames) {
    try {
        $filterHash = @{
            LogName   = $logName
            Level     = 2          # Error
            StartTime = $startTime
        }

        $events = Get-WinEvent -FilterHashtable $filterHash -ErrorAction Stop
        Write-Host "  [$logName] Found $($events.Count) error event(s)." -ForegroundColor Yellow
        $allEvents += $events
    } catch [Exception] {
        if ($_.Exception.Message -like '*No events were found*') {
            Write-Host "  [$logName] No error events found in the specified time range." -ForegroundColor Green
        } else {
            Write-Warning "  [$logName] Query failed: $($_.Exception.Message)"
        }
    }
}

# ── Handle empty results ─────────────────────────────────────────────
if ($allEvents.Count -eq 0) {
    Write-Host "`nNo error events found across all queried logs. Nothing to export." -ForegroundColor Green
    exit 0
}

# ── Build export data ────────────────────────────────────────────────
$exportData = $allEvents | Select-Object `
    TimeCreated,
    LogName,
    ProviderName,
    Id,
    @{ Name = 'Message'; Expression = { $_.Message -replace "`r`n", ' ' } }

# ── Write CSV ────────────────────────────────────────────────────────
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$csvPath   = Join-Path -Path $OutputDirectory -ChildPath "ErrorEvents_$timestamp.csv"

try {
    $exportData | Export-Csv -Path $csvPath -NoTypeInformation -ErrorAction Stop
    Write-Host "`nExported $($allEvents.Count) event(s) to: $csvPath" -ForegroundColor Green
} catch {
    Write-Error "Failed to write CSV file: $_"
    exit 1
}
