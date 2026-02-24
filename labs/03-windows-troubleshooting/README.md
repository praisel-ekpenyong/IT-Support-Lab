# Lab 03: Windows Troubleshooting

## Objective

Use Windows built-in diagnostic and repair tools to identify and resolve common system issues. This lab covers hands-on exercises with Event Viewer, the Services console, Task Manager, command-line repair utilities (SFC and DISM), and a realistic printer troubleshooting scenario. It also introduces secure remote support practices that align with professional IT helpdesk standards.

By the end of this lab you will be able to:

- Navigate Event Viewer to locate and interpret error and warning events.
- Manage Windows services through the Services console, including stopping, restarting, and changing startup types.
- Use Task Manager to assess system health and manage running processes.
- Run SFC and DISM from an elevated Command Prompt to detect and repair system file corruption.
- Troubleshoot a "printer not printing" scenario from start to finish.
- Follow a secure remote support checklist when assisting users remotely.

---

## Tools Used

| Tool | Purpose |
|------|---------|
| Windows 10 or Windows 11 | Host operating system for all exercises |
| Event Viewer (`eventvwr.msc`) | Review system, application, and security logs |
| Services console (`services.msc`) | Manage Windows services and their startup behavior |
| Task Manager (`Ctrl+Shift+Esc`) | Monitor processes, performance, and startup programs |
| Command Prompt (elevated) | Run `sfc` and `DISM` repair commands |
| Printer — physical or virtual (Microsoft Print to PDF) | Target device for the printer troubleshooting scenario |
| Remote Desktop / Quick Assist | Referenced for the secure remote support checklist |

---

## Diagram Description

```
┌─────────────────────────────────────────────────┐
│              Windows Workstation                 │
│                                                  │
│  ┌────────────┐  ┌────────────┐  ┌───────────┐  │
│  │ Event      │  │ Services   │  │ Task      │  │
│  │ Viewer     │  │ Console    │  │ Manager   │  │
│  └────────────┘  └────────────┘  └───────────┘  │
│                                                  │
│  ┌────────────┐  ┌─────────────────────────────┐ │
│  │ CMD        │  │ Printer (physical or virtual │ │
│  │ (SFC/DISM) │  │ e.g., Microsoft Print to PDF│ │
│  └────────────┘  └─────────────────────────────┘ │
└─────────────────────────────────────────────────┘
         │ (optional)
         ▼
   ┌───────────┐
   │ Network   │
   │ Printer   │
   └───────────┘
```

A single Windows workstation is used for every exercise. The workstation has Event Viewer, the Services console, Task Manager, and an elevated Command Prompt available. A printer — either a physical network printer or the built-in Microsoft Print to PDF virtual printer — is used for the printer troubleshooting scenario.

---

## Build Steps

### Part A — Event Viewer Exercises

1. Press `Win + R`, type `eventvwr.msc`, and press **Enter** to open Event Viewer.

2. In the left pane, expand **Windows Logs**. Click **System** to load the System log.

3. Scroll through the entries and note the four severity levels displayed in the **Level** column: **Information**, **Warning**, **Error**, and **Critical**.

4. Filter for errors and warnings only:
   - In the right-hand **Actions** pane click **Filter Current Log…**
   - In the dialog, check the boxes for **Critical**, **Error**, and **Warning**. Uncheck **Information** and **Verbose**.
   - Click **OK**. The view now shows only events that indicate problems.

5. Click on any **Error** event to select it. In the lower detail pane, record the following fields:
   - **Date and Time** — when the event occurred.
   - **Source** — the component that generated the event (e.g., `Service Control Manager`, `Disk`, `NTFS`).
   - **Event ID** — the numeric identifier (e.g., Event ID 7034 indicates a service terminated unexpectedly).
   - **Description** — the full text explaining what happened.

6. Switch to the **Application** log in the left pane and repeat the filtering process. Look for errors from sources such as `Application Error`, `Windows Error Reporting`, or `.NET Runtime`.

