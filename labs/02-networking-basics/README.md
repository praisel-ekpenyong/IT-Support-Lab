# Lab 02: Networking Basics

## Objective

Learn the fundamentals of IP addressing and subnetting, practice using core Windows networking commands (`ipconfig`, `ping`, `tracert`, `nslookup`), and diagnose two common help-desk scenarios: **"no internet access"** caused by an incorrect default gateway and **"DNS not resolving"** caused by a misconfigured DNS server. By the end of this lab you will be able to read and interpret an IP configuration, calculate subnet boundaries by hand, and isolate whether a connectivity problem is at the network layer or the DNS layer.

---

## Tools Used

| Tool | Purpose |
|------|---------|
| Windows 10 or 11 (VM or bare metal) | Primary workstation for all exercises |
| Command Prompt (`cmd.exe`) | Running `ipconfig`, `ping`, `tracert`, `nslookup` |
| PowerShell | Alternative shell; same commands work here |
| VirtualBox or VMware Workstation (optional) | Second VM for cross-host ping testing |
| Online subnet calculators (reference only) | Verify hand-calculated subnetting answers |

> **Note:** No additional software needs to be installed. Every command used in this lab is built into Windows.

---

## Diagram Description

```
┌─────────────────────────────────────────────────────────┐
│                    Home / Lab Network                   │
│                    192.168.1.0/24                        │
│                                                         │
│   ┌──────────────┐        ┌──────────────┐              │
│   │  Windows VM   │        │ Second VM    │              │
│   │  (Primary)    │        │ (Optional)   │              │
│   │ 192.168.1.10  │        │ 192.168.1.20 │              │
│   └──────┬───────┘        └──────┬───────┘              │
│          │                       │                      │
│          └───────────┬───────────┘                      │
│                      │                                  │
│              ┌───────┴───────┐                          │
│              │ Default GW /  │                          │
│              │ Router        │                          │
│              │ 192.168.1.1   │                          │
│              └───────┬───────┘                          │
│                      │                                  │
└──────────────────────┼──────────────────────────────────┘
                       │
                 ┌─────┴─────┐
                 │  Internet  │
                 └─────┬─────┘
                       │
              ┌────────┴────────┐
              │  DNS Server     │
              │  8.8.8.8        │
              │  (Google DNS)   │
              └─────────────────┘
```

- **Windows VM (Primary):** The machine where every command is executed. IP address `192.168.1.10`, subnet mask `255.255.255.0`, default gateway `192.168.1.1`, DNS server `8.8.8.8`.
- **Router / Default Gateway:** Forwards traffic between the local subnet and the internet.
- **DNS Server (8.8.8.8):** Resolves domain names to IP addresses.
- **Second VM (Optional):** Used only for cross-host ping tests on the same subnet.

---

## Build Steps

### Part A — Review IP Addressing Fundamentals

1. **Understand IPv4 structure.** An IPv4 address is a 32-bit number written as four decimal octets separated by dots (e.g., `192.168.1.10`). Each octet ranges from 0 to 255.

2. **Identify the key fields in a network configuration:**

   | Field | Example | Role |
   |-------|---------|------|
   | IPv4 Address | `192.168.1.10` | Unique host identifier on the subnet |
   | Subnet Mask | `255.255.255.0` | Separates network bits from host bits |
   | Default Gateway | `192.168.1.1` | Router that forwards traffic outside the subnet |
   | DNS Server | `8.8.8.8` | Translates domain names to IP addresses |

3. **Know the private address ranges** (RFC 1918). These are non-routable on the public internet:
   - `10.0.0.0/8` — 10.0.0.0 to 10.255.255.255
   - `172.16.0.0/12` — 172.16.0.0 to 172.31.255.255
   - `192.168.0.0/16` — 192.168.0.0 to 192.168.255.255

4. **Understand CIDR notation.** `/24` means the first 24 bits are the network portion, leaving 8 bits for hosts. A `/24` mask equals `255.255.255.0`.

---

### Part B — Subnetting Practice

We will subnet the network `192.168.10.0/24` into four `/26` subnets.

**Why /26?** A `/24` has 8 host bits. Borrowing 2 additional bits for subnetting gives `/26`, which creates 2² = **4 subnets**, each with 2⁶ = 64 addresses (62 usable hosts after subtracting the network and broadcast addresses).

