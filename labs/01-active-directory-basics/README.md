# Lab 01: Active Directory Basics

## Objective

Set up a Windows Server environment with Active Directory Domain Services (AD DS) and DNS, establish an organizational unit (OU) hierarchy with sample users and security groups, enforce a Group Policy Object (GPO) for password complexity and account lockout, configure a shared folder with NTFS and share-level permissions, and join a Windows client to the domain. This lab demonstrates core identity and access management skills used daily in enterprise IT support and systems administration.

## Tools Used

| Tool | Purpose |
|------|---------|
| Windows Server 2022 (or 2019) | Domain Controller hosting AD DS and DNS |
| Windows 10/11 Pro | Domain-joined client workstation |
| VirtualBox or VMware Workstation | Hypervisor for running both VMs |
| Active Directory Domain Services | Centralized identity and authentication |
| DNS Server | Name resolution for the domain environment |
| Group Policy Management Console (GPMC) | Creating and linking GPOs for security policy |
| Active Directory Users and Computers (ADUC) | Managing OUs, users, and groups |
| Server Manager | Installing roles and features on Windows Server |

## Diagram Description

```
┌─────────────────────────────────────────────────────┐
│              Internal Network: 192.168.1.0/24        │
│                                                      │
│   ┌───────────────────────┐   ┌──────────────────┐  │
│   │   DC-SERVER01         │   │   WS-CLIENT01    │  │
│   │   192.168.1.10        │   │   192.168.1.100  │  │
│   │                       │   │                  │  │
│   │   Roles:              │   │   OS:            │  │
│   │   - AD DS             │   │   Windows 10 Pro │  │
│   │   - DNS Server        │   │                  │  │
│   │                       │   │   DNS:           │  │
│   │   Domain:             │   │   192.168.1.10   │  │
│   │   homelab.local       │   │                  │  │
│   │                       │   │   Joined to:     │  │
│   │   OS:                 │   │   homelab.local  │  │
│   │   Windows Server 2022 │   │                  │  │
│   └───────────────────────┘   └──────────────────┘  │
│                                                      │
│   Both VMs connected via internal/host-only network  │
│   adapter in VirtualBox or VMware.                   │
└─────────────────────────────────────────────────────┘
```

The domain controller (DC-SERVER01) provides AD DS for authentication and DNS for name resolution across the `homelab.local` domain. The Windows client (WS-CLIENT01) is joined to the domain and receives Group Policy settings from the DC. Both machines reside on the same internal virtual network segment so they can communicate without external network dependencies.

## Build Steps

### Phase 1 — Provision the Domain Controller VM

1. **Create the Windows Server VM.** In VirtualBox or VMware, create a new VM with at least 2 CPU cores, 4 GB RAM, and a 60 GB virtual disk. Attach the Windows Server 2022 ISO and complete the installation, selecting **Windows Server 2022 Standard (Desktop Experience)**.

2. **Set a static IP address.** Open **Network and Sharing Center → Change adapter settings**, right-click the network adapter, select **Properties → Internet Protocol Version 4 (TCP/IPv4)**, and configure:
   - IP Address: `192.168.1.10`
   - Subnet Mask: `255.255.255.0`
   - Default Gateway: `192.168.1.1` (or leave blank for isolated lab)
   - Preferred DNS: `127.0.0.1`

3. **Rename the server.** Open **System Properties → Computer Name → Change**, set the name to `DC-SERVER01`, and restart when prompted.

### Phase 2 — Install AD DS and DNS

4. **Install the AD DS and DNS roles.** Open **Server Manager → Manage → Add Roles and Features**. Select **Role-based or feature-based installation**, choose the local server, and check both:
   - **Active Directory Domain Services**
   - **DNS Server**

   Accept the default features and complete the installation.

5. **Promote the server to a Domain Controller.** Click the notification flag in Server Manager and select **Promote this server to a domain controller**. Choose **Add a new forest** and enter the root domain name:
   - Domain: `homelab.local`
   - Forest and Domain Functional Level: Windows Server 2016 (or the highest available)
   - Set the DSRM password to a strong value (document it securely)
   - Accept the default NetBIOS name: `HOMELAB`
   - Accept default paths for the AD database, log files, and SYSVOL

   Complete the wizard and allow the server to restart. After reboot, sign in as `HOMELAB\Administrator`.

### Phase 3 — Create the OU Structure

6. **Open Active Directory Users and Computers (ADUC).** Navigate to **Server Manager → Tools → Active Directory Users and Computers**.

7. **Create Organizational Units.** Right-click the `homelab.local` domain object and select **New → Organizational Unit**. Create the following OUs:

   | OU Name | Purpose |
   |---------|---------|
   | `IT` | IT department users and computers |
   | `HR` | Human Resources department |
   | `Finance` | Finance department |
   | `Disabled_Accounts` | Staging area for terminated user accounts |

