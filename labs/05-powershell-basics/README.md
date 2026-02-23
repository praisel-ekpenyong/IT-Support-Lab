# Lab 05: PowerShell Basics

## Objective

Learn PowerShell fundamentals by creating and running three practical IT support scripts that automate common helpdesk tasks. By the end of this lab you will be able to:

- Query system information and format the output into actionable reports.
- Export Windows Event Log data to CSV for offline analysis and ticket documentation.
- Perform a local user password reset through a script with built-in safety checks.

The three scripts built in this lab are:

| Script | Purpose |
|--------|---------|
| `Get-DiskSpaceReport.ps1` | Report disk space on all local fixed drives and flag volumes that are running low. |
| `Export-EventLogs.ps1` | Export recent Error-level entries from the System and Application logs to CSV. |
| `Reset-LocalPassword.ps1` | Reset a local user account password (**safe demo with warnings**). |

These scripts mirror real tasks that appear in day-to-day IT support work—monitoring storage, reviewing logs, and managing user accounts.

---

## Tools Used

| Tool / Requirement | Details |
|--------------------|---------|
| **Operating System** | Windows 10, Windows 11, or Windows Server 2016 and later |
| **PowerShell** | Version 5.1 or later (ships with Windows 10+). Verify with `$PSVersionTable.PSVersion` |
| **Editor** | PowerShell ISE (built-in) or Visual Studio Code with the PowerShell extension |
| **Privileges** | Administrator — required for event log access and local user management |

> **Tip:** If you are running this lab inside a virtual machine (VirtualBox, Hyper-V, VMware), take a snapshot before you begin so you can roll back any changes.

---

## Diagram Description

```
┌──────────────────────────────────────────────────┐
│              Windows Workstation / Server         │
│                                                    │
│   ┌──────────────┐    ┌────────────────────────┐  │
│   │  PowerShell   │───▶│  Console Output         │  │
│   │  (Admin)      │    └────────────────────────┘  │
│   │               │                                 │
│   │  Scripts:     │    ┌────────────────────────┐  │
│   │  1. DiskSpace │───▶│  C:\Scripts\Output\     │  │
│   │  2. EventLogs │    │   ├─ DiskReport.csv     │  │
│   │  3. ResetPwd  │    │   ├─ EventErrors.csv    │  │
│   └──────────────┘    │   └─ ResetLog.txt        │  │
│                        └────────────────────────┘  │
└──────────────────────────────────────────────────┘
```

