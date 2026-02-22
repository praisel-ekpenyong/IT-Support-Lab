# INC-003: Printer Not Printing After Driver Update

> **Simulated Incident** — IT Support Lab Environment

## Summary

Following a printer driver update pushed via Group Policy, 8 users on Floor 2 lost the ability to print to the shared department printer (HP LaserJet Pro MFP M428). Print jobs appeared in the queue but never printed, and the Print Spooler service began crashing repeatedly on affected workstations. The issue was traced to an incompatible driver version that caused the spooler to fault when processing jobs for the specific printer model.

## Severity

**SEV-C** — Moderate impact, localized  
- **Response window:** 8 hours  
- **Coverage:** Business hours  
- **Justification:** Printing disruption limited to a single floor and department. Users could still perform all other work. Workaround available (email documents to users on other floors for printing).

## Impact

| Metric | Detail |
|---|---|
| **Users affected** | 8 users on Floor 2 (Marketing department) |
| **Duration** | ~4 hours from first report to full resolution |
| **Business impact** | Marketing team unable to print client-facing materials for a scheduled 14:00 meeting. Several users attempted to print repeatedly, creating large stuck queues. One user's workstation became unresponsive due to continuous spooler crashes. Temporary workaround: documents emailed to Floor 1 for printing. |

## Timeline

| Timestamp (UTC) | Event |
|---|---|
| 2026-01-22 06:00 | IT pushes printer driver update via GPO (`PrinterDrivers-Update-Jan2026`). Updated driver: HP Universal Print Driver v7.2.0. Previous driver: HP Universal Print Driver v7.1.2. |
| 2026-01-22 08:00 | Workstations begin applying GPO at logon. Driver update installs silently. |
| 2026-01-22 08:30 | First user on Floor 2 attempts to print. Job enters queue, shows "Printing" status briefly, then disappears. No output at printer. |
| 2026-01-22 08:45 | Second user reports same issue. First user tries printing again multiple times — queue fills with stuck jobs. |
| 2026-01-22 09:00 | User reports workstation is "freezing." Helpdesk remote-connects and observes Print Spooler service crashing and restarting in a loop (Event ID 7034 in System log). |
| 2026-01-22 09:15 | Helpdesk opens TICKET-005 and escalates to Tier 2 after confirming 4 users on Floor 2 are affected. |
| 2026-01-22 09:30 | Tier 2 checks Event Viewer on affected machine — finds faulting module in spoolsv.exe crash is the new HP driver DLL (`hpup7200.dll`). |
| 2026-01-22 09:45 | Tier 2 identifies the GPO-pushed driver update as the change. Confirms Floor 1 and Floor 3 printers use different models and are unaffected. |
| 2026-01-22 10:00 | Decision made to roll back the driver. Tier 2 removes HP UPD v7.2.0 from the Floor 2 print server queue and reinstalls v7.1.2. |
| 2026-01-22 10:30 | Stuck print queues cleared on all 8 affected workstations. Print Spooler service restarted. |
| 2026-01-22 10:45 | Test print from two workstations — prints successfully on Floor 2 printer. |
| 2026-01-22 11:00 | All 8 users confirmed printing is working. GPO updated to exclude Floor 2 printer from the v7.2.0 driver deployment. |
| 2026-01-22 11:15 | Incident declared resolved. |

## Detection

- **Method:** User-reported — Floor 2 users called helpdesk when print jobs were not producing output.
- **Gap identified:** No automated monitoring of Print Spooler health or print job completion rates. The issue was only identified after multiple users reported it independently.

## Triage

1. Helpdesk remote-connected to affected workstation and attempted a test print — job entered queue and vanished without printing.
2. Checked printer status on the print server — printer showed "Ready" with no errors.
3. Opened Event Viewer on the workstation — found repeated Event ID 7034 (Print Spooler service terminated unexpectedly) and application crash events referencing `hpup7200.dll`.
4. Checked printer driver version on affected machine — HP Universal Print Driver v7.2.0 (updated that morning).
5. Compared with a working machine on Floor 1 — Floor 1 machine still had v7.1.2 (different printer model, not targeted by the GPO).
6. Confirmed the GPO `PrinterDrivers-Update-Jan2026` was applied that morning to Floor 2 workstations.