### Phase 4 — Create Users and Security Groups

8. **Create security groups.** Inside each department OU, right-click and select **New → Group**. Create these groups with **Global** scope and **Security** type:

   | Group Name | OU | Purpose |
   |------------|-----|---------|
   | `SG_IT_Staff` | IT | IT department members |
   | `SG_HR_Staff` | HR | HR department members |
   | `SG_Finance_Staff` | Finance | Finance department members |
   | `SG_AllEmployees` | homelab.local (root) | All employees across departments |

9. **Create sample user accounts.** Inside each department OU, right-click and select **New → User**. Create the following accounts:

   | Full Name | Username | OU | Group Membership |
   |-----------|----------|-----|-----------------|
   | John Smith | `jsmith` | IT | SG_IT_Staff, SG_AllEmployees |
   | Alice Johnson | `ajohnson` | IT | SG_IT_Staff, SG_AllEmployees |
   | Bob Martinez | `bmartinez` | HR | SG_HR_Staff, SG_AllEmployees |
   | Carol Davis | `cdavis` | Finance | SG_Finance_Staff, SG_AllEmployees |

   For each user:
   - Set initial password to `LabPass2024!` (or similar strong password)
   - Check **User must change password at next logon** for realistic practice
   - Ensure the account is enabled

10. **Add users to their respective groups.** Open each group's properties, go to the **Members** tab, and add the corresponding users. Also add all department groups as members of `SG_AllEmployees`.

### Phase 5 — Create and Link a Group Policy Object

11. **Open the Group Policy Management Console (GPMC).** Navigate to **Server Manager → Tools → Group Policy Management**.

12. **Create a new GPO for password and lockout policy.** Right-click the `homelab.local` domain and select **Create a GPO in this domain, and Link it here**. Name it `Password and Lockout Policy`.

13. **Edit the GPO.** Right-click the new GPO and select **Edit**. Navigate to:

    **Computer Configuration → Policies → Windows Settings → Security Settings → Account Policies**

    Configure **Password Policy**:

    | Setting | Value |
    |---------|-------|
    | Enforce password history | 12 passwords remembered |
    | Maximum password age | 90 days |
    | Minimum password age | 1 day |
    | Minimum password length | 10 characters |
    | Password must meet complexity requirements | Enabled |

    Configure **Account Lockout Policy**:

    | Setting | Value |
    |---------|-------|
    | Account lockout threshold | 5 invalid logon attempts |
    | Account lockout duration | 30 minutes |
    | Reset account lockout counter after | 30 minutes |

14. **Verify the GPO is linked.** In GPMC, confirm the GPO appears linked under the `homelab.local` domain. Run `gpupdate /force` on the DC to apply immediately.

### Phase 6 — Configure a Shared Folder

15. **Create the shared folder on the DC.** Open File Explorer and create `C:\SharedData\Finance_Reports`.

16. **Configure sharing.** Right-click the `Finance_Reports` folder, select **Properties → Sharing → Advanced Sharing**:
    - Check **Share this folder**
    - Share name: `Finance_Reports`
    - Click **Permissions** and configure:

    | Principal | Permission |
    |-----------|-----------|
    | Everyone | Remove this entry |
    | SG_Finance_Staff | Change + Read |
    | SG_IT_Staff | Full Control |

17. **Configure NTFS permissions.** On the **Security** tab of the folder properties:
    - Remove **Users** group if present (to restrict inheritance)
    - Add the following explicit permissions:

    | Principal | NTFS Permission |
    |-----------|----------------|
    | SG_Finance_Staff | Modify |
    | SG_IT_Staff | Full Control |
    | SYSTEM | Full Control |
    | Administrators | Full Control |

### Phase 7 — Join the Windows Client to the Domain

18. **Configure the Windows client VM.** Create a Windows 10/11 Pro VM with at least 2 CPU cores, 4 GB RAM, and a 40 GB disk. Complete the installation with a local account.

19. **Set the client's DNS to point to the DC.** Open **Network and Sharing Center → Change adapter settings**, configure IPv4:
    - IP Address: `192.168.1.100`
    - Subnet Mask: `255.255.255.0`
    - Default Gateway: `192.168.1.1` (or leave blank)
    - Preferred DNS Server: `192.168.1.10`

20. **Test DNS resolution.** Open Command Prompt and run:
    ```
    nslookup homelab.local
    ```
    Confirm it resolves to `192.168.1.10`. If it does not, do not proceed — see the Troubleshooting section.

21. **Join the domain.** Open **System Properties → Computer Name → Change**:
    - Set computer name to `WS-CLIENT01`
    - Select **Domain** and enter `homelab.local`
    - When prompted, authenticate with `HOMELAB\Administrator`
    - Restart the computer after the "Welcome to the homelab.local domain" message

