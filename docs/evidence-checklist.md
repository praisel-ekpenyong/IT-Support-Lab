# Evidence Checklist

Use this checklist to track screenshots and outputs captured for each lab. Mark items complete as you gather evidence.

---

## Lab 00: Lab Setup

| # | Evidence Item | Filename | Captured |
|---|---|---|---|
| 1 | VirtualBox Manager showing all three VMs listed | `lab00-step01-vbox-manager.png` | ☐ |
| 2 | DC-SERVER01 VM settings (CPU, RAM, disk) | `lab00-step02-dc-vm-specs.png` | ☐ |
| 3 | WS-CLIENT01 VM settings (CPU, RAM, disk) | `lab00-step03-client-vm-specs.png` | ☐ |
| 4 | UBUNTU-SVR01 VM settings (CPU, RAM, disk) | `lab00-step04-ubuntu-vm-specs.png` | ☐ |
| 5 | Network adapter config showing NAT and Internal Network | `lab00-step05-network-adapters.png` | ☐ |
| 6 | DC-SERVER01 static IP (`ipconfig /all`) | `lab00-step06-dc-static-ip.png` | ☐ |
| 7 | WS-CLIENT01 static IP (`ipconfig /all`) | `lab00-step07-client-static-ip.png` | ☐ |
| 8 | UBUNTU-SVR01 static IP (`ip addr show`) | `lab00-step08-ubuntu-static-ip.png` | ☐ |
| 9 | Ping test — Server to Client | `lab00-step09-ping-server-client.png` | ☐ |
| 10 | Ping test — Client to Server | `lab00-step10-ping-client-server.png` | ☐ |
| 11 | Ping test — Ubuntu to Server | `lab00-step11-ping-ubuntu-server.png` | ☐ |
| 12 | Internet connectivity from any VM | `lab00-step12-internet-test.png` | ☐ |

---

## Lab 01: Active Directory Basics

| # | Evidence Item | Filename | Captured |
|---|---|---|---|
| 1 | AD DS role installation summary (Server Manager) | `lab01-step01-adds-install.png` | ☐ |
| 2 | Domain controller promotion completion screen | `lab01-step02-dc-promotion.png` | ☐ |
| 3 | OU structure in Active Directory Users and Computers | `lab01-step03-ou-structure.png` | ☐ |
| 4 | User accounts created within OUs | `lab01-step04-user-accounts.png` | ☐ |
| 5 | Group Policy Object linked to OU | `lab01-step05-gpo-linked.png` | ☐ |
| 6 | GPO settings detail (e.g., password policy) | `lab01-step06-gpo-settings.png` | ☐ |
| 7 | Client machine successfully joined to domain | `lab01-step07-domain-join.png` | ☐ |
| 8 | DNS forward lookup zone with A records | `lab01-step08-dns-forward.png` | ☐ |
| 9 | `nslookup` test resolving domain name from client | `lab01-step09-dns-nslookup.png` | ☐ |
| 10 | `ping` test from client to domain controller by hostname | `lab01-step10-dns-ping.png` | ☐ |

---

## Lab 02: Networking Basics

| # | Evidence Item | Filename | Captured |
|---|---|---|---|
| 1 | `ipconfig /all` output showing IP, subnet, gateway, DNS | `lab02-step01-ipconfig.png` | ☐ |
| 2 | `ping` test to default gateway (successful) | `lab02-step02-ping-gateway.png` | ☐ |
| 3 | `ping` test to external host (e.g., 8.8.8.8) | `lab02-step03-ping-external.png` | ☐ |
| 4 | `ping` test to hostname (e.g., google.com) | `lab02-step04-ping-hostname.png` | ☐ |
| 5 | `tracert` output to external host | `lab02-step05-tracert.png` | ☐ |
| 6 | `nslookup` forward lookup result | `lab02-step06-nslookup-forward.png` | ☐ |
| 7 | `nslookup` reverse lookup result | `lab02-step07-nslookup-reverse.png` | ☐ |
| 8 | Completed subnet worksheet with calculations | `lab02-step08-subnet-worksheet.png` | ☐ |
| 9 | Network adapter settings in Control Panel | `lab02-step09-adapter-settings.png` | ☐ |
| 10 | `netstat` or connection test output | `lab02-step10-netstat.png` | ☐ |

