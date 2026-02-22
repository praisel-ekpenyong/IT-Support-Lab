# INC-002: DNS Resolution Failure Affecting Logins and Web Access

> **Simulated Incident** — IT Support Lab Environment

## Summary

A scheduled Windows Update on the primary domain controller (which also serves as the primary DNS server) caused an unexpectedly long reboot. During the downtime, 50+ users lost the ability to resolve internal DNS names, resulting in failed domain logins, inaccessible internal websites, and broken network drive mappings. Most client machines had no secondary DNS server configured, leaving them completely dependent on the single DNS server.

## Severity

**SEV-A** — Critical impact  
- **Response window:** 1 hour  
- **Coverage:** 24/7  
- **Justification:** Widespread authentication and resource access failure affecting the majority of the organization. Users unable to perform any domain-authenticated work.

## Impact

| Metric | Detail |
|---|---|
| **Users affected** | 50+ across all departments |
| **Duration** | ~1.5 hours from first report to full resolution |
| **Business impact** | Domain logins failing — users could not authenticate to workstations (unless cached credentials were available). Internal web applications (intranet, ticketing system, HR portal) unreachable. File shares inaccessible by hostname. Customer-facing operations in Sales unaffected (external DNS unrelated) but internal workflow halted. |

## Timeline

| Timestamp (UTC) | Event |
|---|---|
| 2026-01-20 02:00 | Scheduled Windows Update maintenance window begins on DC01 (primary domain controller and DNS server). Admin initiates patching remotely. |
| 2026-01-20 02:15 | DC01 begins reboot to apply patches. Expected downtime: 10–15 minutes. |
| 2026-01-20 02:45 | DC01 reboot takes longer than expected — stuck on "Configuring Windows Updates — 35%" for 20+ minutes. |
| 2026-01-20 06:30 | First shift users begin logging in. Users with cached credentials log in successfully but cannot access network resources. Users without cached credentials cannot log in at all. |
| 2026-01-20 06:40 | Helpdesk receives first call — user reports "cannot connect to network drives." |
| 2026-01-20 06:50 | Five more reports come in rapidly. Helpdesk identifies a pattern: `nslookup` fails on all affected machines. DNS server 10.0.0.10 (DC01) is unreachable. |
| 2026-01-20 06:55 | Helpdesk escalates to Tier 2 as SEV-A. Tier 2 confirms DC01 is still mid-reboot, now at "Configuring Windows Updates — 92%." |
| 2026-01-20 07:10 | DC01 completes reboot. DNS service starts automatically. `nslookup` from admin workstation resolves successfully against DC01. |
| 2026-01-20 07:15 | Tier 2 runs `ipconfig /flushdns` remotely on a sample of affected machines. Users confirm they can now access resources. |
| 2026-01-20 07:25 | DHCP scope options updated to include secondary DNS server (DC02 at 10.0.0.11). Clients will receive the updated DNS settings at next DHCP renewal. |
| 2026-01-20 07:30 | Broadcast `ipconfig /flushdns` and `ipconfig /renew` pushed to all workstations via remote PowerShell to expedite DNS config update. |
| 2026-01-20 07:45 | All users confirmed operational. Monitoring shows DNS resolution is healthy. |
| 2026-01-20 08:00 | Incident declared resolved. |

## Detection

- **Method:** User-reported — helpdesk received calls about login failures and inaccessible network resources at the start of the business day.
- **Gap identified:** No DNS health monitoring or alerting was in place. The overnight reboot delay went unnoticed for over 4 hours because no one was actively monitoring during the maintenance window.

## Triage

1. Helpdesk ran `nslookup corp.lab.local` on an affected workstation — query timed out.
2. Ran `ping 10.0.0.10` (DC01) — destination unreachable.
3. Checked DHCP-assigned DNS settings on client: only 10.0.0.10 was configured as DNS server — no secondary.
4. Attempted to RDP to DC01 — connection refused. Accessed DC01 via Hyper-V console — observed Windows Update in progress.
5. Confirmed DC02 (10.0.0.11) was online and running DNS service, but clients were not configured to use it.