22. **Verify domain login.** At the Windows login screen on the client, select **Other user** and sign in as:
    ```
    HOMELAB\jsmith
    ```
    Use the password set in Step 9. If prompted to change the password, set a new one meeting the GPO complexity requirements.

## Validation Steps

After completing the build, verify each component is functioning:

| # | Check | Command / Method | Expected Result |
|---|-------|-----------------|-----------------|
| 1 | AD DS is running | `Get-Service NTDS` on the DC | Status: Running |
| 2 | DNS resolves the domain | `nslookup homelab.local` from the client | Returns `192.168.1.10` |
| 3 | DNS resolves the DC hostname | `nslookup DC-SERVER01.homelab.local` from the client | Returns `192.168.1.10` |
| 4 | OUs exist | `Get-ADOrganizationalUnit -Filter *` on the DC | Lists IT, HR, Finance, Disabled_Accounts |
| 5 | Users exist | `Get-ADUser -Filter * -SearchBase "OU=IT,DC=homelab,DC=local"` | Returns jsmith, ajohnson |
| 6 | Groups have members | `Get-ADGroupMember -Identity "SG_IT_Staff"` | Returns jsmith, ajohnson |
| 7 | GPO is applied | `gpresult /r` on the client (run as domain user) | Shows "Password and Lockout Policy" under Applied GPOs |
| 8 | Password policy active | `net accounts` on the DC or client | Minimum length: 10, Lockout threshold: 5 |
| 9 | Shared folder accessible | `\\DC-SERVER01\Finance_Reports` from the client as `cdavis` | Folder opens with read/write access |
| 10 | Share denied for wrong group | `\\DC-SERVER01\Finance_Reports` from the client as `bmartinez` | Access Denied (HR user, not in SG_Finance_Staff) |
| 11 | Client is domain-joined | `systeminfo` on the client | Domain: homelab.local |
| 12 | Domain user can log in | Sign in as `HOMELAB\jsmith` at client login screen | Successful desktop load with domain profile |

## Troubleshooting

### DNS Resolution Failures — Client Cannot Find the Domain

**Symptom:** `nslookup homelab.local` returns "Server: UnKnown" or times out; domain join fails with "the domain could not be contacted."

**Resolution:**
1. Confirm the client's preferred DNS server is set to `192.168.1.10` (the DC).
2. Verify the DNS Server service is running on the DC: `Get-Service DNS`.
3. Check that both VMs are on the same virtual network adapter (internal or host-only).
4. On the DC, open **DNS Manager** and verify the `homelab.local` forward lookup zone exists with an A record for `DC-SERVER01`.
5. Flush the client DNS cache: `ipconfig /flushdns`, then retry.

### Time Synchronization Issues Preventing Domain Join

**Symptom:** Domain join fails with "The time difference between the client and server is too great."

**Resolution:**
1. Kerberos authentication requires clocks to be within 5 minutes of each other.
2. On the client, manually sync the time: `w32tm /resync /force`.
3. If the client is not yet joined, temporarily set the time source to the DC:
   ```
   w32tm /config /manualpeerlist:192.168.1.10 /syncfromflags:manual /update
   net stop w32time && net start w32time
   w32tm /resync
   ```
4. Verify the time offset: `w32tm /stripchart /computer:192.168.1.10 /samples:3`.

### Login Failures After GPO Account Lockout Policy

**Symptom:** A domain user cannot log in and receives "The referenced account is currently locked out."

**Resolution:**
1. On the DC, check the account status:
   ```powershell
   Get-ADUser -Identity jsmith -Properties LockedOut, AccountLockoutTime
   ```
2. Unlock the account:
   ```powershell
   Unlock-ADAccount -Identity jsmith
   ```
3. Review the cause — the lockout policy triggers after 5 failed attempts. Check if a service or mapped drive is using stale credentials. Review the Security event log (Event ID 4740) on the DC for the source of the failed attempts.
4. The account will also auto-unlock after 30 minutes per the GPO setting.

### "Access Denied" on Shared Folders

**Symptom:** A user who should have access to `\\DC-SERVER01\Finance_Reports` receives "Access Denied."

**Resolution:**
1. Verify group membership — the user must be in `SG_Finance_Staff` or `SG_IT_Staff`:
   ```powershell
   Get-ADPrincipalGroupMembership -Identity cdavis | Select-Object Name
   ```
2. If the user was recently added to a group, they must **log off and log back in** for the new Kerberos token to include the updated group membership.
3. Check both the **Share permissions** and **NTFS permissions** — effective access is the most restrictive intersection of the two.
4. Use the **Effective Access** tab in the folder's Advanced Security settings to test a specific user's permissions.

