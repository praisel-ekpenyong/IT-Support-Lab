# TICKET-006: Computer Running Very Slowly

| Field              | Details                                      |
|--------------------|----------------------------------------------|
| **Date**           | 2026-02-09                                   |
| **Requester**      | Tom Brown, Sales Department                  |
| **Environment**    | Windows 10 Pro, Intel i5, 8 GB RAM, 256 GB SSD |
| **Tags**           | performance, disk-space, windows-troubleshooting |
| **Time to Resolve**| 45 minutes                                   |
| **Related Lab**    | [Lab 03 - Windows Troubleshooting](../labs/03-windows-troubleshooting/) |
| **Related Incident** | [INC-004 - Slow PC Due to Low Disk Space](../incidents/INC-004-slow-pc-disk-space.md) |

---

## Problem Statement

Tom Brown from Sales reported that his PC has been running extremely slowly for the past several days. It takes over **10 minutes to boot up**, applications freeze constantly, and he frequently sees the message **"Low Disk Space — You are running out of disk space on Local Disk (C:)."** He is unable to work effectively and has missed several client follow-up deadlines as a result.

## Questions Asked

1. **When did the slowness start?** — It has been getting progressively worse over the past two weeks but became unusable about three days ago.
2. **What applications do you use most frequently?** — Outlook, Chrome, the CRM application, and Excel.
3. **Have you installed any new software recently?** — No, but he has been downloading large client proposal files and saving them to his Desktop.
4. **Do you see any error messages?** — Yes, the "Low Disk Space" warning pops up frequently, and sometimes applications crash with "not enough memory" errors.
5. **Have you restarted the computer recently?** — Yes, he restarts it every day, but it takes so long to boot that he sometimes gives up and leaves it running overnight.
6. **Do you save files to the network share or locally?** — Mostly locally on the Desktop and in the Downloads folder.

## Troubleshooting Steps

1. Logged into Tom's workstation — boot time was approximately 11 minutes from power-on to a usable desktop.
2. Opened **File Explorer** and checked the C: drive properties:
   - **Total capacity:** 256 GB
   - **Used space:** 251 GB (98% full)
   - **Free space:** 5.1 GB
3. Opened **Task Manager** — observed that the **Disk** column showed 100% utilization almost continuously, with `System` and `SearchIndexer.exe` competing for I/O.
4. Ran `TreeSize Free` (portable version from USB) to identify the largest space consumers:
   - `C:\Users\tbrown\Desktop` — **42 GB** (client proposal files, videos, and zip archives)
   - `C:\Users\tbrown\Downloads` — **38 GB** (old installer files, duplicate downloads)
   - `C:\Users\tbrown\AppData\Local\Temp` — **18 GB** (temporary files never cleaned up)
   - `C:\Windows\Temp` — **6 GB**
   - `C:\Users\tbrown\AppData\Local\Google\Chrome\User Data` — **12 GB** (browser cache)
5. Discussed findings with Tom — he confirmed the Desktop and Downloads files could be moved to the network share `\\FS01\Sales\TBrown`.
6. Moved the Desktop files (42 GB) and Downloads files (38 GB) to the network share, then deleted the local copies after verifying the transfer.
7. Ran **Disk Cleanup** (`cleanmgr.exe`) as Administrator:
   - Selected: Temporary files, Temporary Internet Files, Recycle Bin, Windows Update Cleanup, Delivery Optimization Files.
   - Freed an additional **28 GB** of space.
8. Cleared Chrome browser cache: `Settings > Privacy and Security > Clear browsing data > Cached images and files` — recovered **10 GB**.
9. Deleted contents of `C:\Users\tbrown\AppData\Local\Temp` and `C:\Windows\Temp` — recovered **24 GB**.
10. Rechecked C: drive properties:
    - **Used space:** 109 GB
    - **Free space:** 147 GB (57% free)
11. Restarted the workstation — boot time improved to approximately **1 minute 45 seconds**.
12. Opened Task Manager — disk utilization was at normal levels (0–5%) at idle.
13. Launched Outlook, Chrome, and Excel simultaneously — all opened promptly with no freezing.
14. Configured a **Desktop shortcut** to Tom's network share folder for easy file saving.
15. Reported the pattern of local file hoarding to the team lead and opened Incident INC-004 to assess whether other Sales workstations have the same issue.

## Resolution

Tom's C: drive was 98% full (251 GB of 256 GB used), which caused severe performance degradation. The disk was saturated primarily by client proposal files saved to the Desktop (42 GB), accumulated downloads (38 GB), temporary files (24 GB), and browser cache (12 GB). Files were relocated to the `\\FS01\Sales\TBrown` network share, and temporary/cache files were cleared using Disk Cleanup and manual deletion. After freeing 142 GB of space (57% of the drive now free), boot time dropped from 11 minutes to under 2 minutes and application performance returned to normal. The issue was reported as Incident INC-004 to investigate whether other Sales department workstations have similar disk space problems.

## Close Notes

- Workstation performance fully restored. Boot time under 2 minutes, no application freezes observed.
- Created a network share shortcut on Tom's Desktop and educated him on saving files to the network share instead of locally.
- 142 GB of disk space recovered through file relocation and cleanup.
- Escalated as INC-004 to audit disk usage across all Sales department workstations.
- Recommended implementing a GPO to warn users when local disk usage exceeds 80% and to redirect the Desktop and Documents folders to the network share via Folder Redirection policy.
- Scheduled a follow-up check in two weeks to ensure disk usage remains at a healthy level.
