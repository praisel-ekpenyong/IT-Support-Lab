# Lab 00: Lab Setup

## Objective

Build the foundational virtual lab environment used by all subsequent labs in this portfolio. By the end of this setup you will have Oracle VirtualBox installed, three virtual machines provisioned (Windows Server 2022, Windows 10/11 Pro, and Ubuntu Server 22.04), and an internal network connecting them. This environment supports Active Directory, networking, Windows troubleshooting, osTicket, and PowerShell labs without requiring any external hardware beyond a single host computer.

## Tools Used

| Tool | Purpose |
|------|---------|
| Oracle VirtualBox 7.x | Type-2 hypervisor for running all lab VMs |
| Windows Server 2022 ISO | Domain controller and DNS server (Labs 01, 03, 05) |
| Windows 10/11 Pro ISO | Domain-joined client workstation (Labs 01–03, 05) |
| Ubuntu Server 22.04 LTS ISO | LAMP stack host for osTicket (Lab 04) |
| VirtualBox Extension Pack | USB 2.0/3.0 support and PXE boot (optional) |

## Hardware Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| CPU | 4 cores (Intel VT-x / AMD-V enabled) | 6+ cores |
| RAM | 12 GB | 16+ GB |
| Disk Space | 120 GB free | 200+ GB free (SSD preferred) |
| Network | Any internet connection for ISO downloads | Wired connection for stability |

> **Note:** Intel VT-x or AMD-V must be enabled in your BIOS/UEFI settings. VirtualBox will not start 64-bit VMs without hardware virtualization support.

## Diagram Description

```
┌──────────────────────────────────────────────────────────┐
│                  Host Machine (Your PC)                   │
│                  VirtualBox 7.x Installed                 │
│                                                           │
│   ┌─────────────────────────────────────────────────┐    │
│   │       Internal Network: intnet (192.168.1.0/24) │    │
│   │                                                  │    │
│   │  ┌──────────────┐  ┌──────────────┐  ┌────────┐│    │
│   │  │ DC-SERVER01  │  │ WS-CLIENT01  │  │ UBUNTU ││    │
│   │  │ Win Server   │  │ Win 10/11    │  │ 22.04  ││    │
│   │  │ 192.168.1.10 │  │ 192.168.1.100│  │ .1.200 ││    │
│   │  │              │  │              │  │        ││    │
│   │  │ Labs:        │  │ Labs:        │  │ Lab:   ││    │
│   │  │ 01,03,05     │  │ 01,02,03,05  │  │ 04     ││    │
│   │  └──────────────┘  └──────────────┘  └────────┘│    │
│   └─────────────────────────────────────────────────┘    │
│                                                           │
│   NAT adapter on each VM provides internet access when    │
│   needed (e.g., downloading osTicket, Windows updates).   │
└──────────────────────────────────────────────────────────┘
```

All three VMs share an **Internal Network** adapter (`intnet`) for isolated lab communication. Each VM also has a **NAT** adapter for internet access during setup. After initial configuration, the NAT adapter can be disabled to simulate an air-gapped environment.

## Build Steps

### Phase 1 — Install VirtualBox