## What I Learned

1. **DNS is the foundation of Active Directory.** Every domain join, GPO application, and authentication request depends on DNS resolution. Misconfiguring the client's DNS server is the single most common cause of AD-related failures in a lab environment.

2. **Effective file share access is the intersection of share and NTFS permissions.** Granting "Full Control" at the share level but "Read" at the NTFS level results in read-only access. Best practice is to set share permissions broadly (e.g., Authenticated Users — Change) and control granular access through NTFS permissions alone.

3. **Group Policy changes are not instant.** GPOs apply during computer startup and user logon, and then refresh approximately every 90 minutes. Running `gpupdate /force` on a machine applies changes immediately, and `gpresult /r` confirms which policies are active — both are essential troubleshooting commands.

4. **Account lockout policies protect against brute-force attacks but create support tickets.** A threshold of 5 attempts with a 30-minute lockout is a common enterprise default. IT support staff need to know how to identify the lockout source (Event ID 4740) and unlock accounts quickly to minimize user downtime.

5. **Security groups simplify permission management at scale.** Assigning permissions to groups rather than individual users makes onboarding, offboarding, and department transfers significantly easier — add or remove the user from the relevant group instead of updating permissions on every resource.

## Lessons From Mistakes

**Mistake: Setting the client DNS to 8.8.8.8 instead of the domain controller IP**

During my first attempt to join WS-CLIENT01 to the domain, I configured the client's Preferred DNS Server as `8.8.8.8` (Google's public DNS) instead of `192.168.1.10` (the domain controller). When I ran the domain join wizard and entered `homelab.local`, I immediately received the error: *"The following error occurred attempting to join the domain 'homelab.local': The specified domain either does not exist or could not be contacted."*

My first instinct was to check whether the DC was running, but `ping 192.168.1.10` succeeded — the VM was reachable. The real issue became clear when I ran:

```
nslookup homelab.local
```

The response came back from `8.8.8.8` instead of `192.168.1.10`, and there was no answer for `homelab.local` — a public DNS server has no knowledge of a private internal domain. As soon as I opened the network adapter properties on the client and corrected the Preferred DNS Server to `192.168.1.10`, the `nslookup` returned the correct IP and the domain join succeeded on the next attempt.

**Key takeaway:** Before attempting a domain join, always run `nslookup <domain>` from the client. The response must come from the domain controller's IP. If it comes from any other address, fix the DNS setting first.

## Evidence Checklist

Capture the following screenshots or command outputs to document the completed lab:

- [x] **AD DS role installed** — Server Manager dashboard showing AD DS and DNS roles with green status indicators
- [x] **Domain Controller promotion** — `Get-ADDomainController` output showing `DC-SERVER01` as a Global Catalog server for `homelab.local`
- [x] **OU structure** — ADUC tree view expanded to show IT, HR, Finance, and Disabled_Accounts OUs — [View sample output](../../docs/screenshots/lab01-ad-users-ou.txt)
- [x] **Users created** — `Get-ADUser -Filter * | Select-Object Name, SamAccountName, Enabled` output listing all four sample users — [View sample output](../../docs/screenshots/lab01-ad-users-ou.txt)
- [x] **Group membership** — `Get-ADGroupMember -Identity "SG_IT_Staff"` output showing jsmith and ajohnson
- [x] **GPO linked** — GPMC showing "Password and Lockout Policy" linked to `homelab.local` with settings visible in the Settings tab
- [x] **Password policy applied** — `net accounts` output on the DC showing minimum length 10 and lockout threshold 5
- [x] **GPO applied on client** — `gpresult /r` output from the client showing the GPO under "Applied Group Policy Objects" — [View sample output](../../docs/screenshots/lab01-gpresult-output.txt)
- [x] **Shared folder permissions** — Properties dialog for `Finance_Reports` showing both Share and NTFS permission entries
- [x] **Client DNS configured** — `ipconfig /all` output from the client showing DNS server `192.168.1.10`
- [x] **Successful domain join** — `systeminfo | findstr Domain` output from the client showing `homelab.local`
- [x] **Domain user login** — Desktop screenshot of the client logged in as `HOMELAB\jsmith` (visible via `whoami` output)
- [x] **Share access verified** — File Explorer on the client showing `\\DC-SERVER01\Finance_Reports` opened as `cdavis`
- [x] **Account lockout test** — `Get-ADUser jsmith -Properties LockedOut` showing `LockedOut: True` after five failed attempts, followed by a successful `Unlock-ADAccount` command
- [x] **DNS resolution** — `nslookup homelab.local` resolving to 192.168.1.10 — [View sample output](../../docs/screenshots/lab01-dns-nslookup.txt)
