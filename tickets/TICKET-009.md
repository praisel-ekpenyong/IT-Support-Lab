# TICKET-009: Blue Screen Error on Startup

| Field              | Details                                      |
|--------------------|----------------------------------------------|
| **Ticket ID**      | TICKET-009                                   |
| **Date**           | 2026-01-26                                   |
| **Requester**      | James Martinez, Engineering Department       |
| **Environment**    | Dell OptiPlex 7090, Windows 11 Pro 23H2, 16 GB RAM, 512 GB NVMe SSD |
| **Priority**       | High                                         |
| **Status**         | Closed                                       |
| **Tags**           | windows-troubleshooting, bsod, system-repair |
| **Time to Resolve**| 60 minutes                                   |
| **Related Lab**    | [Lab 03 - Windows Troubleshooting](../labs/lab-03-windows-troubleshooting.md) |
| **Related Incident** | N/A                                        |

---

## Problem Statement

James Martinez reported that his workstation displays a blue screen of death (BSOD) with the stop code `CRITICAL_PROCESS_DIED` every time it attempts to boot into Windows. The machine enters a reboot loop and cannot reach the desktop. James needs the machine operational as he has a project deadline this week.

---

## Questions Asked

1. **When did this issue start?**
   - This morning. The PC was working fine yesterday when he shut it down at the end of the day.

2. **Were there any updates installed recently, or did you install any new software?**
   - Windows Update ran automatically yesterday afternoon before he shut down. He did not install any new software.

3. **Did you notice any unusual behavior before the issue started (slow performance, error messages)?**
   - No unusual behavior. Everything was normal yesterday.

4. **Is there any critical data on this machine that is not backed up?**
   - Most files are on the network share, but he has some local project files on the desktop he needs.

5. **Have you tried restarting the machine multiple times?**
   - Yes, tried three times. Each attempt results in the same blue screen during the Windows loading phase.

6. **Does the machine attempt to show the Automatic Repair screen?**
   - Yes, after two failed boots it shows "Preparing Automatic Repair," but Automatic Repair fails and reports it could not repair the PC.

---

## Troubleshooting Steps

1. **Accessed Advanced Startup Options** by forcing two failed boot attempts to trigger the Windows Recovery Environment (WinRE). Selected **Troubleshoot > Advanced options**.

2. **Attempted Startup Repair** from the recovery options:
   - Startup Repair ran but reported: "Startup Repair couldn't repair your PC."
   - Reviewed the SrtTrail.txt log, which indicated corrupted system files in the `C:\Windows\System32` directory.

3. **Booted into Safe Mode** via **Troubleshoot > Advanced options > Startup Settings > Restart > Safe Mode with Networking**:
   - The machine successfully booted into Safe Mode, confirming the hardware was functional and the issue was software-related.

4. **Checked Windows Event Viewer** in Safe Mode:
   - Found critical errors in the System log corresponding to the BSOD events.
   - Error details pointed to corrupted system binaries, likely caused by an interrupted or incomplete Windows Update.

5. **Ran System File Checker (SFC)** from an elevated Command Prompt in Safe Mode:
   ```
   sfc /scannow
   ```
   - SFC detected corrupted files but reported: "Windows Resource Protection found corrupt files but was unable to fix some of them."

6. **Ran DISM to repair the Windows image** before retrying SFC:
   ```
   DISM /Online /Cleanup-Image /CheckHealth
   DISM /Online /Cleanup-Image /ScanHealth
   DISM /Online /Cleanup-Image /RestoreHealth
   ```
   - DISM completed successfully and reported that the component store was repaired.

7. **Re-ran SFC** after DISM repair:
   ```
   sfc /scannow
   ```
   - SFC completed successfully: "Windows Resource Protection found corrupt files and successfully repaired them."

8. **Rebooted the machine normally** (exited Safe Mode):
   - Windows booted to the desktop without a blue screen.
   - Verified all user files on the desktop were intact.

9. **Checked for pending Windows Updates** and installed them cleanly to ensure the system was fully patched.

10. **Ran a disk health check** using `chkdsk C: /f /r` (scheduled for next reboot) to rule out underlying disk issues. Also checked SSD health via CrystalDiskInfo — SMART status reported "Good" with 94% life remaining.

---

## Resolution

The BSOD with `CRITICAL_PROCESS_DIED` was caused by corrupted Windows system files, likely resulting from an interrupted Windows Update the previous day. The machine was booted into Safe Mode, where DISM was used to repair the Windows component store, followed by SFC to restore the corrupted system binaries. After repair, the system booted normally and all user data was intact. A disk health check confirmed no underlying hardware issues with the SSD.

---

## Close Notes

- Workstation is fully operational and James has confirmed access to all his local files and applications.
- Windows Updates were re-applied successfully after the repair.
- Scheduled a follow-up disk check (`chkdsk`) to run on next reboot as a precaution.
- Recommended James enable OneDrive sync for his local desktop files to prevent future data risk.
- Documented the SFC/DISM repair process in the knowledge base for similar BSOD cases.