#### Subnet math walkthrough

| Property | Value |
|----------|-------|
| Original network | `192.168.10.0/24` |
| New prefix length | `/26` |
| Subnet mask | `255.255.255.192` |
| Bits borrowed | 2 (from the 4th octet) |
| Subnets created | 2² = 4 |
| Addresses per subnet | 2⁶ = 64 |
| Usable hosts per subnet | 64 − 2 = 62 |

**Binary breakdown of the fourth octet for /26:**

```
Subnet mask fourth octet: 11000000 = 192
Block size: 256 − 192 = 64
```

#### The four /26 subnets

| Subnet | Network Address | First Usable Host | Last Usable Host | Broadcast Address |
|--------|----------------|--------------------|-------------------|-------------------|
| 1 | `192.168.10.0` | `192.168.10.1` | `192.168.10.62` | `192.168.10.63` |
| 2 | `192.168.10.64` | `192.168.10.65` | `192.168.10.126` | `192.168.10.127` |
| 3 | `192.168.10.128` | `192.168.10.129` | `192.168.10.190` | `192.168.10.191` |
| 4 | `192.168.10.192` | `192.168.10.193` | `192.168.10.254` | `192.168.10.255` |

#### Practice exercises

**Exercise 1:** Given the network `10.0.0.0/16`, subnet it into `/20` subnets. How many subnets are created and how many usable hosts per subnet?

<details>
<summary>Answer</summary>

- Bits borrowed: 20 − 16 = 4
- Number of subnets: 2⁴ = **16**
- Hosts per subnet: 2¹² = 4096 total, **4094 usable**
- First subnet: `10.0.0.0/20` (hosts `10.0.0.1` – `10.0.15.254`, broadcast `10.0.15.255`)
- Second subnet: `10.0.16.0/20` (hosts `10.0.16.1` – `10.0.31.254`, broadcast `10.0.31.255`)

</details>

**Exercise 2:** A host has IP `172.16.50.100/28`. What is the network address, broadcast address, and usable host range?

<details>
<summary>Answer</summary>

- `/28` means the subnet mask is `255.255.255.240` (block size = 16).
- `100 ÷ 16 = 6.25` → the subnet starts at `6 × 16 = 96`.
- Network address: `172.16.50.96`
- Broadcast address: `172.16.50.111` (96 + 16 − 1)
- Usable range: `172.16.50.97` – `172.16.50.110`
- Usable hosts: 2⁴ − 2 = **14**

</details>

**Exercise 3:** You need at least 30 hosts per subnet. What is the smallest prefix length that satisfies this requirement?

<details>
<summary>Answer</summary>

- 30 hosts requires at least 32 addresses (30 usable + network + broadcast).
- 2⁵ = 32, so 5 host bits are needed.
- Prefix length: 32 − 5 = **/27** (subnet mask `255.255.255.224`, 30 usable hosts).

</details>

**Exercise 4:** How many `/30` subnets can you create from `192.168.5.0/24`? What is each one typically used for?

<details>
<summary>Answer</summary>

- Bits borrowed: 30 − 24 = 6
- Number of subnets: 2⁶ = **64**
- Hosts per subnet: 2² − 2 = **2 usable hosts**
- `/30` subnets are standard for **point-to-point links** between two routers.

</details>

---

### Part C — Document Your Network Configuration

5. **Open Command Prompt as Administrator.** Press `Win + R`, type `cmd`, and press `Ctrl + Shift + Enter`.

6. **Run `ipconfig /all` and record the output:**

   ```cmd
   ipconfig /all
   ```

   Document these fields from the output:

   | Field | Your Value |
   |-------|-----------|
   | Host Name | __________ |
   | IPv4 Address | __________ |
   | Subnet Mask | __________ |
   | Default Gateway | __________ |
   | DNS Servers | __________ |
   | DHCP Enabled | __________ |
   | DHCP Server | __________ |
   | Lease Obtained | __________ |

   > **Screenshot opportunity:** Capture the full `ipconfig /all` output.

---

### Part D — Test Connectivity with `ping`

7. **Ping localhost** to verify the TCP/IP stack is functioning:

   ```cmd
   ping 127.0.0.1
   ```

   Expected result: four replies with `time<1ms`. This confirms the local TCP/IP stack is operational.

