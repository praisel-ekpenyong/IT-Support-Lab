<#
.SYNOPSIS
    Resets the password of a local user account (LAB / DEMO USE ONLY).

.DESCRIPTION
    ⚠️  LAB USE ONLY — Do not run on production systems without explicit
    authorization from your organisation's security team.

    This script resets the password for a specified local user account
    using Set-LocalUser.  It verifies the account exists, prompts for
    confirmation, performs the reset, and logs the action to a local
    log file.

    Designed as a safe, auditable demonstration for an IT support
    portfolio.

.PARAMETER Username
    The name of the local user account whose password will be reset.
    This parameter is mandatory.

.PARAMETER NewPassword
    The new password to assign to the account, supplied as a
    SecureString.  This parameter is mandatory.

.PARAMETER LogPath
    Path to the log file.  Defaults to PasswordResetLog.txt in the
    same directory as the script.

.EXAMPLE
    .\Reset-LocalPassword.ps1 -Username labuser -NewPassword (Read-Host -AsSecureString)
    Prompts for a new password interactively, then resets labuser's
    password after confirmation.

.EXAMPLE
    $pw = ConvertTo-SecureString 'P@ssw0rd!' -AsPlainText -Force
    .\Reset-LocalPassword.ps1 -Username testaccount -NewPassword $pw
    Resets the password using a pre-built SecureString (lab only).

.NOTES
    Author : IT Support Lab
    Version: 1.0
    Purpose: Lab / Demo script for IT support portfolio

    ⚠️  WARNING: This script modifies user credentials.  Use only in
    isolated lab environments or with proper change-management approval.
#>

#Requires -RunAsAdministrator

# ─────────────────────────────────────────────────────────────────────
# ⚠️  LAB USE ONLY — Do not run on production systems without
#     authorization from your organisation's security team.
# ─────────────────────────────────────────────────────────────────────

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string]$Username,

    [Parameter(Mandatory)]
    [SecureString]$NewPassword,

    [string]$LogPath = (Join-Path -Path $PSScriptRoot -ChildPath 'PasswordResetLog.txt')
)

# ── Display safety banner ────────────────────────────────────────────
Write-Host ''
Write-Host '╔══════════════════════════════════════════════════════════╗' -ForegroundColor Red
Write-Host '║  ⚠️  WARNING: LAB USE ONLY                              ║' -ForegroundColor Red
Write-Host '║  Do not run on production systems without authorization ║' -ForegroundColor Red
Write-Host '╚══════════════════════════════════════════════════════════╝' -ForegroundColor Red
Write-Host ''

# ── Verify the local user exists ─────────────────────────────────────
try {
    $user = Get-LocalUser -Name $Username -ErrorAction Stop
} catch {
    Write-Error "User '$Username' was not found on this system. Aborting."
    exit 1
}

Write-Host "Account found: $($user.Name)  (Enabled: $($user.Enabled))" -ForegroundColor Cyan

# ── Confirm before proceeding ────────────────────────────────────────
if ($PSCmdlet.ShouldProcess($Username, 'Reset local account password')) {
    # Additional manual confirmation for safety
    $confirm = Read-Host "Type YES to confirm password reset for '$Username'"
    if ($confirm -ne 'YES') {
        Write-Host 'Operation cancelled by user.' -ForegroundColor Yellow
        exit 0
    }
} else {
    Write-Host 'Operation cancelled (WhatIf or user declined).' -ForegroundColor Yellow
    exit 0
}

# ── Perform the password reset ───────────────────────────────────────
try {
    Set-LocalUser -Name $Username -Password $NewPassword -ErrorAction Stop
    Write-Host "Password for '$Username' has been reset successfully." -ForegroundColor Green
} catch {
    Write-Error "Failed to reset password for '$Username': $_"
    exit 1
}

# ── Log the action ───────────────────────────────────────────────────
$logEntry = "[{0}] Password reset for user '{1}' by {2}\{3}" -f `
    (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'),
    $Username,
    $env:COMPUTERNAME,
    $env:USERNAME

try {
    Add-Content -Path $LogPath -Value $logEntry -ErrorAction Stop
    Write-Host "Action logged to: $LogPath" -ForegroundColor Green
} catch {
    Write-Warning "Password was reset but logging failed: $_"
}