---

## Lab 03: Windows Troubleshooting

| # | Evidence Item | Filename | Captured |
|---|---|---|---|
| 1 | Event Viewer showing a critical or error event | `lab03-step01-event-viewer-error.png` | ☐ |
| 2 | Event Viewer filtered view (e.g., last 24 hours) | `lab03-step02-event-viewer-filtered.png` | ☐ |
| 3 | Services console with a stopped service identified | `lab03-step03-services-stopped.png` | ☐ |
| 4 | Services console after restarting the service | `lab03-step04-services-restarted.png` | ☐ |
| 5 | `sfc /scannow` output showing scan results | `lab03-step05-sfc-scan.png` | ☐ |
| 6 | `DISM /Online /Cleanup-Image /RestoreHealth` output | `lab03-step06-dism-restore.png` | ☐ |
| 7 | Printer error or issue identified in Devices and Printers | `lab03-step07-printer-error.png` | ☐ |
| 8 | Printer driver reinstall or fix applied | `lab03-step08-printer-fix.png` | ☐ |
| 9 | Successful test print page | `lab03-step09-test-print.png` | ☐ |
| 10 | Remote support checklist completed (tools and steps) | `lab03-step10-remote-checklist.png` | ☐ |

---

## Lab 04: osTicket

| # | Evidence Item | Filename | Captured |
|---|---|---|---|
| 1 | osTicket installation page (prerequisites check) | `lab04-step01-install-prereqs.png` | ☐ |
| 2 | osTicket installation complete / success screen | `lab04-step02-install-complete.png` | ☐ |
| 3 | Admin panel dashboard after login | `lab04-step03-admin-panel.png` | ☐ |
| 4 | Help topics and departments configured | `lab04-step04-help-topics.png` | ☐ |
| 5 | New ticket creation form (end-user view) | `lab04-step05-ticket-create.png` | ☐ |
| 6 | Ticket detail view showing assignment and priority | `lab04-step06-ticket-detail.png` | ☐ |
| 7 | SLA plans configured in admin panel | `lab04-step07-sla-config.png` | ☐ |
| 8 | Ticket response and internal note added | `lab04-step08-ticket-response.png` | ☐ |
| 9 | Closed/resolved ticket view | `lab04-step09-ticket-closed.png` | ☐ |
| 10 | Ticket list showing multiple tickets in various states | `lab04-step10-ticket-list.png` | ☐ |

---

## Lab 05: PowerShell Basics

| # | Evidence Item | Filename | Captured |
|---|---|---|---|
| 1 | Script 1 source code open in editor or terminal | `lab05-step01-script1-code.png` | ☐ |
| 2 | Script 1 execution output | `lab05-step02-script1-output.png` | ☐ |
| 3 | Script 2 source code open in editor or terminal | `lab05-step03-script2-code.png` | ☐ |
| 4 | Script 2 execution output | `lab05-step04-script2-output.png` | ☐ |
| 5 | Script 3 source code open in editor or terminal | `lab05-step05-script3-code.png` | ☐ |
| 6 | Script 3 execution output | `lab05-step06-script3-output.png` | ☐ |
| 7 | PowerShell execution policy set (if changed) | `lab05-step07-execution-policy.png` | ☐ |
| 8 | Any error handling or edge case demonstration | `lab05-step08-error-handling.png` | ☐ |

---

## How to Use This Checklist

1. Complete each lab following the instructions in the `labs/` folder.
2. At each evidence item above, take a screenshot or copy the command output.
3. Save files to the `docs/screenshots/` folder using the filenames listed.
4. Mark the **Captured** column with ☑ once evidence is saved.
5. Review the completed checklist before adding your portfolio to a resume or GitHub profile.
