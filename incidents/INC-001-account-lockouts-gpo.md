# INC-001: Account Lockouts After GPO Change

> **Simulated Incident** — IT Support Lab Environment

## Summary

Following a Group Policy Object (GPO) update to the domain password and account lockout policy, 15+ users across multiple departments were locked out of their Active Directory accounts within a two-hour window. The lockout threshold had been set to 3 invalid attempts, which proved too aggressive. Several workstations that had not been recently rebooted were still using cached (expired) credentials, triggering automatic lockouts before users could even attempt to log in manually.

## Severity

**SEV-B** — High impact, non-critical  
- **Response window:** 4 hours  
- **Coverage:** 24/7  
- **Justification:** Multiple users unable to work, but no data loss or security breach. Core infrastructure remained operational.

## Impact

| Metric | Detail |
|---|---|
| **Users affected** | 15+ across Finance, HR, and Operations |
| **Duration** | ~3 hours from first report to full resolution |
| **Business impact** | Affected users unable to log in to workstations or access network resources. Several time-sensitive finance reports were delayed. Helpdesk queue backed up with lockout calls, delaying other support requests. |

## Timeline

| Timestamp (UTC) | Event |
|---|---|
| 2026-01-15 07:00 | IT admin applies updated GPO (`Corp-PasswordPolicy-v2`) to the `Corp-Users` OU. New policy sets account lockout threshold to 3 invalid attempts with a 30-minute lockout duration. |
| 2026-01-15 07:45 | GPO begins propagating to domain-joined workstations during background refresh cycle. |
| 2026-01-15 08:20 | First lockout ticket received — Finance department user unable to log in after a single password attempt. |
| 2026-01-15 08:35 | Two more lockout reports from HR. Helpdesk begins unlocking accounts manually. |
| 2026-01-15 09:00 | Helpdesk escalates to Tier 2 after receiving 8 lockout calls in 40 minutes. Pattern identified: affected users are on workstations that have not been rebooted in 7+ days. |
| 2026-01-15 09:15 | Tier 2 reviews GPO change log and identifies the new lockout threshold. Confirms cached credentials on stale machines are generating failed authentication attempts against the domain controller. |
| 2026-01-15 09:30 | Decision made to adjust lockout threshold from 3 to 5 attempts. Emergency GPO update applied. |
| 2026-01-15 09:45 | `gpupdate /force` pushed to affected machines via remote PowerShell. Cached credentials cleared. Locked accounts unlocked in Active Directory. |
| 2026-01-15 10:15 | All affected users confirmed able to log in. Helpdesk queue returning to normal. |
| 2026-01-15 10:30 | Incident declared resolved. Post-incident review scheduled. |

## Detection

- **Method:** User-reported — helpdesk received multiple phone calls and ticket submissions from users unable to log in.
- **Gap identified:** No automated alerting was in place for bulk account lockout events. The pattern was only recognized after manual correlation by the helpdesk team.

## Triage

1. Helpdesk verified lockouts by checking account status in Active Directory Users and Computers (ADUC).
2. Ran `Get-ADUser -Filter {LockedOut -eq $true}` to enumerate all locked accounts — found 15 locked accounts.
3. Checked the domain controller Security Event Log for Event ID 4740 (account lockout) to identify the source machines.
4. Correlated lockout sources with machines that had extended uptime (`systeminfo | findstr "Boot Time"`).
5. Reviewed recent GPO changes in Group Policy Management Console — identified `Corp-PasswordPolicy-v2` applied at 07:00.

## Root Cause

Two contributing factors combined to cause the mass lockout:

1. **Overly aggressive lockout threshold:** The updated GPO set the account lockout threshold to 3 invalid attempts. This left almost no margin for normal user error (typos, caps lock, etc.).
2. **Cached/expired credentials on stale workstations:** Several workstations had not been rebooted in over a week. These machines had cached credentials from before the policy change. Background processes (mapped drives, scheduled tasks, Outlook) were attempting to authenticate with old credentials, consuming all 3 attempts and locking accounts before users even reached the login screen.

## Fix

1. **Adjusted lockout threshold:** Modified `Corp-PasswordPolicy-v2` to set the lockout threshold to 5 invalid attempts (up from 3), with a 15-minute observation window.
2. **Forced policy update:** Ran `Invoke-GPUpdate -Computer <hostname> -Force` on all affected machines via remote PowerShell session.
3. **Unlocked accounts:** Ran `Search-ADAccount -LockedOut | Unlock-ADAccount` to batch-unlock all locked accounts.
4. **Cleared cached credentials:** On machines with stale cached credentials, used Credential Manager to remove saved domain credentials and rebooted the machines.
5. **Verified resolution:** Confirmed each affected user could log in successfully.

## Validation

- All 15+ previously locked accounts confirmed unlocked in Active Directory.
- Affected users tested login from their workstations and confirmed access to network resources.
- Monitored domain controller Event ID 4740 for the following 2 hours — no new lockout events detected.
- Ran `Get-ADUser -Filter {LockedOut -eq $true}` again at 12:00 — returned zero results.

## Preventive Actions

| Action | Owner | Status |
|---|---|---|
| Test all GPO changes on a pilot OU (`Corp-Users-Pilot`) with 5–10 test accounts before applying to production OUs. | IT Admin | Planned |
| Configure automated alerting for bulk lockout events (5+ lockouts in 10 minutes) using a scheduled PowerShell script monitoring Event ID 4740. | IT Admin | Planned |
| Communicate password and lockout policy changes to all users at least 48 hours in advance via company email. | IT / HR | Planned |
| Establish a GPO change management checklist that includes rollback procedures and a communication plan. | IT Manager | Planned |
| Schedule regular workstation reboots (weekly) via GPO to prevent credential caching issues. | IT Admin | Planned |

## Customer Communication

> **Subject: [Resolved] Account Lockout Issues — January 15, 2026**
>
> Hello,
>
> Earlier today, some of you experienced issues logging into your workstations. This was caused by a recent update to our account security policy that temporarily affected account access. The issue has been fully resolved, and all accounts have been unlocked.
>
> **What happened:** A scheduled security policy update set login attempt limits that were too restrictive, which caused some accounts to lock automatically.
>
> **What we did:** We adjusted the policy settings, unlocked all affected accounts, and updated workstations to prevent recurrence.
>
> **What you need to do:** Nothing — your account should now work normally. If you are still unable to log in, please contact the helpdesk at ext. 4357 or submit a ticket.
>
> We apologize for the inconvenience and appreciate your patience. We are implementing additional safeguards to prevent this from happening again.
>
> Thank you,
> IT Support Team

## Related Tickets

- [TICKET-001: Password Reset — jsmith](../tickets/TICKET-001-password-reset-jsmith.md)
- [TICKET-007: Account Lockout — mjones](../tickets/TICKET-007-account-lockout-mjones.md)