A single Windows workstation or server runs all three PowerShell scripts locally. Each script writes its results to the console **and/or** to CSV or text files in a designated output folder (`C:\Scripts\Output\`). No network connections or remote systems are required.

---

## Build Steps

### Part A — Environment Setup

**Step 1: Open PowerShell as Administrator**

1. Press **Win + X** and select **Windows PowerShell (Admin)** or **Terminal (Admin)**.
2. If prompted by User Account Control, click **Yes**.
3. Verify you see `Administrator:` in the title bar of the window.

**Step 2: Verify the PowerShell version**

```powershell
$PSVersionTable
```

Confirm that `PSVersion` is **5.1** or higher. Example output:

```
Name                           Value
----                           -----
PSVersion                      5.1.19041.3031
PSEdition                      Desktop
PSCompatibleVersions           {1.0, 2.0, 3.0, 4.0...}
```

**Step 3: Set the execution policy for this lab**

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

When prompted, type **Y** and press Enter. This allows locally-created scripts to run while still blocking unsigned scripts downloaded from the internet.

Verify the change:

```powershell
Get-ExecutionPolicy -List
```

You should see `RemoteSigned` next to the `CurrentUser` scope.

**Step 4: Create the working directory**

```powershell
New-Item -ItemType Directory -Path "C:\Scripts\Output" -Force
Set-Location -Path "C:\Scripts"
```

All scripts and output files will live under `C:\Scripts`.

---

### Part B — Script 1: Get-DiskSpaceReport.ps1

> **Reference:** The completed script is available at [`/scripts/Get-DiskSpaceReport.ps1`](/scripts/Get-DiskSpaceReport.ps1).

#### Purpose

Query every fixed local drive, calculate total size, free space, and percent free, then flag any drive that falls below a configurable threshold (default 20 %).

#### Step 5: Create the script

Open your editor and save the following as `C:\Scripts\Get-DiskSpaceReport.ps1`:

```powershell
<#
.SYNOPSIS
    Reports disk space for all fixed local drives.
.DESCRIPTION
    Retrieves disk information using Get-CimInstance, calculates
    percentage free, and flags drives below the warning threshold.
.PARAMETER WarningThreshold
    Percentage of free space below which a drive is flagged WARNING (default 20).
.PARAMETER CriticalThreshold
    Percentage of free space below which a drive is flagged CRITICAL (default 10).
.PARAMETER ExportCsv
    If specified, exports the report to C:\Scripts\Output\DiskReport.csv.
#>
param(
    [int]$WarningThreshold  = 20,
    [int]$CriticalThreshold = 10,
    [switch]$ExportCsv
)

$drives = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3"

if (-not $drives) {
    Write-Warning "No fixed drives found on this system."
    return
}

$report = foreach ($d in $drives) {
    $totalGB   = [math]::Round($d.Size / 1GB, 2)
    $freeGB    = [math]::Round($d.FreeSpace / 1GB, 2)
    $pctFree   = [math]::Round(($d.FreeSpace / $d.Size) * 100, 1)

    $status = if ($pctFree -le $CriticalThreshold) { "CRITICAL" }
              elseif ($pctFree -le $WarningThreshold) { "WARNING" }
              else { "OK" }

    [PSCustomObject]@{
        Drive      = $d.DeviceID
        TotalGB    = $totalGB
        FreeGB     = $freeGB
        PercentFree = $pctFree
        Status     = $status
    }
}

$report | Format-Table -AutoSize

if ($ExportCsv) {
    $path = "C:\Scripts\Output\DiskReport.csv"
    $report | Export-Csv -Path $path -NoTypeInformation
    Write-Host "Report exported to $path" -ForegroundColor Green
}
```

#### Step 6: Run the script

```powershell
.\Get-DiskSpaceReport.ps1
```

**Expected console output:**

```
Drive TotalGB FreeGB PercentFree Status
----- ------- ------ ----------- ------
C:    237.88  102.45        43.1 OK
D:     50.00    3.20         6.4 CRITICAL
```

To also export a CSV:

```powershell
.\Get-DiskSpaceReport.ps1 -ExportCsv
```

The file is saved to `C:\Scripts\Output\DiskReport.csv`.

#### Common Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `Access is denied` | PowerShell is not running as Administrator | Relaunch PowerShell with **Run as Administrator** |
| `No fixed drives found` | Running inside a container or minimal VM with no mapped disks | Add a virtual hard disk to the VM or run on a standard Windows install |

---

### Part C — Script 2: Export-EventLogs.ps1

> **Reference:** The completed script is available at [`/scripts/Export-EventLogs.ps1`](/scripts/Export-EventLogs.ps1).

#### Purpose

Pull recent **Error**-level events from the System and Application logs and export them to a CSV file so they can be attached to a support ticket or reviewed offline.

#### Step 7: Create the script

Save the following as `C:\Scripts\Export-EventLogs.ps1`:

```powershell
<#
.SYNOPSIS
    Exports recent Error-level events from System and Application logs.
.PARAMETER Hours
    How many hours back to search (default 24).
.PARAMETER OutputPath
    Path for the CSV output file.
#>
param(
    [int]$Hours       = 24,
    [string]$OutputPath = "C:\Scripts\Output\EventErrors.csv"
)

$startTime = (Get-Date).AddHours(-$Hours)

$logs = @("System", "Application")
$allEvents = @()

foreach ($log in $logs) {
    try {
        $events = Get-WinEvent -FilterHashtable @{
            LogName   = $log
            Level     = 2          # 2 = Error
            StartTime = $startTime
        } -ErrorAction Stop

        foreach ($e in $events) {
            $allEvents += [PSCustomObject]@{
                LogName     = $log
                TimeCreated = $e.TimeCreated
                Source      = $e.ProviderName
                EventID     = $e.Id
                Message     = ($e.Message -replace "`r`n", " ").Substring(0,
                    [Math]::Min(200, $e.Message.Length))
            }
        }
    }
    catch [Exception] {
        if ($_.Exception.Message -match "No events were found") {
            Write-Host "No Error events in '$log' log for the last $Hours hour(s)." `
                -ForegroundColor Yellow
        }
        else {
            Write-Warning "Failed to query '$log': $_"
        }
    }
}

if ($allEvents.Count -gt 0) {
    $allEvents | Sort-Object TimeCreated -Descending |
        Export-Csv -Path $OutputPath -NoTypeInformation
    Write-Host "Exported $($allEvents.Count) event(s) to $OutputPath" `
        -ForegroundColor Green
}
else {
    Write-Host "No Error events found in the last $Hours hour(s). Nothing to export." `
        -ForegroundColor Yellow
}
```

#### Step 8: Run the script

```powershell
.\Export-EventLogs.ps1
```

**Expected output (events found):**

```
Exported 14 event(s) to C:\Scripts\Output\EventErrors.csv
```

**Expected output (no events):**

```
No Error events in 'System' log for the last 24 hour(s).
No Error events in 'Application' log for the last 24 hour(s).
No Error events found in the last 24 hour(s). Nothing to export.
```

To search a wider window:

```powershell
.\Export-EventLogs.ps1 -Hours 72
```

Open the CSV file to inspect the columns:

```powershell
Import-Csv "C:\Scripts\Output\EventErrors.csv" | Format-Table -AutoSize
```

#### Common Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `No events were found` | No Error-level entries exist in that timeframe | This is normal — increase `-Hours` or check a different log level |
| `Attempted to perform an unauthorized operation` | Not running as Administrator | Relaunch with elevated privileges |

---

### Part D — Script 3: Reset-LocalPassword.ps1

> **Reference:** The completed script is available at [`/scripts/Reset-LocalPassword.ps1`](/scripts/Reset-LocalPassword.ps1).

> ⚠️ **WARNING — READ BEFORE RUNNING**
>
> This script **modifies local user accounts**. Only run it in a **lab or test environment** (virtual machine, sandbox, or dedicated test workstation). **Never** execute this on a production system without explicit written authorization from your organization.

#### Purpose

Reset the password for a local Windows user account. The script includes safety features: a confirmation prompt, input validation, and logging of every action to a text file.

#### Step 9: Create a test user (lab environment only)

Before testing the script, create a disposable local account:

```powershell
$securePass = ConvertTo-SecureString "OldP@ss1!" -AsPlainText -Force
New-LocalUser -Name "testuser" -Password $securePass -Description "Lab test account"
```

#### Step 10: Create the script

Save the following as `C:\Scripts\Reset-LocalPassword.ps1`:

```powershell
<#
.SYNOPSIS
    Resets the password of a local user account.
.DESCRIPTION
    Prompts for confirmation, resets the password, and logs the action.
    Intended for lab/test use only.
.PARAMETER Username
    The local account name whose password will be reset.
.PARAMETER NewPassword
    The new password to assign (must meet local complexity policy).
#>
param(
    [Parameter(Mandatory)]
    [string]$Username,

    [Parameter(Mandatory)]
    [string]$NewPassword
)

$logFile = "C:\Scripts\Output\ResetLog.txt"

# --- Safety confirmation ---
Write-Host ""
Write-Host "=======================================" -ForegroundColor Red
Write-Host "  PASSWORD RESET — LAB USE ONLY" -ForegroundColor Red
Write-Host "=======================================" -ForegroundColor Red
Write-Host ""
Write-Host "You are about to reset the password for:" -ForegroundColor Yellow
Write-Host "  Account : $Username"
Write-Host "  Computer: $env:COMPUTERNAME"
Write-Host ""

$confirm = Read-Host "Type YES to continue or anything else to cancel"
if ($confirm -ne "YES") {
    Write-Host "Operation cancelled." -ForegroundColor Cyan
    return
}

# --- Verify user exists ---
try {
    $user = Get-LocalUser -Name $Username -ErrorAction Stop
}
catch {
    Write-Warning "User '$Username' was not found on this computer."
    return
}

# --- Reset password ---
try {
    $securePassword = ConvertTo-SecureString $NewPassword -AsPlainText -Force
    Set-LocalUser -Name $Username -Password $securePassword -ErrorAction Stop

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry  = "$timestamp | Password reset for '$Username' by $env:USERNAME on $env:COMPUTERNAME"

    Add-Content -Path $logFile -Value $logEntry

    Write-Host ""
    Write-Host "Password for '$Username' has been reset successfully." -ForegroundColor Green
    Write-Host "Action logged to $logFile" -ForegroundColor Green
}
catch {
    Write-Warning "Failed to reset password: $_"
}
```

#### Step 11: Run the script

```powershell
.\Reset-LocalPassword.ps1 -Username "testuser" -NewPassword "P@ssw0rd123!"
```

**Expected output:**

```
=======================================
  PASSWORD RESET — LAB USE ONLY
=======================================

You are about to reset the password for:
  Account : testuser
  Computer: LAB-PC01

Type YES to continue or anything else to cancel: YES

Password for 'testuser' has been reset successfully.
Action logged to C:\Scripts\Output\ResetLog.txt
```

Verify the log entry:

```powershell
Get-Content "C:\Scripts\Output\ResetLog.txt"
```

```
2025-01-15 14:22:07 | Password reset for 'testuser' by Administrator on LAB-PC01
```

#### Safety Features

- **Confirmation prompt** — the script will not proceed unless the operator types `YES`.
- **User existence check** — exits gracefully if the account does not exist.
- **Audit logging** — every reset is appended to `ResetLog.txt` with a timestamp, operator name, and computer name.

#### Common Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `User 'testuser' was not found` | The account does not exist on this machine | Create it first (see Step 9) or check the spelling |
| `The password does not meet the password policy requirements` | Password is too short or does not include required complexity | Use a password that includes uppercase, lowercase, number, and special character (12+ chars recommended) |
| `Access is denied` | Not running as Administrator | Relaunch PowerShell with elevated privileges |

#### Step 12: Clean up the test user (optional)

```powershell
Remove-LocalUser -Name "testuser"
```

---

## Validation Steps

Use the following checks to confirm each script works correctly.

### Script 1 — Get-DiskSpaceReport.ps1

1. **Console output** — Run the script and verify that a formatted table appears listing at least one drive with columns: `Drive`, `TotalGB`, `FreeGB`, `PercentFree`, `Status`.
2. **CSV export** — Run with `-ExportCsv` and confirm `C:\Scripts\Output\DiskReport.csv` exists.
   ```powershell
   Test-Path "C:\Scripts\Output\DiskReport.csv"   # Should return True
   Import-Csv "C:\Scripts\Output\DiskReport.csv" | Format-Table
   ```
3. **Threshold flag** — If any drive has less than 20 % free space, verify the `Status` column shows `WARNING` or `CRITICAL`.

### Script 2 — Export-EventLogs.ps1

1. **CSV output** — Run the script and check that `C:\Scripts\Output\EventErrors.csv` is created (or a "No Error events" message appears).
   ```powershell
   Test-Path "C:\Scripts\Output\EventErrors.csv"
   ```
2. **CSV contents** — Open the CSV and confirm columns: `LogName`, `TimeCreated`, `Source`, `EventID`, `Message`.
   ```powershell
   Import-Csv "C:\Scripts\Output\EventErrors.csv" | Select-Object -First 5 | Format-Table
   ```
3. **Time range** — Run with `-Hours 1` and then `-Hours 168` (one week) to verify the time filter works.

### Script 3 — Reset-LocalPassword.ps1

1. **Confirmation prompt** — Run the script and type something other than `YES`. Verify the script cancels without making changes.
2. **Successful reset** — Run with `YES` and confirm the success message.
3. **Log file** — Verify `C:\Scripts\Output\ResetLog.txt` contains a timestamped entry.
   ```powershell
   Get-Content "C:\Scripts\Output\ResetLog.txt"
   ```
4. **Login test** — Attempt to log in (or use `runas`) with the test account and new password to confirm the password was actually changed.
   ```powershell
   runas /user:testuser cmd
   ```

---

## Troubleshooting

### Execution policy blocking scripts

**Symptom:** `File C:\Scripts\*.ps1 cannot be loaded because running scripts is disabled on this system.`

**Fix:**

```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

If group policy overrides this setting, use the bypass flag for testing only:

```powershell
powershell -ExecutionPolicy Bypass -File .\Get-DiskSpaceReport.ps1
```

### "Not recognized as a cmdlet" errors

**Symptom:** `The term 'Get-CimInstance' is not recognized as the name of a cmdlet...`

**Possible causes:**

- You are running an older version of PowerShell (below 3.0). Upgrade to PowerShell 5.1.
- A typo in the cmdlet name — PowerShell cmdlets follow the **Verb-Noun** pattern.

**Fix:** Confirm your version with `$PSVersionTable` and correct any typos.

### Running without Administrator privileges

**Symptom:** `Access is denied` or `Attempted to perform an unauthorized operation` when querying event logs or managing users.

**Fix:** Close the current PowerShell window. Right-click the PowerShell icon and select **Run as Administrator**, or press `Win + X` and choose the Admin option. Verify with:

```powershell
([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)
```

This should return `True`.

### Script path issues

**Symptom:** `The term '.\Get-DiskSpaceReport.ps1' is not recognized...`

**Possible causes:**

- Your current directory is not `C:\Scripts`.
- The file was saved with an incorrect name or extension.

**Fix:**

```powershell
Set-Location C:\Scripts
Get-ChildItem *.ps1          # Verify the files exist
.\Get-DiskSpaceReport.ps1    # Use .\ prefix for current-directory scripts
```

### Password complexity failures

**Symptom:** `The password does not meet the password policy requirements.`

**Fix:** Ensure the new password meets the local security policy (typically at least 8 characters including uppercase, lowercase, digit, and special character). Check the policy with:

```powershell
net accounts
```

---

## What I Learned

1. **PowerShell follows a Verb-Noun convention** — cmdlets like `Get-CimInstance`, `Get-WinEvent`, and `Set-LocalUser` are predictable once you know the pattern. Discoverability is built in: `Get-Command *EventLog*` lists every related cmdlet.

2. **Execution policies are a safety net, not a security boundary** — `RemoteSigned` is the practical default for IT work. It stops accidental execution of downloaded scripts while still allowing locally-authored automation.

3. **Structured output makes automation possible** — returning `[PSCustomObject]` instead of plain strings lets you pipe results into `Format-Table`, `Export-Csv`, `Where-Object`, and other cmdlets without string parsing.

4. **Error handling with `try`/`catch` is essential for production scripts** — the Event Log script gracefully handles "no events found" instead of throwing a wall of red text at the operator.

5. **Safety mechanisms belong in every script that modifies the system** — confirmation prompts, parameter validation, and audit logging (as shown in the password reset script) protect both the operator and the organization.

---

## Evidence Checklist

Capture the following screenshots or text outputs to document your lab work.

| # | Evidence | How to Capture |
|---|----------|----------------|
| 1 | PowerShell version output | Screenshot of `$PSVersionTable` |
| 2 | Execution policy list | Screenshot of `Get-ExecutionPolicy -List` |
| 3 | Disk space report — console | Screenshot of `.\Get-DiskSpaceReport.ps1` output — [View sample output](../../docs/screenshots/lab05-disk-report-output.txt) |
| 4 | Disk space report — CSV file | Screenshot of `Import-Csv .\Output\DiskReport.csv` piped to `Format-Table` |
| 5 | Event log export — console | Screenshot showing the export count or "no events" message — [View sample output](../../docs/screenshots/lab05-event-log-export.txt) |
| 6 | Event log export — CSV contents | Screenshot of `Import-Csv .\Output\EventErrors.csv` piped to `Select -First 5` then `Format-Table` |
| 7 | Password reset — confirmation prompt | Screenshot showing the warning banner and `YES` prompt |
| 8 | Password reset — success message | Screenshot of the "Password has been reset successfully" output — [View sample output](../../docs/screenshots/lab05-password-reset-log.txt) |
| 9 | Password reset — log file | Screenshot of `Get-Content .\Output\ResetLog.txt` |
| 10 | Cleanup confirmation | Screenshot showing test user removed or VM snapshot restored |

- [x] All 10 evidence items above captured and available in `docs/screenshots/`
