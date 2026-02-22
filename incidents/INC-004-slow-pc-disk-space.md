# INC-004: Slow PC Performance Due to Low Disk Space

> **Simulated Incident** — IT Support Lab Environment

## Summary

Four workstations in the Sales department were reported as running critically slow, with applications taking minutes to open and frequent "Low Disk Space" warnings. Investigation revealed that the C: drives on all four machines were over 95% full. The root causes included accumulated Windows temp files, oversized Outlook PST files stored locally, and large data files that users had saved to their desktops and Documents folders instead of using the designated network shares.

## Severity

**SEV-C** — Moderate impact, localized  
- **Response window:** 8 hours  
- **Coverage:** Business hours  
- **Justification:** Issue limited to 4 workstations in a single department. Users could still perform basic tasks (slowly), and no data was at risk of loss. No impact to infrastructure or other departments.

## Impact

| Metric | Detail |
|---|---|
| **Users affected** | 4 users in the Sales department |
| **Duration** | ~6 hours from first report to full resolution (staggered across machines) |
| **Business impact** | Sales team members unable to work efficiently. CRM application took 3–5 minutes to load. Outlook was unresponsive for extended periods. Two users were unable to save new files due to zero free space. One user missed a client follow-up deadline due to inability to send email attachments. |

## Timeline