7. Practice creating a **Custom View**:
   - Right-click **Custom Views** in the left pane and select **Create Custom View…**
   - Set **Logged** to **Last 24 hours**, check **Error** and **Critical**, select **By log** → **Windows Logs** → **System**.
   - Name the custom view `Critical System Errors - Last 24h` and click **OK**.
   - This saved view can be reopened at any time without re-creating the filter.

8. Right-click any event and choose **Copy → Copy Details as Text**. Paste the output into a text file for your documentation.

### Part B — Services Console Exercises

1. Press `Win + R`, type `services.msc`, and press **Enter** to open the Services console.

2. The console lists every registered service in alphabetical order. Each row shows the **Name**, **Description**, **Status** (Running or blank), **Startup Type**, and **Log On As** account.

3. Scroll to **Print Spooler** and double-click it to open its properties. Note the following fields:
   - **Service name:** `Spooler`
   - **Display name:** Print Spooler
   - **Startup type:** Automatic
   - **Service status:** Running (if a printer is configured)

4. Click **Stop** to stop the Print Spooler service. Confirm the status changes to **Stopped**.

5. Click **Start** to restart it. Confirm the status returns to **Running**.

6. Change the **Startup type** dropdown and review each option:
   - **Automatic** — the service starts when Windows boots.
   - **Automatic (Delayed Start)** — the service starts shortly after boot to reduce startup load.
   - **Manual** — the service starts only when requested by another service or application.
   - **Disabled** — the service cannot start at all, even if another service depends on it.

7. Set the startup type back to **Automatic** and click **OK**.

8. Check the **Dependencies** tab to see which services Print Spooler depends on (typically HTTP and Remote Procedure Call) and which services depend on it.

9. Repeat this exercise with another service such as **Windows Update** (`wuauserv`) to practice stopping, starting, and reviewing dependencies.

### Part C — Task Manager Exercises

1. Press `Ctrl + Shift + Esc` to open Task Manager. If it opens in compact mode, click **More details** to expand it.

2. On the **Processes** tab, click the **CPU** column header to sort by CPU usage (highest first). Identify which process is consuming the most CPU time.

3. Click the **Memory** column header to sort by memory usage. Note the top three memory consumers and record their values.

4. Right-click a non-critical process (for example, a web browser with no unsaved work) and select **End task**. Confirm the process disappears from the list.

   > **Caution:** Never end system-critical processes such as `csrss.exe`, `svchost.exe`, or `winlogon.exe`. Doing so can cause a system crash.

5. Switch to the **Startup** tab. This tab lists programs that run automatically when you sign in. For each entry note:
   - **Name** — the application.
   - **Publisher** — the software vendor.
   - **Status** — Enabled or Disabled.
   - **Startup impact** — Low, Medium, or High.

6. Right-click any non-essential startup item (e.g., a chat application or cloud sync client) and select **Disable**. This prevents it from launching at next logon but does not uninstall it.

7. Switch to the **Performance** tab. Review the real-time graphs for:
   - **CPU** — current utilization percentage, speed, number of cores, and up-time.
   - **Memory** — total installed RAM, amount in use, available, and committed.
   - **Disk** — active time, read/write speeds.
   - **Network** — current throughput on each adapter.

8. Click **Open Resource Monitor** at the bottom of the Performance tab for more granular data, including per-process disk and network I/O.

### Part D — SFC and DISM

System File Checker (SFC) and Deployment Image Servicing and Management (DISM) are command-line tools that detect and repair corruption in Windows system files and the component store.

**When to use each tool:**

| Scenario | Tool to use first |
|----------|-------------------|
| General system instability, random errors | `sfc /scannow` |
| SFC reports it found corrupt files but could not fix them | `DISM /RestoreHealth`, then re-run SFC |
| Preparing a Windows image or ruling out component store issues | `DISM /CheckHealth` or `/ScanHealth` |

#### Running SFC