8. **Ping the default gateway** to verify LAN connectivity:

   ```cmd
   ping 192.168.1.1
   ```

   Expected result: four replies with low latency (typically `<5ms` on a local network). This confirms Layer 2 and Layer 3 connectivity to the router.

9. **Ping an external IP address** to verify internet connectivity:

   ```cmd
   ping 8.8.8.8
   ```

   Expected result: four replies. This confirms the default gateway is routing traffic to the internet. DNS is not involved in this test because we are using a raw IP address.

10. **Ping a domain name** to verify DNS resolution:

    ```cmd
    ping www.google.com
    ```

    Expected result: the domain resolves to an IP address and replies are received. This confirms DNS is working in addition to internet connectivity.

    > **Screenshot opportunity:** Capture the output of all four ping tests.

---

### Part E — Trace a Route with `tracert`

11. **Run a traceroute to an external host:**

    ```cmd
    tracert 8.8.8.8
    ```

    Observe each hop between your machine and the destination. The first hop is your default gateway. Subsequent hops are routers across the internet.

12. **Interpret the output.** Each line shows:
    - Hop number
    - Three round-trip time measurements (in milliseconds)
    - IP address or hostname of the router at that hop

    Hops that show `* * * Request timed out` indicate a router that does not respond to ICMP, not necessarily a failure.

    > **Screenshot opportunity:** Capture the full `tracert` output.

---

### Part F — Query DNS with `nslookup`

13. **Look up an A record (domain → IP):**

    ```cmd
    nslookup www.google.com
    ```

    The response shows the DNS server used and the resolved IP address(es).

14. **Look up an MX record (mail exchange):**

    ```cmd
    nslookup -type=mx google.com
    ```

    The response lists the mail servers responsible for the domain, each with a priority value. Lower priority values indicate higher preference.

15. **Query a specific DNS server:**

    ```cmd
    nslookup www.google.com 1.1.1.1
    ```

    This forces the query through Cloudflare's DNS (`1.1.1.1`) instead of your default DNS server. Useful for comparing results across DNS providers.

    > **Screenshot opportunity:** Capture all three `nslookup` outputs.

---

### Part G — Simulate "No Internet" Scenario

This exercise demonstrates what happens when the default gateway is wrong. The machine can reach local devices but cannot route traffic to the internet.

16. **Record your current default gateway** (from `ipconfig` output in Step 6).

17. **Change the default gateway to an invalid address.** Open an elevated Command Prompt and run:

    ```cmd
    netsh interface ip set address name="Ethernet" static 192.168.1.10 255.255.255.0 192.168.1.254
    ```

    This sets the gateway to `192.168.1.254`, which does not exist on the network.

18. **Test connectivity:**

    ```cmd
    ping 192.168.1.1
    ping 8.8.8.8
    ping www.google.com
    ```

    Expected results:
    - `ping 192.168.1.1` — **Succeeds** (the router is still on the local subnet).
    - `ping 8.8.8.8` — **Fails** with "Request timed out" or "Destination host unreachable" (traffic cannot be routed through the invalid gateway).
    - `ping www.google.com` — **Fails** (no route to the DNS server either).

    > **Screenshot opportunity:** Capture the failed ping results.

19. **Restore the correct gateway:**

    ```cmd
    netsh interface ip set address name="Ethernet" dhcp
    ```

    Or set it back to the correct static values:

    ```cmd
    netsh interface ip set address name="Ethernet" static 192.168.1.10 255.255.255.0 192.168.1.1
    ```

20. **Verify the fix:**

    ```cmd
    ping 8.8.8.8
    ```

    Expected result: replies resume.

---

### Part H — Simulate "DNS Not Resolving" Scenario

This exercise demonstrates what happens when the DNS server is unreachable. The machine has full internet connectivity by IP, but cannot resolve domain names.

21. **Change the DNS server to an invalid address:**

    ```cmd
    netsh interface ip set dns name="Ethernet" static 1.2.3.4
    ```

