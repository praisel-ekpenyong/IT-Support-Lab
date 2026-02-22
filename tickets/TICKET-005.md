# TICKET-005: Printer Not Printing

| Field              | Details                                      |
|--------------------|----------------------------------------------|
| **Date**           | 2026-02-02                                   |
| **Requester**      | Amy Wilson, Accounting Department             |
| **Environment**    | Windows 10 Pro, Network Printer HP LaserJet M607 (Floor 2) |
| **Tags**           | printer, print-spooler, driver               |
| **Time to Resolve**| 35 minutes                                   |
| **Related Lab**    | [Lab 03 - Windows Troubleshooting](../labs/lab-03-windows-troubleshooting.md) |
| **Related Incident** | [INC-003 - Printer Failure After Driver Update](../incidents/INC-003.md) |

---

## Problem Statement

Amy Wilson from Accounting reported that she cannot print to the Floor 2 shared printer (HP LaserJet M607). Print jobs appear to be sent from her applications but nothing comes out of the printer. She can see multiple jobs stuck in the print queue. The issue has been ongoing since this morning and several other users on Floor 2 have the same problem.

## Questions Asked

1. **When did the issue start?** — This morning, around 8:00 AM. She tried to print a report and it never came out.
2. **Were you able to print yesterday?** — Yes, printing worked fine yesterday afternoon.
3. **Is the printer showing any error lights or messages on its display?** — No, the printer display shows "Ready" and the lights are normal.
4. **Have you tried printing from a different application?** — Yes, she tried from Excel and Notepad with the same result.
5. **How many jobs are stuck in the queue?** — She can see about 12 jobs in the queue, including several from other people.
6. **Did anything change recently, like a software update?** — She noticed Windows Update ran last night and the computer restarted this morning.

## Troubleshooting Steps

1. Walked to the Floor 2 printer to verify its physical status — printer was powered on, displayed "Ready," had paper loaded, and no paper jams were detected.
2. Printed a test page directly from the printer's control panel — test page printed successfully, confirming the printer hardware is functional.
3. Opened the print queue on Amy's workstation (`Control Panel > Devices and Printers > HP LaserJet M607`) — observed 12 jobs in a **"Printing"** or **"Error"** state, none completing.
4. Attempted to cancel all print jobs from the queue — jobs would not delete and showed **"Deleting"** status indefinitely.
5. Opened `services.msc` and located the **Print Spooler** service — status showed **Running**.
6. Stopped the Print Spooler service.
7. Navigated to `C:\Windows\System32\spool\PRINTERS` and deleted all files in the directory to clear the stuck spool files.
8. Restarted the Print Spooler service.
9. Print queue was now empty. Sent a test page from Notepad — the job entered the queue but immediately went to **"Error"** status and did not print.
10. Checked Windows Update history — confirmed that a printer driver update (`HP Universal Print Driver v7.2.0`) was installed the previous night via Windows Update.
11. Opened **Device Manager**, located the HP LaserJet M607 under **Print queues**, right-clicked and selected **Properties > Driver** tab.
12. Clicked **Roll Back Driver** to revert to the previous driver version (`HP Universal Print Driver v7.1.2`).
13. Restarted the Print Spooler service after the driver rollback.
14. Sent a test page from Notepad — job completed and the page printed successfully.
15. Had Amy print her Accounting report — confirmed it printed correctly.
16. Verified with two other Floor 2 users that they could also print after the driver rollback.
17. Reported the driver compatibility issue to the Infrastructure team and opened Incident INC-003.

## Resolution

Print jobs were failing for all users on the Floor 2 HP LaserJet M607 due to an incompatible printer driver update (`HP Universal Print Driver v7.2.0`) that was deployed via Windows Update overnight. The stuck print queue was cleared by stopping the Print Spooler service and deleting spool files from `C:\Windows\System32\spool\PRINTERS`. Rolling back the driver to the previous version (`v7.1.2`) restored printing functionality. The issue was escalated as Incident INC-003 to evaluate the driver update across all affected workstations and to block the problematic driver version in WSUS.

## Close Notes

- Printing restored on Amy's workstation and verified with two additional Floor 2 users.
- Print Spooler service restarted and functioning normally after queue clearance and driver rollback.
- Escalated to Infrastructure team as INC-003 to roll back the driver on all affected Floor 2 workstations and block the `v7.2.0` driver in WSUS.
- Recommended testing printer driver updates in a staging environment before allowing automatic deployment to production workstations.
- Total of approximately 12 print jobs were lost from the stuck queue; affected users were notified to resubmit their print jobs.