1. Right-click the **Start** button and select **Windows Terminal (Admin)** or **Command Prompt (Admin)**.

2. At the elevated prompt, run:

   ```
   sfc /scannow
   ```

3. The scan takes several minutes. Do not close the window. When it finishes it will report one of:
   - `Windows Resource Protection did not find any integrity violations.` — No corruption found.
   - `Windows Resource Protection found corrupt files and successfully repaired them.` — Issues found and fixed.
   - `Windows Resource Protection found corrupt files but was unable to fix some of them.` — Proceed to DISM.

4. Review the detailed log at `C:\Windows\Logs\CBS\CBS.log`. To extract only repair-related lines, run:

   ```
   findstr /c:"[SR]" %windir%\Logs\CBS\CBS.log > "%userprofile%\Desktop\SFC-Results.txt"
   ```

#### Running DISM

5. Run a quick health check (reads a flag in the registry — takes seconds):

   ```
   DISM /Online /Cleanup-Image /CheckHealth
   ```

6. Run a deeper scan of the component store (takes several minutes):

   ```
   DISM /Online /Cleanup-Image /ScanHealth
   ```

7. If either command reports corruption, run the repair command. This downloads clean copies of damaged files from Windows Update:

   ```
   DISM /Online /Cleanup-Image /RestoreHealth
   ```

8. After DISM completes, re-run SFC to confirm all system files are now intact:

   ```
   sfc /scannow
   ```

### Part E — Printer Troubleshooting Scenario

**Scenario:** A user reports "my printer won't print." Documents are sent to the printer but nothing comes out.

#### Step 1 — Check the Print Spooler Service

1. Open the Services console (`services.msc`).
2. Locate **Print Spooler**. If the status is blank (stopped), right-click it and select **Start**.
3. If the service is already running, right-click it and select **Restart** to clear any stale state.

#### Step 2 — Clear the Print Queue

A stuck print job can block all subsequent jobs.

1. Stop the Print Spooler service (right-click → **Stop** in `services.msc`, or run `net stop spooler` in an elevated Command Prompt).

2. Open File Explorer and navigate to:

   ```
   C:\Windows\System32\spool\PRINTERS
   ```

3. Delete all files in this folder. These are the queued print jobs.

4. Restart the Print Spooler service (`net start spooler` or through `services.msc`).

5. Open **Settings → Devices → Printers & scanners** (Windows 10) or **Settings → Bluetooth & devices → Printers & scanners** (Windows 11) and confirm the queue is now empty.

#### Step 3 — Verify Default Printer

1. In the Printers & scanners settings, confirm the correct printer is listed.
2. Click on the target printer and select **Manage** → **Set as default** (or ensure **Let Windows manage my default printer** is unchecked if you want to control this manually).

#### Step 4 — Check Printer Port Configuration

1. Open **Control Panel → Devices and Printers**.
2. Right-click the target printer and select **Printer properties** (not "Properties").
3. Go to the **Ports** tab. Verify the correct port is checked:
   - For a USB printer, it should be a `USB` port.
   - For a network printer, it should be a **Standard TCP/IP Port** with the correct IP address.
   - For a virtual printer (Microsoft Print to PDF), the port is `PORTPROMPT:`.
4. If the IP address is wrong (e.g., the printer received a new DHCP lease), update the port or create a new Standard TCP/IP Port with the correct IP.

#### Step 5 — Test Print

1. Return to **Printer properties → General** tab.
2. Click **Print Test Page**.
3. Confirm the test page prints successfully. If it does, the issue is resolved.

### Part F — Secure Remote Support Checklist

When providing remote assistance to a user, follow these practices to maintain security and professionalism:

| # | Practice | Details |
|---|----------|---------|
| 1 | **Get explicit consent** | Ask the user for permission before connecting. Never initiate a remote session without their knowledge. |
| 2 | **Verify user identity** | Confirm the user's name, employee ID, or department through your organization's identity verification process before proceeding. |
| 3 | **Use approved tools only** | Use only organization-sanctioned remote support tools such as Remote Desktop (RDP), Quick Assist, or your organization's remote management platform. Never use unauthorized third-party tools. |
| 4 | **Never ask for passwords** | If elevated credentials are needed, have the user type them in. Do not request that users share passwords verbally, in chat, or on screen. |
| 5 | **Explain your actions** | Narrate what you are doing so the user can follow along. This builds trust and helps the user learn. |
| 6 | **Document start and end time** | Record when the remote session begins and ends. Include this information in the support ticket. |
| 7 | **Close the session properly** | Disconnect the remote session when finished. Confirm with the user that the session has ended and that they have regained full control. |
| 8 | **Log the session** | Update the ticketing system with a summary of what was done, any changes made, and the resolution. |

---

## Validation Steps

| Exercise | How to confirm success |
|----------|----------------------|
| Event Viewer | You can locate a specific error by Event ID and Source, and you have a saved Custom View that filters to critical/error events from the last 24 hours. |
| Services console | Print Spooler stops and starts on command without errors. The startup type change persists after closing and reopening the properties dialog. |
| Task Manager | You can sort processes by CPU and memory, end a non-critical process, disable a startup item, and read the Performance tab graphs. |
| SFC | The command completes and reports either "no integrity violations" or "successfully repaired." The results are saved to a text file on the desktop. |
| DISM | `CheckHealth` and `ScanHealth` complete without errors, or `RestoreHealth` runs successfully and a follow-up SFC scan passes. |
| Printer troubleshooting | After clearing the queue and restarting the spooler, a test page prints successfully from the target printer. |
| Remote support checklist | You can recite or reference the eight checklist items without looking them up. |

---

## Troubleshooting

### Event Viewer shows thousands of entries and is hard to navigate

- Use **Filter Current Log** to narrow by severity level (Error, Critical), time range, and event source.
- Create and save **Custom Views** for recurring searches so you do not have to rebuild the filter each time.
- Use the **Find** feature (`Ctrl + F`) in the Actions pane to search for a specific Event ID or keyword.

### A service will not start

- Open the service's properties and check the **Dependencies** tab. Make sure every dependency service is running.
- Check the **Log On** tab. If the service runs under a specific account, the account credentials may have changed.
- Note the error code in the failure message (e.g., `Error 1068: The dependency service or group failed to start` or `Error 5: Access is denied`) and search the Microsoft documentation for that code.
- Review Event Viewer → System log for entries from `Service Control Manager` around the time of the failure for additional details.

### SFC finds corrupted files but cannot fix them

This usually means the component store itself is damaged and SFC cannot source clean replacement files.

1. Run `DISM /Online /Cleanup-Image /RestoreHealth` to repair the component store first.
2. After DISM completes successfully, re-run `sfc /scannow`.
3. If DISM also fails (e.g., no internet access for Windows Update), you can point DISM to a Windows installation ISO as a repair source:

   ```
   DISM /Online /Cleanup-Image /RestoreHealth /Source:D:\Sources\install.wim
   ```

   Replace `D:` with the drive letter of the mounted ISO.

### Print Spooler crashes repeatedly

- Clear the spool folder (`C:\Windows\System32\spool\PRINTERS`) as described in Part E. A corrupted print job is the most common cause.
- Check for problematic printer drivers. In **Print Management** (`printmanagement.msc`), review installed drivers and remove any that are outdated or from unverified publishers.
- Run `sfc /scannow` to verify that the spooler system files are not corrupt.
- Check Event Viewer → System log for crash details from the `Print Spooler` source.

### Printer shows "Offline" but is physically connected