22. **Test DNS resolution:**

    ```cmd
    ping 8.8.8.8
    ping www.google.com
    nslookup www.google.com
    ```

    Expected results:
    - `ping 8.8.8.8` — **Succeeds** (raw IP does not need DNS).
    - `ping www.google.com` — **Fails** with "Ping request could not find host www.google.com" (DNS resolution fails).
    - `nslookup www.google.com` — **Fails** with "DNS request timed out" or "Server: UnKnown" (confirms the DNS server at `1.2.3.4` is not responding).

    > **Screenshot opportunity:** Capture the DNS failure outputs.

23. **Restore the correct DNS server:**

    ```cmd
    netsh interface ip set dns name="Ethernet" dhcp
    ```

    Or restore a known-good DNS server:

    ```cmd
    netsh interface ip set dns name="Ethernet" static 8.8.8.8
    ```

24. **Verify the fix:**

    ```cmd
    nslookup www.google.com
    ping www.google.com
    ```

    Expected result: DNS queries succeed and pings resolve correctly.

---

## Validation Steps

After each exercise, confirm correct operation with these checks:

| After This Exercise | Run This Command | Expected Result |
|---------------------|------------------|-----------------|
| Part C (document config) | `ipconfig /all` | All fields populated; no APIPA address (`169.254.x.x`) |
| Part D (ping tests) | `ping 8.8.8.8` | Four replies received with `<100ms` latency |
| Part D (ping domain) | `ping www.google.com` | Domain resolves to an IP; four replies received |
| Part E (traceroute) | `tracert 8.8.8.8` | First hop is default gateway; route completes |
| Part F (DNS queries) | `nslookup www.google.com` | Returns one or more IP addresses; server is identified |
| Part G (fix gateway) | `ping 8.8.8.8` | Replies resume after restoring the correct gateway |
| Part H (fix DNS) | `nslookup www.google.com` | Resolves successfully after restoring the correct DNS |
| Final state | `ipconfig /all` | IP, mask, gateway, and DNS all match original values |

---

## Troubleshooting

### "Request timed out" on ping

- **Meaning:** The ICMP echo request was sent but no reply was received within the timeout window.
- **Common causes:** Target host is down, a firewall is blocking ICMP, the default gateway is incorrect, or there is a routing issue between source and destination.
- **Diagnostic steps:**
  1. Verify your IP configuration with `ipconfig /all`.
  2. Ping the default gateway first. If that fails, the issue is local.
  3. If the gateway responds but external IPs do not, the issue is upstream.

### "Destination host unreachable"

- **Meaning:** The local machine or a router along the path has no route to the destination.
- **Common causes:** Incorrect subnet mask, wrong default gateway, or the target is on a different subnet with no route defined.
- **Diagnostic steps:**
  1. Confirm the subnet mask is correct. A wrong mask can make the host think the destination is local when it is not.
  2. Verify the default gateway is reachable with `ping <gateway-ip>`.
  3. Check the routing table with `route print` to inspect routes.

### DNS resolution failures

- **Symptoms:** `ping <IP>` works but `ping <domain>` fails. `nslookup` returns "DNS request timed out" or "Server: UnKnown."
- **Common causes:** DNS server address is wrong or unreachable, DNS service is down, or the DNS cache is stale.
- **Diagnostic steps:**
  1. Check the configured DNS server with `ipconfig /all`.
  2. Test DNS directly: `nslookup www.google.com 8.8.8.8`. If this works, your configured DNS server is the problem.
  3. Flush the DNS cache: `ipconfig /flushdns`.

### APIPA address (169.254.x.x)

- **Meaning:** The machine is configured for DHCP but failed to receive an address from a DHCP server. Windows self-assigns an address in the `169.254.0.0/16` range (Automatic Private IP Addressing).
- **Common causes:** DHCP server is down, the network cable is disconnected, or the VM network adapter is misconfigured.
- **Diagnostic steps:**
  1. Verify physical or virtual network connectivity.
  2. Attempt to renew the lease: `ipconfig /release` followed by `ipconfig /renew`.
  3. If using a VM, confirm the network adapter is set to the correct mode (NAT, Bridged, or Host-Only).

### "No internet" vs. "No network" — understanding the difference

| Condition | Ping Gateway | Ping External IP | Ping Domain Name | Root Cause |
|-----------|-------------|------------------|-------------------|------------|
| Full connectivity | ✅ | ✅ | ✅ | None — working normally |
| DNS failure only | ✅ | ✅ | ❌ | DNS server misconfigured or down |
| No internet access | ✅ | ❌ | ❌ | Default gateway incorrect or upstream outage |
| No network at all | ❌ | ❌ | ❌ | NIC disabled, cable unplugged, or wrong IP/mask |