## Root Cause

The HP Universal Print Driver v7.2.0 had a compatibility issue with the HP LaserJet Pro MFP M428 model used on Floor 2. Specifically:

1. **Driver incompatibility:** The v7.2.0 driver introduced a rendering change that caused a null pointer exception when processing jobs for the M428's specific PDL (Page Description Language) configuration.
2. **Spooler crash cascade:** Each failed print job caused the Print Spooler service (`spoolsv.exe`) to crash. Windows automatically restarted the service, but any queued jobs would immediately trigger another crash, creating a crash loop.
3. **No pre-deployment testing:** The driver update was pushed to all workstations in the GPO scope without first testing on a single machine with the Floor 2 printer model.

## Fix

1. **Rolled back printer driver:** Removed HP UPD v7.2.0 from the print server for the Floor 2 HP LaserJet queue and reinstalled HP UPD v7.1.2.
   ```powershell
   # On the print server
   Remove-PrinterDriver -Name "HP Universal Printing PCL 6 (v7.2.0)"
   Add-PrinterDriver -Name "HP Universal Printing PCL 6 (v7.1.2)"
   ```
2. **Cleared stuck print queues:** Stopped the Print Spooler, deleted pending jobs, and restarted the service on each affected workstation.
   ```powershell
   Stop-Service Spooler
   Remove-Item "$env:SystemRoot\System32\spool\PRINTERS\*" -Force
   Start-Service Spooler
   ```
3. **Restarted Print Spooler service:** Verified the service was running stably (no crash events for 15+ minutes).
4. **Updated GPO scope:** Modified `PrinterDrivers-Update-Jan2026` to exclude the Floor 2 printer from the v7.2.0 deployment until a compatible driver is available.
5. **Tested printing:** Sent test prints from two workstations to confirm normal operation.

## Validation

- All 8 affected users sent test prints successfully after the fix.
- Monitored Event Viewer on affected workstations for 1 hour — no Print Spooler crash events.
- Verified printer driver version on affected machines was back to v7.1.2.
- Checked print server queue — jobs processing normally, no stuck jobs.
- Marketing team confirmed they were able to print materials for their 14:00 meeting.

## Preventive Actions

| Action | Owner | Status |
|---|---|---|
| Test all printer driver updates on a single workstation per printer model before mass deployment via GPO. | IT Admin | Planned |
| Maintain a known-good driver version list for each printer model in the environment. | IT Admin | Planned |
| Create a rollback plan document for printer driver deployments, including steps to quickly revert to the previous version. | IT Admin | Planned |
| Deploy Print Spooler monitoring that alerts on repeated service crashes (Event ID 7034 threshold: 3 occurrences in 10 minutes). | IT Admin | Planned |
| Stage driver updates in phases: pilot group (2 machines) → department → organization-wide. | IT Manager | Planned |

## Customer Communication

> **Subject: [Resolved] Floor 2 Printing Issue — January 22, 2026**
>
> Hello Floor 2 team,
>
> We are writing to let you know that the printing issue affecting Floor 2 has been fully resolved. We understand this was frustrating, especially with time-sensitive printing needs, and we appreciate your patience.
>
> **What happened:** A printer driver update that was applied this morning turned out to be incompatible with the Floor 2 printer, which prevented print jobs from completing.
>
> **What we did:** We rolled back the driver to the previous working version, cleared all stuck print jobs, and verified that printing is working normally.
>
> **What you need to do:** You should be able to print normally now. If you had any documents stuck in the queue, you will need to resend them. If you experience any further printing issues, please contact the helpdesk at ext. 4357.
>
> We will be implementing a more thorough testing process for future driver updates to prevent this type of disruption.
>
> Thank you,
> IT Support Team

## Related Tickets

- [TICKET-005: Printer Not Working — Floor 2](../tickets/TICKET-005-printer-not-working-floor2.md)