1. **Download VirtualBox.** Visit [virtualbox.org/wiki/Downloads](https://www.virtualbox.org/wiki/Downloads) and download the installer for your host operating system (Windows, macOS, or Linux).

2. **Install VirtualBox.** Run the installer and accept the default options. Allow network adapter installation when prompted (required for host-only and internal networking).

3. **(Optional) Install the Extension Pack.** Download the Extension Pack from the same page and install it via **File → Tools → Extension Pack Manager → Install**. This adds USB 2.0/3.0 pass-through and PXE boot support.

4. **Verify installation.** Open VirtualBox and confirm the main manager window loads without errors. Check **Help → About VirtualBox** to confirm the version.

### Phase 2 — Download ISOs

5. **Download Windows Server 2022.** Obtain an evaluation ISO from the [Microsoft Evaluation Center](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2022). Select **ISO** as the download type. The evaluation license is valid for 180 days.

6. **Download Windows 10 or 11.** Download a Windows 10/11 ISO from the [Microsoft Software Download](https://www.microsoft.com/en-us/software-download/) page. Windows 10/11 Pro or Enterprise is required for domain join functionality.

7. **Download Ubuntu Server 22.04 LTS.** Download the ISO from [ubuntu.com/download/server](https://ubuntu.com/download/server). The LTS release provides long-term support and stability for the osTicket LAMP stack.

8. **Organize ISOs.** Store all downloaded ISOs in a dedicated folder (e.g., `C:\LabISOs` or `~/LabISOs`) for easy access when creating VMs.

### Phase 3 — Create the Windows Server VM (DC-SERVER01)

9. **Create a new VM.** In VirtualBox, click **New** and configure:

   | Setting | Value |
   |---------|-------|
   | Name | `DC-SERVER01` |
   | Type | Microsoft Windows |
   | Version | Windows 2022 (64-bit) |
   | Memory | 4096 MB |
   | Processors | 2 |
   | Hard Disk | Create a virtual hard disk now — 60 GB, VDI, dynamically allocated |

10. **Attach the ISO.** Go to **Settings → Storage**, click the empty optical drive, select **Choose a disk file**, and browse to the Windows Server 2022 ISO.

11. **Configure network adapters.** Go to **Settings → Network**:
    - **Adapter 1:** Attached to **NAT** (for internet access during setup)
    - **Adapter 2:** Attached to **Internal Network**, name: `intnet`

12. **Install Windows Server.** Start the VM and follow the installation wizard:
    - Select **Windows Server 2022 Standard (Desktop Experience)**
    - Choose **Custom: Install Windows only** and select the virtual disk
    - Set the Administrator password when prompted (document it securely)

13. **Install VirtualBox Guest Additions.** After Windows boots, select **Devices → Insert Guest Additions CD image** from the VirtualBox menu. Open File Explorer inside the VM, run `VBoxWindowsAdditions.exe`, and restart when complete. Guest Additions improve display resolution, mouse integration, and enable shared folders.

### Phase 4 — Create the Windows Client VM (WS-CLIENT01)

14. **Create a new VM.** In VirtualBox, click **New** and configure:

    | Setting | Value |
    |---------|-------|
    | Name | `WS-CLIENT01` |
    | Type | Microsoft Windows |
    | Version | Windows 10 (64-bit) or Windows 11 (64-bit) |
    | Memory | 4096 MB |
    | Processors | 2 |
    | Hard Disk | Create a virtual hard disk now — 50 GB, VDI, dynamically allocated |

15. **Attach the ISO.** Go to **Settings → Storage**, click the empty optical drive, and select the Windows 10/11 ISO.

16. **Configure network adapters.** Go to **Settings → Network**:
    - **Adapter 1:** Attached to **NAT**
    - **Adapter 2:** Attached to **Internal Network**, name: `intnet`

17. **Install Windows.** Start the VM and follow the installation wizard:
    - Select **Windows 10/11 Pro** (Pro edition is required for domain join)
    - Create a local user account during setup (do not sign in with a Microsoft account)
    - Complete the out-of-box experience (OOBE) with default settings

18. **Install VirtualBox Guest Additions.** Follow the same process as Step 13 — insert the Guest Additions CD, run the installer, and restart.

### Phase 5 — Create the Ubuntu Server VM (UBUNTU-SVR01)

19. **Create a new VM.** In VirtualBox, click **New** and configure:

    | Setting | Value |
    |---------|-------|
    | Name | `UBUNTU-SVR01` |
    | Type | Linux |
    | Version | Ubuntu (64-bit) |
    | Memory | 2048 MB |
    | Processors | 2 |
    | Hard Disk | Create a virtual hard disk now — 25 GB, VDI, dynamically allocated |

20. **Attach the ISO.** Go to **Settings → Storage**, click the empty optical drive, and select the Ubuntu Server 22.04 ISO.

21. **Configure network adapters.** Go to **Settings → Network**:
    - **Adapter 1:** Attached to **NAT** (for `apt` package downloads)
    - **Adapter 2:** Attached to **Internal Network**, name: `intnet`

22. **Install Ubuntu Server.** Start the VM and follow the installer:
    - Select your language and keyboard layout
    - Choose **Ubuntu Server** (not minimized)
    - On the network screen, accept the defaults (the NAT adapter will auto-configure via DHCP)
    - Use the entire disk for storage
    - Set your username and password (e.g., `labadmin` / `LabPass2024!`)
    - Enable **Install OpenSSH server** when prompted
    - Skip additional snaps and complete the installation
    - Reboot when prompted and remove the installation media

### Phase 6 — Configure Static IPs on the Internal Network

23. **Configure DC-SERVER01 static IP.** Inside the Windows Server VM, open **Network and Sharing Center → Change adapter settings**. Identify the adapter connected to the internal network (usually "Ethernet 2") and configure IPv4:

    | Setting | Value |
    |---------|-------|
    | IP Address | `192.168.1.10` |
    | Subnet Mask | `255.255.255.0` |
    | Default Gateway | (leave blank) |
    | Preferred DNS | `127.0.0.1` |

24. **Configure WS-CLIENT01 static IP.** Inside the Windows client VM, open the same network settings for the internal adapter and configure:

    | Setting | Value |
    |---------|-------|
    | IP Address | `192.168.1.100` |
    | Subnet Mask | `255.255.255.0` |
    | Default Gateway | (leave blank) |
    | Preferred DNS | `192.168.1.10` |

25. **Configure UBUNTU-SVR01 static IP.** Inside the Ubuntu VM, edit the Netplan configuration for the internal adapter:

    ```bash
    sudo nano /etc/netplan/00-installer-config.yaml
    ```

    Add or update the internal adapter (typically `enp0s8`):

    ```yaml
    network:
      version: 2
      ethernets:
        enp0s3:
          dhcp4: true
        enp0s8:
          dhcp4: false
          addresses:
            - 192.168.1.200/24
    ```

    Apply the configuration:

    ```bash
    sudo netplan apply
    ```

### Phase 7 — Verify Connectivity

26. **Test DC-SERVER01 → WS-CLIENT01.** On the Windows Server, open Command Prompt and run:

    ```
    ping 192.168.1.100
    ```

27. **Test WS-CLIENT01 → DC-SERVER01.** On the Windows client, run:

    ```
    ping 192.168.1.10
    ```

28. **Test UBUNTU-SVR01 → DC-SERVER01.** On the Ubuntu VM, run:

    ```bash
    ping -c 4 192.168.1.10
    ```

29. **Test internet access (NAT adapter).** On each VM, verify internet connectivity:
    - Windows: `ping 8.8.8.8`
    - Ubuntu: `ping -c 4 8.8.8.8`

    If internet access fails, ensure the NAT adapter (Adapter 1) is enabled in the VM's network settings.

## Validation Steps

After completing all build steps, verify the environment is ready:

| # | Check | Command / Method | Expected Result |
|---|-------|-----------------|-----------------|
| 1 | VirtualBox installed | Open VirtualBox Manager | Manager window loads, version 7.x displayed |
| 2 | DC-SERVER01 boots | Start the VM | Windows Server desktop loads, Administrator login succeeds |
| 3 | WS-CLIENT01 boots | Start the VM | Windows 10/11 desktop loads, local user login succeeds |
| 4 | UBUNTU-SVR01 boots | Start the VM | Ubuntu login prompt appears, SSH available |
| 5 | Internal network — Server to Client | `ping 192.168.1.100` from DC-SERVER01 | Reply from 192.168.1.100, 0% packet loss |
| 6 | Internal network — Client to Server | `ping 192.168.1.10` from WS-CLIENT01 | Reply from 192.168.1.10, 0% packet loss |
| 7 | Internal network — Ubuntu to Server | `ping -c 4 192.168.1.10` from UBUNTU-SVR01 | 4 packets received, 0% packet loss |
| 8 | Internet access — Server | `ping 8.8.8.8` from DC-SERVER01 | Reply from 8.8.8.8 |
| 9 | Internet access — Client | `ping 8.8.8.8` from WS-CLIENT01 | Reply from 8.8.8.8 |
| 10 | Internet access — Ubuntu | `ping -c 4 8.8.8.8` from UBUNTU-SVR01 | 4 packets received, 0% packet loss |
| 11 | Guest Additions — Server | Resize VirtualBox window | Display auto-resizes inside the VM |
| 12 | Guest Additions — Client | Resize VirtualBox window | Display auto-resizes inside the VM |

## Troubleshooting

### VMs Cannot Ping Each Other on the Internal Network

**Symptom:** `ping 192.168.1.x` returns "Request timed out" or "Destination host unreachable" between VMs.

**Resolution:**
1. Confirm all VMs have **Adapter 2** set to **Internal Network** with the same name (`intnet`). A typo in the network name creates separate isolated networks.
2. Verify each VM has a static IP configured on the correct adapter (the internal one, not the NAT adapter).
3. On Windows VMs, check that Windows Firewall allows ICMP: **Windows Defender Firewall → Advanced Settings → Inbound Rules → File and Printer Sharing (Echo Request – ICMPv4-In) → Enable**.
4. On Ubuntu, verify the interface is up: `ip addr show enp0s8`. If the interface has no IP, re-run `sudo netplan apply`.

### VirtualBox Fails to Start a 64-bit VM

**Symptom:** Error message "VT-x is not available" or "AMD-V is not available" when starting a VM.

**Resolution:**
1. Restart your host computer and enter BIOS/UEFI settings (usually by pressing F2, F10, Del, or Esc during boot).
2. Find the virtualization setting — often labeled **Intel Virtualization Technology**, **VT-x**, **AMD-V**, or **SVM Mode**.
3. Enable it, save, and exit BIOS.
4. If you are running Windows as your host OS, ensure Hyper-V is disabled: **Control Panel → Programs → Turn Windows features on or off → uncheck Hyper-V**.

### NAT Adapter Has No Internet Access

**Symptom:** `ping 8.8.8.8` times out on a VM even though Adapter 1 is set to NAT.

**Resolution:**
1. In VirtualBox, verify **Adapter 1** is enabled and set to **NAT** (not "NAT Network" or "Not attached").
2. On Windows, run `ipconfig /release` followed by `ipconfig /renew` on the NAT adapter.
3. On Ubuntu, restart networking: `sudo systemctl restart systemd-networkd` or `sudo netplan apply`.
4. Verify the host machine itself has internet access.

### Ubuntu Network Interface Name Mismatch

**Symptom:** Netplan configuration references `enp0s8` but the interface has a different name.

**Resolution:**
1. List all interfaces: `ip link show`.
2. Identify the second adapter (the one without a DHCP-assigned IP).
3. Update the Netplan YAML file to use the correct interface name.
4. Re-apply: `sudo netplan apply`.

## What I Learned

1. **A well-planned lab environment saves hours of troubleshooting later.** Documenting IP addresses, network names, and VM specifications upfront prevents configuration drift and makes it easy to rebuild if something breaks.

2. **Dual network adapters (NAT + Internal) provide the best of both worlds.** The NAT adapter gives each VM internet access for downloads and updates, while the Internal Network adapter creates an isolated segment for lab exercises without affecting your home network.

3. **VirtualBox snapshots are essential for lab work.** Taking a snapshot after a clean OS install and another after initial configuration creates restore points. If a lab goes wrong, you can revert in seconds instead of reinstalling from scratch.

4. **Hardware virtualization (VT-x/AMD-V) is a hard requirement.** Without it enabled in BIOS, VirtualBox cannot run 64-bit guest operating systems. This is one of the most common stumbling blocks for first-time virtualization users.

5. **Static IPs on the internal network eliminate DHCP-related inconsistencies.** In a lab environment with no DHCP server, manually assigning IPs ensures every machine is always reachable at the same address across reboots and lab sessions.

## Evidence Checklist

Capture the following screenshots or command outputs to document the completed lab setup:

- [ ] **VirtualBox Manager** — Main window showing all three VMs listed (DC-SERVER01, WS-CLIENT01, UBUNTU-SVR01)
- [ ] **DC-SERVER01 specs** — VM Settings dialog showing CPU, RAM, and disk configuration
- [ ] **WS-CLIENT01 specs** — VM Settings dialog showing CPU, RAM, and disk configuration
- [ ] **UBUNTU-SVR01 specs** — VM Settings dialog showing CPU, RAM, and disk configuration
- [ ] **Network adapter config** — Settings → Network tab showing NAT (Adapter 1) and Internal Network (Adapter 2) for any one VM
- [ ] **DC-SERVER01 static IP** — `ipconfig /all` output showing 192.168.1.10 on the internal adapter
- [ ] **WS-CLIENT01 static IP** — `ipconfig /all` output showing 192.168.1.100 on the internal adapter
- [ ] **UBUNTU-SVR01 static IP** — `ip addr show enp0s8` output showing 192.168.1.200/24
- [ ] **Ping test — Server to Client** — `ping 192.168.1.100` from DC-SERVER01 showing successful replies
- [ ] **Ping test — Client to Server** — `ping 192.168.1.10` from WS-CLIENT01 showing successful replies
- [ ] **Ping test — Ubuntu to Server** — `ping -c 4 192.168.1.10` from UBUNTU-SVR01 showing successful replies
- [ ] **Internet connectivity** — `ping 8.8.8.8` from any VM showing successful replies