---

## What I Learned

1. **Systematic troubleshooting follows layers.** Testing in order — localhost → gateway → external IP → domain name — isolates the failure point. If gateway pings succeed but external IPs fail, the problem is routing, not DNS.

2. **Subnetting is arithmetic, not guesswork.** Calculating subnet boundaries requires knowing the block size (256 minus the subnet mask octet value) and counting in those increments. Practicing by hand builds the intuition needed for real-world network planning.

3. **DNS problems mimic internet outages but are distinct.** When a user reports "the internet is down," the first check should be pinging an external IP address (e.g., `8.8.8.8`). If that succeeds, the problem is DNS, not connectivity, and the fix is different.

4. **`nslookup` is the definitive DNS diagnostic tool.** It shows exactly which DNS server is being queried, what the response is, and whether the query timed out. Comparing results against a known-good server (like `8.8.8.8` or `1.1.1.1`) quickly identifies whether the issue is with the configured DNS server.

5. **APIPA addresses are an immediate red flag.** Seeing `169.254.x.x` in `ipconfig` output means DHCP failed. The fix is never at the DNS layer — it is a network connectivity or DHCP server issue.

---

## Lessons From Mistakes

**Mistake: Forgetting to enable the ICMP firewall rule on the Windows VM**

During Part D of this lab, I set up both VMs with the correct static IP addresses and confirmed the VirtualBox internal network adapter names matched on both machines. However, `ping 192.168.1.10` from the client consistently returned "Request timed out" — even though the network configuration looked perfect.

My troubleshooting process:

1. **Verified IP configuration** — Ran `ipconfig /all` on both VMs and confirmed the correct IPs (`192.168.1.10` and `192.168.1.100`), matching subnet masks, and the same internal network name (`intnet`) in VirtualBox.
2. **Confirmed the VirtualBox adapter names matched** — Both VMs had Adapter 2 set to Internal Network with the name `intnet`. No typo, no mismatch.
3. **Checked Windows Firewall** — Opened **Windows Defender Firewall → Advanced Settings → Inbound Rules** and searched for "ICMP." I found that the rule named **"File and Printer Sharing (Echo Request – ICMPv4-In)"** was set to **Disabled** on the target VM.

Enabling that single firewall rule immediately resolved the issue — the next ping attempt received four replies with 0% packet loss.

**Key takeaway:** A successful `ipconfig` and matching network adapter names are necessary but not sufficient for ping tests. Windows Firewall blocks ICMP by default on some network profiles. Always check the ICMP inbound rule when pings fail but the IP configuration looks correct.

---

## Evidence Checklist

Use this checklist to confirm you have captured documentation for each exercise:

- [ ] `ipconfig /all` output showing full network configuration (Part C, Step 6) — [View sample output](../../docs/screenshots/lab02-ipconfig-all.txt)
- [ ] `ping 127.0.0.1` output — localhost test (Part D, Step 7)
- [ ] `ping <default-gateway>` output — LAN connectivity test (Part D, Step 8)
- [ ] `ping 8.8.8.8` output — internet connectivity test (Part D, Step 9)
- [ ] `ping www.google.com` output — DNS resolution test (Part D, Step 10)
- [ ] `tracert 8.8.8.8` output — full route trace (Part E, Step 11) — [View sample output](../../docs/screenshots/lab02-tracert-output.txt)
- [ ] `nslookup www.google.com` output — A record lookup (Part F, Step 13)
- [ ] `nslookup -type=mx google.com` output — MX record lookup (Part F, Step 14)
- [ ] Failed `ping 8.8.8.8` after changing gateway to invalid address (Part G, Step 18)
- [ ] Successful `ping 8.8.8.8` after restoring correct gateway (Part G, Step 20)
- [ ] Failed `nslookup` and `ping www.google.com` after setting DNS to `1.2.3.4` (Part H, Step 22)
- [ ] Successful `nslookup` and `ping` after restoring correct DNS (Part H, Step 24)
- [ ] Final `ipconfig /all` confirming all settings are restored to original values