## Root Cause

Three factors combined to produce the outage:

1. **Extended reboot duration:** DC01 took approximately 4.5 hours to complete its post-update reboot (from 02:15 to 07:10). A large cumulative update required extended configuration time during restart.
2. **Single point of failure for DNS:** DC01 was the only DNS server configured in the DHCP scope options distributed to clients. When DC01 went offline, clients had no fallback DNS.
3. **No monitoring or alerting:** No automated health checks were monitoring DNS availability. The extended downtime during the overnight window was not detected until users arrived in the morning.

## Fix

1. **Verified DNS service on DC01:** Once DC01 completed its reboot, confirmed that the DNS Server service was running and responding to queries.
2. **Flushed DNS cache on clients:** Ran `ipconfig /flushdns` remotely on affected workstations to clear stale negative cache entries.
3. **Updated DHCP scope options:** Added DC02 (10.0.0.11) as secondary DNS and added 8.8.8.8 as a tertiary fallback in DHCP scope options for all subnets.
4. **Forced DHCP renewal:** Ran `ipconfig /renew` on client machines via remote PowerShell to pull updated DNS settings immediately rather than waiting for lease renewal.
5. **Tested resolution:** Verified `nslookup` succeeded against both DC01 and DC02 from multiple client machines.

## Validation

- Ran `nslookup corp.lab.local` from 10 sample workstations across different subnets — all resolved successfully.
- Verified DHCP leases on sample clients showed both primary (10.0.0.10) and secondary (10.0.0.11) DNS servers.
- Simulated DC01 DNS service stop on a test machine configured with new DHCP settings — confirmed failover to DC02 worked within seconds.
- Monitored helpdesk queue for 2 hours after resolution — no further DNS-related reports.

## Preventive Actions

| Action | Owner | Status |
|---|---|---|
| Configure secondary DNS (DC02) and tertiary DNS (8.8.8.8) in all DHCP scope options. | IT Admin | Completed |
| Schedule domain controller patches during designated maintenance windows (Saturday 02:00–06:00) to avoid overlap with business hours. | IT Admin | Planned |
| Deploy DNS monitoring script that checks resolution every 5 minutes and sends email/SMS alert on failure. | IT Admin | Planned |
| Stagger domain controller patching — never patch all DCs in the same maintenance window. | IT Admin | Planned |
| Document DC patching runbook with pre-patch checklist (verify secondary DNS, notify on-call, set maintenance window alerts). | IT Manager | Planned |
| Test DNS failover quarterly by temporarily stopping DNS on primary DC and verifying client resolution. | IT Admin | Planned |

## Customer Communication

> **Subject: [Resolved] Network Access Issues — January 20, 2026**
>
> Hello,
>
> Some of you experienced difficulties logging in and accessing internal resources (network drives, intranet, email) early this morning. We want to let you know the issue has been fully resolved.
>
> **What happened:** During a scheduled overnight server maintenance, one of our key infrastructure servers took longer than expected to restart. This temporarily disrupted the service that helps your computer find network resources.
>
> **What we did:** We restored the affected server, updated network settings to include backup servers for redundancy, and verified that all systems are operating normally.
>
> **What you need to do:** Everything should be working normally now. If you are still having trouble accessing any network resources, please restart your computer. If problems persist after a restart, contact the helpdesk at ext. 4357 or submit a ticket.
>
> We understand how disruptive this was to your morning, and we sincerely apologize. We have already implemented changes to prevent this from happening again.
>
> Thank you for your patience,
> IT Support Team

## Related Tickets

- [TICKET-003: Unable to Access Shared Drive — lgarcia](../tickets/TICKET-003.md)
- [TICKET-004: Login Failure — kwilliams](../tickets/TICKET-004.md)