| Timestamp (UTC) | Event |
|---|---|
| 2026-01-27 08:15 | First Sales user (workstation SALES-PC01) submits ticket — "computer extremely slow, everything takes forever to open." |
| 2026-01-27 08:45 | Second user (SALES-PC02) calls helpdesk with same complaint. Helpdesk notes both are in the Sales department. |
| 2026-01-27 09:00 | Helpdesk remote-connects to SALES-PC01. Observes Task Manager showing 100% disk utilization. Checks disk space: C: drive shows 1.2 GB free of 256 GB (99.5% full). |
| 2026-01-27 09:15 | Helpdesk checks SALES-PC02 — C: drive has 3.8 GB free of 256 GB (98.5% full). Escalates to Tier 2 and proactively checks remaining Sales workstations. |
| 2026-01-27 09:30 | Tier 2 scans all Sales workstations remotely. Finds SALES-PC03 at 96% and SALES-PC04 at 95%. Other department machines are at normal levels (40–60% usage). |
| 2026-01-27 09:45 | Tier 2 runs disk analysis (`TreeSize` / `WinDirStat`) on SALES-PC01. Findings: 85 GB in `C:\Users\<user>\AppData\Local\Temp`, 45 GB PST file in `C:\Users\<user>\Documents\Outlook Files`, 60 GB of client proposal PDFs and Excel files on the Desktop. |
| 2026-01-27 10:00 | Similar pattern confirmed on all 4 machines. No disk space monitoring or folder redirection was in place for Sales. |
| 2026-01-27 10:30 | Begin remediation on SALES-PC01 (worst case). Run Disk Cleanup, clear temp files, move user data to `\\fileserver\Sales\` network share. |
| 2026-01-27 12:00 | SALES-PC01 and SALES-PC02 remediated. C: drives now at 45% and 50% usage respectively. Users report machines are "fast again." |
| 2026-01-27 13:30 | SALES-PC03 and SALES-PC04 remediated. All 4 machines healthy. |
| 2026-01-27 14:00 | Folder redirection GPO created and linked to Sales OU — redirects Desktop and Documents to network shares. |
| 2026-01-27 14:30 | Incident declared resolved. |

## Detection

- **Method:** User-reported — Sales users contacted helpdesk about slow performance.
- **Gap identified:** No disk space monitoring was deployed to any workstations. The IT team had no visibility into disk utilization trends and could not detect the problem proactively. Users were unaware that local storage was filling up or that they should be using network shares.

## Triage

1. Helpdesk remote-connected to the first reported machine and opened Task Manager — disk utilization was at 100%.
2. Ran `Get-PSDrive C | Select-Object Used, Free` — confirmed less than 2 GB free on a 256 GB drive.
3. Ran `Get-ChildItem -Path C:\Users -Recurse -ErrorAction SilentlyContinue | Sort-Object Length -Descending | Select-Object -First 20 FullName, @{N='SizeGB';E={[math]::Round($_.Length/1GB,2)}}` to identify the largest files.
4. Found three categories of disk consumers: Windows temp files, Outlook PST files, and user-saved data files.
5. Checked other Sales workstations proactively — found 2 more with critically low space.
6. Verified that no folder redirection or disk space monitoring policy was in place for the Sales OU.

## Root Cause

Multiple contributing factors led to the disk space exhaustion:

1. **No folder redirection:** Desktop and Documents folders were stored locally. Sales users saved large client files (proposals, contracts, presentations) to their desktops and Documents folders, consuming tens of gigabytes per machine.
2. **Oversized local PST files:** Outlook was configured with local PST files rather than an online Exchange mailbox or cached mode with a size limit. PST files had grown to 30–50 GB each.
3. **Accumulated temp files:** Windows temp directories (`%TEMP%`, `C:\Windows\Temp`), Windows Update cache (`C:\Windows\SoftwareDistribution`), and browser caches had never been cleaned and accumulated over months.
4. **No monitoring or alerting:** No disk space monitoring was in place to warn IT or users before space became critically low.
5. **No user education:** Users were not trained on the expectation to save work files to network shares rather than locally.

## Fix

1. **Ran Disk Cleanup on all 4 machines:**
   ```powershell
   # Automated disk cleanup — temp files, Windows Update cache, thumbnails
   cleanmgr /d C /sageset:1
   cleanmgr /d C /sagerun:1
   ```
2. **Cleared temp files manually** where Disk Cleanup missed:
   ```powershell
   Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
   Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
   Stop-Service wuauserv
   Remove-Item "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force
   Start-Service wuauserv
   ```
3. **Moved user data to network shares:** Worked with each user to move client files from Desktop and Documents to `\\fileserver\Sales\<username>\`. Verified files were accessible from the new location.
4. **Configured folder redirection via GPO:** Created and linked a GPO (`Sales-FolderRedirection`) to redirect Desktop and Documents to `\\fileserver\Sales\%USERNAME%\Desktop` and `\\fileserver\Sales\%USERNAME%\Documents` respectively.
5. **Configured Outlook cached mode limits:** Set Outlook to use cached Exchange mode with a 12-month sliding window to prevent unbounded PST growth.
6. **Verified disk space recovery:** Confirmed each machine had at least 40% free space after cleanup.

## Validation

- Checked all 4 workstations: free space ranged from 40% to 55% of total disk capacity.
- Users tested opening CRM application, Outlook, and Excel — all opened within normal time (under 10 seconds).
- Task Manager showed disk utilization at normal levels (0–15% at idle).
- Verified folder redirection was functioning: new files saved to Desktop appeared on `\\fileserver\Sales\<username>\Desktop`.
- "Low Disk Space" warnings no longer appearing on any of the 4 machines.
- Followed up with users the next morning — all reported normal performance.

## Preventive Actions

| Action | Owner | Status |
|---|---|---|
| Deploy `Get-DiskSpaceReport.ps1` as a scheduled task on all workstations. The script checks disk space daily and sends an email alert to the helpdesk if any machine falls below 20% free space. | IT Admin | Planned |
| Implement folder redirection via GPO for all OUs (not just Sales) to redirect Desktop and Documents to network shares. | IT Admin | In Progress |
| Set disk space threshold alerts at 80% and 90% utilization levels. | IT Admin | Planned |
| Configure Outlook cached Exchange mode with a 12-month sliding window organization-wide via GPO. | IT Admin | Planned |
| Educate users on saving files to network shares. Include in new employee onboarding and send a reminder to all staff. | IT / HR | Planned |
| Schedule quarterly disk space audits across all departments to identify trends before they become critical. | IT Admin | Planned |

## Customer Communication

> **Subject: [Resolved] Slow Computer Performance — Sales Department — January 27, 2026**
>
> Hello Sales team,
>
> Thank you for your patience today while we worked on resolving the slow performance issues on your workstations. All four affected computers have been cleaned up and are now running normally.
>
> **What happened:** Over time, temporary files and locally saved documents had filled up your computers' hard drives, which caused them to run very slowly.
>
> **What we did:** We cleaned up temporary files, freed up disk space, and moved your work documents to the network file server where they are properly backed up and accessible from any workstation. We also set up an automatic policy so that your Desktop and Documents folders now save directly to the network.
>
> **What you need to do:**
> - Your files have been moved to the network share. You should see them in your Desktop and Documents folders as before — they just live on the server now.
> - Going forward, please save work files to your Documents folder or the `S:\Sales` network drive. Avoid saving large files directly to the C: drive.
> - If you notice anything missing or have trouble finding a file, please contact the helpdesk at ext. 4357 immediately.
>
> We are also setting up automatic monitoring so that we can catch low disk space issues before they affect your work in the future.
>
> Thank you,
> IT Support Team

## Related Tickets

- [TICKET-006: Slow PC — asingh](../tickets/TICKET-006.md)
- [TICKET-012: Disk Space Alert — Sales PCs](../tickets/TICKET-012.md)