- On the workstation, open the print queue for the printer (double-click the printer icon in **Devices and Printers**). In the menu bar, click **Printer** and uncheck **Use Printer Offline** if it is checked.
- For a network printer, verify connectivity: ping the printer's IP address from a Command Prompt. If the ping fails, check cables, Wi-Fi, or the printer's network configuration panel.
- Confirm the printer port IP matches the printer's current IP (the IP may have changed due to DHCP). Update the port in **Printer properties → Ports** if needed.
- Power-cycle the printer: turn it off, wait 30 seconds, and turn it back on.

---

## What I Learned

1. **Event Viewer is the first place to look** when diagnosing unexplained system behavior. Filtering by severity and time range turns a wall of log entries into actionable information.

2. **Services have dependencies.** Stopping or disabling one service can break others. Always check the Dependencies tab before making changes, and understand the difference between Automatic, Manual, and Disabled startup types.

3. **SFC and DISM work as a pair.** SFC checks and repairs individual system files, while DISM repairs the underlying component store that SFC draws from. When SFC cannot fix a problem on its own, running DISM first and then re-running SFC usually resolves it.

4. **Most printer issues trace back to the Print Spooler or a stuck print job.** Clearing the spool folder and restarting the service resolves the majority of "printer not printing" calls before you ever need to touch drivers or hardware.

5. **Secure remote support is a professional responsibility.** Getting consent, verifying identity, using approved tools, never handling passwords, and documenting every session protect both the user and the technician.

---

## Lessons From Mistakes

**Mistake: Accidentally stopping Windows Update while working on a different service**

During Part B (Services Console exercises), I was practicing stopping and restarting services to understand their behavior. While investigating a slow startup issue, I stopped the **Windows Update** service (`wuauserv`) intending to compare boot times — and then forgot to restart it.

Several minutes later, I noticed that a scheduled Windows Update check was silently failing in the background. There was no obvious error on the desktop, but the Windows Update settings page showed an indefinite spinning indicator and never completed its check.

I opened **Event Viewer → Windows Logs → System** and filtered for the `Service Control Manager` source. Event ID **7036** appeared with the description:

```
The Windows Update service entered the stopped state.
```

The timestamp matched exactly when I had manually stopped the service. I opened `services.msc`, located **Windows Update**, confirmed the startup type had been left as **Manual** (changed inadvertently during my earlier exercises), set it back to **Automatic (Delayed Start)**, and clicked **Start**. Windows Update immediately resumed its check and completed successfully.

**Key takeaway:** Services can affect other system behaviors in non-obvious ways. Always document which services you stop during troubleshooting exercises and verify their startup types before ending a session. Event ID 7036 in the System log is the definitive record of service state changes.

---

## Evidence Checklist

Use this list to capture proof of your work for portfolio documentation:

- [ ] Screenshot of Event Viewer filtered to Error and Critical events in the System log — [View sample output](../../docs/screenshots/lab03-event-viewer-sample.txt)
- [ ] Screenshot of the Custom View you created (`Critical System Errors - Last 24h`)
- [ ] Screenshot of an event's detail pane showing Event ID, Source, and Description
- [ ] Screenshot of the Print Spooler service properties showing Status and Startup Type
- [ ] Screenshot of the Services console after stopping and restarting Print Spooler
- [ ] Screenshot of Task Manager Processes tab sorted by CPU or Memory usage
- [ ] Screenshot of Task Manager Startup tab with a disabled item visible
- [ ] Screenshot of Task Manager Performance tab showing CPU and Memory graphs
- [ ] Terminal output of `sfc /scannow` completion message — [View sample output](../../docs/screenshots/lab03-sfc-scannow.txt)
- [ ] Terminal output of `DISM /Online /Cleanup-Image /CheckHealth`
- [ ] Terminal output of `DISM /Online /Cleanup-Image /ScanHealth`
- [ ] Contents of the extracted SFC results file (`SFC-Results.txt`)
- [ ] Screenshot of the empty spool folder after clearing the print queue
- [ ] Screenshot of a successful test page confirmation dialog
- [ ] Screenshot of printer port configuration showing the correct port type and address
- [ ] Copy of the Secure Remote Support Checklist filled out for a practice session
