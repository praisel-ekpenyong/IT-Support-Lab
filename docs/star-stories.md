# STAR Stories for Interview Preparation

These STAR (Situation, Task, Action, Result) stories are based on simulated incidents completed in the IT Support Lab environment. Use them to practice behavioral interview responses for helpdesk and IT support roles.

---

## 1. Account Lockouts After GPO Change

**Situation:**
In a simulated Active Directory lab environment, a Group Policy Object update was applied to enforce a stricter account lockout policy. Shortly after the change, multiple user accounts began locking out, and users were unable to log in to the domain.

**Task:**
Identify the root cause of the widespread account lockouts and restore user access while keeping the environment secure under the updated policy.

**Action:**
I reviewed the recently modified GPO settings in the Group Policy Management Console and identified that the lockout threshold had been set lower than intended. I checked the Security event logs on the domain controller to confirm repeated failed authentication attempts triggering the lockouts. After verifying the root cause, I adjusted the lockout threshold to an appropriate value, then used Active Directory Users and Computers to unlock the affected accounts. I documented the correct policy values and the steps taken to prevent recurrence.

**Result:**
All affected accounts were unlocked within minutes, and the corrected GPO was validated against best practices. The incident was documented with root cause analysis, and the experience reinforced the importance of testing Group Policy changes in a staging OU before broad deployment.

---

## 2. DNS Resolution Failure Affecting Logins and Web Access

**Situation:**
In a lab environment with a Windows Server domain controller acting as the DNS server, a client machine suddenly lost the ability to resolve domain names. Users on the client could not log in to the domain or access internal web resources.

**Task:**
Diagnose the DNS resolution failure on the client machine and restore both domain authentication and web access.

**Action:**
I started by running `nslookup` on the client machine and confirmed that DNS queries were timing out. I checked the network adapter settings with `ipconfig /all` and found that the preferred DNS server was pointing to an incorrect IP address. I corrected the DNS server setting to point to the domain controller, then flushed the DNS cache with `ipconfig /flushdns`. On the server side, I verified that the DNS Server service was running and that the forward lookup zone contained the correct A records for the domain.

**Result:**
DNS resolution was restored immediately after correcting the client configuration. Domain logins and web access resumed without further issues. I documented the troubleshooting steps and added DNS server verification to the standard client setup checklist to prevent similar misconfigurations.

---

## 3. Printer Not Printing After Driver Update

**Situation:**
In a Windows troubleshooting lab scenario, a network printer stopped producing output after a driver update was applied. Print jobs were queuing but not printing, and users reported that the printer appeared online in the Devices and Printers console.

**Task:**
Determine why print jobs were stuck in the queue and restore normal printing functionality.

**Action:**
I opened the print queue for the affected printer and observed that several jobs were stuck in a "Printing" or "Error" state. I stopped the Print Spooler service using `services.msc`, cleared the contents of the `C:\Windows\System32\spool\PRINTERS` directory, and restarted the Print Spooler service. Since the issue began after a driver update, I removed the recently installed driver through Print Management, then reinstalled the previous stable driver from the manufacturer. I sent a test page to confirm the fix.

**Result:**
The printer successfully produced the test page and resumed processing queued jobs. The root cause was an incompatible driver version that caused jobs to stall in the spooler. I documented the working driver version and the rollback steps so the issue could be quickly resolved if it recurred.

---

## 4. Slow PC Due to Low Disk Space

**Situation:**
In a simulated support scenario, a user reported that their Windows workstation had become extremely slow. Applications were taking minutes to open, and the system was displaying low disk space warnings on the C: drive.

**Task:**
Identify what was consuming disk space, free up sufficient storage, and restore normal system performance.

**Action:**
I opened File Explorer and confirmed the C: drive was at 98% capacity. I ran Disk Cleanup as an administrator to remove temporary files, Windows Update cache, and system error memory dumps. I then used PowerShell to scan for large files and identified several oversized log files and forgotten installer packages in the user's Downloads folder. After clearing unnecessary files, I also reviewed the Recycle Bin and emptied it. Finally, I checked for disk fragmentation and verified that Windows had adequate free space for virtual memory and updates.

**Result:**
Over 15 GB of disk space was recovered, bringing the drive down to 62% utilization. System responsiveness returned to normal within minutes. I documented the cleanup steps and recommended setting up a scheduled PowerShell script to alert on low disk space conditions before they impact performance.
