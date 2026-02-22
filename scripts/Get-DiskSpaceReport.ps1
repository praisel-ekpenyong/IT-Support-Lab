<#
.SYNOPSIS
    Reports disk space usage on all local fixed drives.

.DESCRIPTION
    Queries all fixed local drives using CIM/WMI, calculates total size,
    free space, and percent free for each drive.  Drives are flagged as
    OK (>20 % free), WARNING (10-20 %), or CRITICAL (<10 %).

    Results are displayed as a formatted table.  Use -ExportCsv to also
    write the report to a CSV file in the current directory.

    This script is intended for IT support lab and portfolio use.

.PARAMETER ExportCsv
    When specified, exports the report to a timestamped CSV file in the
    current working directory.

.EXAMPLE
    .\Get-DiskSpaceReport.ps1
    Displays a disk space report for all fixed drives.

.EXAMPLE
    .\Get-DiskSpaceReport.ps1 -ExportCsv
    Displays the report and saves it to a CSV file.

.NOTES
    Author : IT Support Lab
    Version: 1.0
    Purpose: Lab / Demo script for IT support portfolio
#>

#Requires -RunAsAdministrator

[CmdletBinding()]
param(
    [switch]$ExportCsv
)

# ── Thresholds (percent free) ────────────────────────────────────────
$WarningThreshold  = 20
$CriticalThreshold = 10

# ── Collect drive information ────────────────────────────────────────
try {
    $drives = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType = 3" -ErrorAction Stop
} catch {
    Write-Error "Failed to query disk information: $_"
    exit 1
}

if (-not $drives) {
    Write-Warning "No fixed drives were found on this system."
    exit 0
}

# ── Build report objects ─────────────────────────────────────────────
$report = foreach ($drive in $drives) {
    $totalGB   = [math]::Round($drive.Size / 1GB, 2)
    $freeGB    = [math]::Round($drive.FreeSpace / 1GB, 2)
    $pctFree   = if ($drive.Size -gt 0) {
        [math]::Round(($drive.FreeSpace / $drive.Size) * 100, 1)
    } else {
        0
    }

    $status = switch ($true) {
        ($pctFree -lt $CriticalThreshold) { 'CRITICAL'; break }
        ($pctFree -lt $WarningThreshold)  { 'WARNING';  break }
        default                            { 'OK' }
    }

    [PSCustomObject]@{
        Drive       = $drive.DeviceID
        VolumeName  = $drive.VolumeName
        TotalGB     = $totalGB
        FreeGB      = $freeGB
        PercentFree = $pctFree
        Status      = $status
    }
}

# ── Display results ──────────────────────────────────────────────────
Write-Host "`n=== Disk Space Report - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ===" -ForegroundColor Cyan
$report | Format-Table -AutoSize

# ── Optional CSV export ──────────────────────────────────────────────
if ($ExportCsv) {
    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $csvPath   = Join-Path -Path $PWD -ChildPath "DiskSpaceReport_$timestamp.csv"

    try {
        $report | Export-Csv -Path $csvPath -NoTypeInformation -ErrorAction Stop
        Write-Host "Report exported to: $csvPath" -ForegroundColor Green
    } catch {
        Write-Error "Failed to export CSV: $_"
    }
}
