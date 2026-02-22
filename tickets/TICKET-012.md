# TICKET-012: Need Disk Space Report for All Workstations

| Field              | Details                                      |
|--------------------|----------------------------------------------|
| **Ticket ID**      | TICKET-012                                   |
| **Date**           | 2026-02-16                                   |
| **Requester**      | IT Manager                                   |
| **Environment**    | Windows 11 Pro workstations (domain-joined), PowerShell 5.1 / 7.x, Active Directory |
| **Priority**       | Medium                                       |
| **Status**         | Closed                                       |
| **Tags**           | powershell, disk-space, automation, reporting |
| **Time to Resolve**| 50 minutes                                   |
| **Related Lab**    | [Lab 05 - PowerShell](../labs/lab-05-powershell.md) |
| **Related Incident** | [INC-004 - Slow PC / Disk Space Issue](../incidents/INC-004.md) |

---

## Problem Statement

The IT Manager requested a disk space audit across all domain-joined workstations ahead of the quarter-end deadline. Several users have recently reported slow performance (see INC-004), and the IT Manager suspects low disk space may be a contributing factor on multiple machines. A report is needed identifying workstations with less than 20% free disk space so that proactive cleanup can be performed.

---

## Questions Asked

1. **How many workstations need to be audited?**
   - Approximately 45 domain-joined workstations across three office locations.

2. **Do you want the report to cover all drives or just the system drive (C:)?**
   - Focus on the C: drive only, since that is where the OS and user profiles reside.

3. **What threshold should we flag for low disk space?**
   - Flag any machine with less than 20% free space on the C: drive.

4. **What format would you like the report in?**
   - A CSV file that can be opened in Excel, with columns for computer name, total disk size, free space, percent free, and a flag for machines below the threshold.

5. **Do we have remote PowerShell access (WinRM) enabled on all workstations?**
   - Yes, WinRM is enabled via Group Policy on all domain workstations.

6. **Should cleanup be performed automatically on flagged machines, or just reported?**
   - Report first. The IT Manager wants to review the list before any cleanup actions are taken.

---

## Troubleshooting Steps

1. **Retrieved the list of workstation computer names** from Active Directory using PowerShell:
   ```powershell
   $computers = Get-ADComputer -Filter "OperatingSystem -like '*Windows 11*'" -Property Name |
       Select-Object -ExpandProperty Name
   ```
   - Retrieved 45 workstation names from the domain.

2. **Ran the `Get-DiskSpaceReport.ps1` script** (from the Lab 05 PowerShell toolkit) against all workstations:
   ```powershell
   .\Get-DiskSpaceReport.ps1 -ComputerList $computers -DriveLetter C -ThresholdPercent 20 -OutputPath "C:\Reports\DiskSpaceReport_2026-02-16.csv"
   ```
   - The script remotely queried each workstation's C: drive via `Get-CimInstance Win32_LogicalDisk` over WinRM.
   - 43 of 45 machines responded. Two machines (WS-LAB-12 and WS-MKT-07) were offline and were noted in the report.

3. **Reviewed the generated CSV report.** Key findings:
   | Computer     | Total (GB) | Free (GB) | % Free | Flagged |
   |--------------|------------|-----------|--------|---------|
   | WS-FIN-03    | 476        | 38        | 8%     | Yes     |
   | WS-ENG-11    | 476        | 62        | 13%    | Yes     |
   | WS-HR-05     | 238        | 29        | 12%    | Yes     |
   | WS-MKT-02    | 476        | 81        | 17%    | Yes     |

   - **4 machines** were flagged below the 20% free space threshold.
   - The remaining 39 responsive machines had healthy disk space levels.

4. **Performed targeted disk cleanup** on the four flagged machines after receiving approval from the IT Manager:
   - Ran `cleanmgr /sageset:1` and `cleanmgr /sagerun:1` to clear temporary files, Windows Update cleanup, and Recycle Bin contents.
   - Cleared user temp directories (`$env:TEMP`, `C:\Windows\Temp`).
   - Identified and removed large stale log files in `C:\inetpub\logs` on WS-FIN-03 (over 15 GB of old IIS logs).
   - After cleanup, all four machines were above 25% free space.

5. **Generated a post-cleanup comparison report** showing before and after disk space for the flagged machines:
   | Computer     | Before (% Free) | After (% Free) | Space Recovered |
   |--------------|------------------|-----------------|-----------------|
   | WS-FIN-03    | 8%               | 32%             | 114 GB          |
   | WS-ENG-11    | 13%              | 28%             | 71 GB           |
   | WS-HR-05     | 12%              | 31%             | 45 GB           |
   | WS-MKT-02    | 17%              | 29%             | 57 GB           |

6. **Delivered both reports** (initial audit and post-cleanup) to the IT Manager via email and saved copies to the IT shared drive.

---

## Resolution

Used the `Get-DiskSpaceReport.ps1` PowerShell script to remotely audit disk space on 45 domain-joined workstations. Four machines were identified with C: drive free space below the 20% threshold. After receiving approval, disk cleanup was performed on all flagged machines — clearing temporary files, Windows Update caches, and stale application logs. All four machines were brought above 25% free space. Reports were delivered to the IT Manager in CSV format for review and record-keeping.

---

## Close Notes

- Both the initial audit report and the post-cleanup comparison report have been saved to `\\fileserver\IT\Reports\DiskSpace\`.
- Two offline machines (WS-LAB-12 and WS-MKT-07) still need to be audited when they come back online. A follow-up task has been created.
- Recommended scheduling the `Get-DiskSpaceReport.ps1` script as a monthly automated task via Windows Task Scheduler to proactively monitor disk space.
- Suggested implementing a Group Policy to enable Storage Sense on all workstations for automatic temporary file cleanup.
- This report supports the investigation into INC-004 (Slow PC performance), confirming that low disk space was a contributing factor on at least four machines.
