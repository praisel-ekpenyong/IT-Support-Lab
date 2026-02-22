# TICKET-003: No Internet Connection

| Field              | Details                                      |
|--------------------|----------------------------------------------|
| **Date**           | 2026-01-19                                   |
| **Requester**      | Lisa Park, Marketing Department              |
| **Environment**    | Windows 10 Pro, Wired Ethernet Connection    |
| **Tags**           | networking, connectivity, tcp-ip             |
| **Time to Resolve**| 25 minutes                                   |
| **Related Lab**    | [Lab 02 - Networking](../labs/lab-02-networking.md) |
| **Related Incident** | N/A                                        |

---

## Problem Statement

Lisa Park from Marketing called the helpdesk reporting that she cannot access any websites or email from her workstation. She receives a **"This site can't be reached"** error in Chrome and Outlook shows **"Disconnected"** in the status bar. The issue started this morning and other users on the same floor do not appear to be affected.

## Questions Asked

1. **When did the problem start?** — This morning when she arrived at approximately 8:30 AM.
2. **Was it working yesterday?** — Yes, everything was fine yesterday afternoon.
3. **Did anything change on your computer recently?** — The network team came by Friday afternoon and moved some cables at her desk for a desk relocation.
4. **Can you access any internal sites like the company intranet?** — No, nothing loads at all.
5. **Is the network cable plugged in and do you see a link light?** — Yes, the cable is plugged in and the green light is on.
6. **Are other people near you having the same issue?** — No, her neighbor can browse the internet normally.

## Troubleshooting Steps

1. Opened a command prompt on Lisa's workstation and ran `ipconfig /all`.
2. Observed the following configuration:
   - **IP Address:** 10.0.2.45
   - **Subnet Mask:** 255.255.255.0
   - **Default Gateway:** 10.0.1.1 *(incorrect — should be 10.0.2.1 for the Floor 2 subnet)*
   - **DNS Servers:** 10.0.0.10, 10.0.0.11
3. Ran `ping 10.0.2.1` (correct gateway) — received replies successfully.
4. Ran `ping 10.0.1.1` (configured gateway) — request timed out, confirming the gateway was unreachable from this subnet.
5. Ran `ping 8.8.8.8` — request timed out, confirming no internet connectivity.
6. Ran `ping 10.0.0.10` (DNS server) — received replies, confirming intra-network connectivity was functional.
7. Checked DHCP lease — the workstation was configured with a **static IP address** rather than DHCP.
8. Discovered that the network team had reconfigured the static IP settings during Friday's desk relocation and entered the wrong default gateway (10.0.1.1 instead of 10.0.2.1).
9. Corrected the default gateway to **10.0.2.1** in the network adapter TCP/IPv4 properties.
10. Ran `ping 8.8.8.8` — received replies successfully.
11. Ran `nslookup google.com` — name resolved correctly.
12. Opened Chrome and confirmed websites loaded properly. Verified Outlook reconnected and began syncing email.

## Resolution

The default gateway on Lisa's workstation was incorrectly configured as `10.0.1.1` (Floor 1 subnet) instead of `10.0.2.1` (Floor 2 subnet). This occurred during a desk relocation on Friday when the network team manually updated the static IP settings and entered the wrong gateway. Correcting the gateway to `10.0.2.1` restored full internet and email connectivity. The workstation uses a static IP due to a legacy application requirement.

## Close Notes

- Internet and email connectivity confirmed restored after correcting the default gateway.
- Notified the network team about the incorrect configuration so they can update their records.
- Recommended evaluating whether the static IP requirement still applies or if the workstation can be migrated to DHCP with a reservation to prevent manual configuration errors in the future.
- No other users affected — issue was isolated to this single workstation.
