# TICKET-004: Cannot Resolve Internal Websites

| Field              | Details                                      |
|--------------------|----------------------------------------------|
| **Date**           | 2026-01-26                                   |
| **Requester**      | David Kim, Development Team                  |
| **Environment**    | Windows 11 Pro, Active Directory Domain      |
| **Tags**           | networking, dns, name-resolution             |
| **Time to Resolve**| 30 minutes                                   |
| **Related Lab**    | [Lab 02 - Networking](../labs/lab-02-networking.md) |
| **Related Incident** | [INC-002 - DNS Resolution Failure](../incidents/INC-002.md) |

---

## Problem Statement

David Kim from the Development Team reported that the internal company portal at `https://portal.corp.local` is not loading. His browser displays a **"DNS_PROBE_FINISHED_NXDOMAIN"** error, and he also cannot reach `https://wiki.corp.local` or `https://git.corp.local`. External websites such as google.com load without issues. Multiple developers on his team are experiencing the same problem.

## Questions Asked

1. **When did this start?** — Approximately 30 minutes ago, around 9:45 AM.
2. **Can you access external websites like google.com?** — Yes, external sites work fine.
3. **Which internal sites are affected?** — All of them: the portal, wiki, and internal Git server.
4. **Are other team members experiencing the same issue?** — Yes, at least three other developers in the same area have reported the same problem.
5. **Did anything change recently on your machine?** — No, nothing that he is aware of.
6. **Have you tried clearing your browser cache or using a different browser?** — Yes, tried Edge and Chrome with the same result.

## Troubleshooting Steps

1. Opened a command prompt on David's workstation and ran `nslookup portal.corp.local`.
   - Result: **"DNS request timed out. timeout was 2 seconds."** followed by **"Server: UnKnown"**.
2. Ran `ipconfig /all` to check DNS configuration:
   - **Primary DNS:** 10.0.0.10
   - **Secondary DNS:** 10.0.0.11
3. Ran `ping 10.0.0.10` (primary DNS server) — **request timed out** (server unreachable).
4. Ran `ping 10.0.0.11` (secondary DNS server) — **request timed out** (server also unreachable).
5. Ran `nslookup google.com 8.8.8.8` — resolved successfully, confirming external DNS works and the workstation has internet connectivity.
6. Contacted the Infrastructure team — confirmed that the primary DNS server `DNS01` (10.0.0.10) went down due to a service crash and the secondary `DNS02` (10.0.0.11) was also unresponsive due to a replication issue.
7. As a temporary workaround, configured David's workstation to use the backup DNS server `DNS03` (10.0.0.12) which is hosted in the disaster recovery environment.
8. Ran `ipconfig /flushdns` to clear the local DNS cache.
9. Ran `nslookup portal.corp.local 10.0.0.12` — resolved successfully to `10.0.5.20`.
10. Updated the DNS server settings in the network adapter properties:
    - **Primary DNS:** 10.0.0.12
    - **Secondary DNS:** 8.8.8.8 (as a fallback for external resolution)
11. Confirmed David could access `https://portal.corp.local`, `https://wiki.corp.local`, and `https://git.corp.local`.
12. Escalated the DNS server outage to the Infrastructure team as **INC-002** for immediate remediation.
13. Communicated the temporary workaround to the affected development team via email.

## Resolution

Both the primary DNS server (`DNS01`, 10.0.0.10) and secondary DNS server (`DNS02`, 10.0.0.11) were unreachable, preventing resolution of all internal `corp.local` domain names. External DNS resolution was unaffected because the workstations could still reach public DNS servers for external queries. As a temporary fix, affected workstations were pointed to the backup DNS server `DNS03` (10.0.0.12). The root cause — a DNS service crash on `DNS01` and a replication failure on `DNS02` — was escalated to the Infrastructure team as Incident INC-002.

## Close Notes

- Internal name resolution restored for affected users by pointing to backup DNS server `DNS03`.
- Escalated to Infrastructure team as INC-002 for root cause analysis and restoration of `DNS01` and `DNS02`.
- Temporary DNS settings will need to be reverted once the primary and secondary DNS servers are back online.
- Recommended that DHCP scopes be updated to include `DNS03` as a tertiary DNS server to provide automatic failover in the future.
- Four developers confirmed affected; all received the workaround configuration.
