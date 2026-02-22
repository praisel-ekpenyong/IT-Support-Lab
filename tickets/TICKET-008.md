# TICKET-008: VPN Connection Dropping

| Field              | Details                                      |
|--------------------|----------------------------------------------|
| **Ticket ID**      | TICKET-008                                   |
| **Date**           | 2026-01-19                                   |
| **Requester**      | Rachel Green, Remote Worker                  |
| **Environment**    | Windows 11 Home, Cisco AnyConnect VPN Client 4.10, Home ISP: Comcast Cable |
| **Priority**       | High                                         |
| **Status**         | Closed                                       |
| **Tags**           | networking, vpn, remote-work                 |
| **Time to Resolve**| 40 minutes                                   |
| **Related Lab**    | [Lab 02 - Networking](../labs/lab-02-networking.md) |
| **Related Incident** | N/A                                        |

---

## Problem Statement

Rachel Green, a remote worker, reported that her VPN connection drops every 15–20 minutes while working from home. She is unable to maintain a stable session to access internal applications, causing disruptions to her workflow. The issue began after her ISP performed a firmware update on her home router over the weekend.

---

## Questions Asked

1. **When did this issue start happening?**
   - Started Monday morning (January 19). Worked fine all last week.

2. **Did anything change on your home network recently?**
   - ISP pushed a firmware update to the router over the weekend. No other changes.

3. **Are you connected via Wi-Fi or Ethernet?**
   - Currently on Wi-Fi. Tried Ethernet as well and the same issue occurs.

4. **Do you experience internet drops when the VPN disconnects, or does the internet stay up?**
   - Internet stays connected. Only the VPN tunnel drops.

5. **What error message do you see when the VPN disconnects?**
   - The AnyConnect client shows "VPN reconnecting..." and then eventually "Connection attempt has failed."

6. **Are other remote workers experiencing the same issue?**
   - Checked with the team; no one else has reported this problem.

7. **Have you tried connecting to a different network, such as a mobile hotspot?**
   - Yes, VPN works fine on a mobile hotspot without dropping.

---

## Troubleshooting Steps

1. **Reviewed VPN client logs** from the user's machine. Found repeated `TLS renegotiation failed` and `DTLS connection attempt timed out` errors occurring at regular intervals.

2. **Tested basic connectivity** by running continuous pings to the VPN gateway from the user's machine:
   - `ping vpn.contoso.com -t` — No packet loss observed, confirming the internet path to the VPN server was stable.

3. **Checked for MTU-related issues.** The router firmware update likely changed the default MTU setting. Ran the following test from the user's machine:
   ```
   ping vpn.contoso.com -f -l 1400
   ```
   - Packets with size 1400 were being fragmented and dropped. Reduced to 1300 and packets went through successfully.

4. **Identified the MTU mismatch.** The ISP router firmware update had reset the MTU to 1500, but the ISP's network path required a lower MTU (1380) due to PPPoE overhead. This caused VPN tunnel packets to fragment and fail.

5. **Adjusted the VPN client MTU setting** on the user's machine by modifying the AnyConnect profile:
   - Set MTU to 1300 in the AnyConnect client preferences to ensure packets fit within the network path without fragmentation.

6. **Advised the user to adjust the home router MTU** setting to 1380 to match the ISP's requirements:
   - Walked the user through logging into the router admin panel (192.168.1.1).
   - Changed WAN MTU from 1500 to 1380 under Advanced Network Settings.

7. **Tested VPN stability** after changes:
   - User connected to VPN and maintained a stable session for over 30 minutes without a single drop.
   - Confirmed access to internal file shares and applications.

---

## Resolution

The VPN disconnection issue was caused by an MTU mismatch introduced by the ISP's router firmware update. The firmware reset the router's WAN MTU to 1500, but the ISP network path required a lower MTU (1380) due to PPPoE encapsulation overhead. This caused VPN tunnel packets to exceed the maximum transmission size, resulting in fragmentation and dropped connections. The issue was resolved by adjusting the VPN client MTU to 1300 and setting the home router WAN MTU to 1380. VPN stability was confirmed with extended testing.

---

## Close Notes

- VPN connection is now stable with no drops observed during a 30-minute monitoring period.
- Advised Rachel to contact IT support if the issue recurs after any future router updates.
- Documented the MTU workaround in the internal knowledge base for future reference with remote workers on similar ISPs.
- No server-side VPN changes were required; the issue was isolated to the user's home network.
