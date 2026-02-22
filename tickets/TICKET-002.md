# TICKET-002: Cannot Access Shared Drive

| Field              | Details                                      |
|--------------------|----------------------------------------------|
| **Date**           | 2026-01-12                                   |
| **Requester**      | Mike Chen, Finance Department                |
| **Environment**    | Windows 10 Pro, Active Directory Domain, File Server `FS01` |
| **Tags**           | active-directory, file-shares, permissions   |
| **Time to Resolve**| 20 minutes                                   |
| **Related Lab**    | [Lab 01 - Active Directory](../labs/lab-01-active-directory.md) |
| **Related Incident** | N/A                                        |

---

## Problem Statement

Mike Chen from Finance submitted a helpdesk ticket stating that he receives an **"Access denied"** error when attempting to open the shared drive `\\FS01\Finance`. He was recently transferred from the Marketing department and needs access to Finance files to begin his new role. Other Finance team members can access the share without issues.

## Questions Asked

1. **When did you start in the Finance department?** — Last Monday, January 5th.
2. **Could you access this share previously?** — No, he has never been able to access it. He was in Marketing before.
3. **What exact error message do you see?** — A Windows dialog box stating: `"\\FS01\Finance is not accessible. You might not have permission to use this network resource."`
4. **Can you access other network shares?** — Yes, he can still access `\\FS01\Marketing` from his old department.
5. **Has your manager confirmed you should have access?** — Yes, his new manager, Janet Liu (Finance Director), approved the access request.
6. **Are you connecting from a domain-joined computer?** — Yes, workstation `FIN-PC-034`.

## Troubleshooting Steps

1. Verified the share `\\FS01\Finance` was online and accessible from the helpdesk workstation — confirmed accessible.
2. Ran `whoami /groups` on Mike's workstation to list his current group memberships.
3. Confirmed that Mike's account `mchen` was **not** a member of the `Finance-Users` security group in Active Directory.
4. Checked the share permissions on `\\FS01\Finance` — the share grants **Read/Write** access to the `Finance-Users` group and **Full Control** to `Finance-Admins`.
5. Checked NTFS permissions on the `D:\Shares\Finance` folder on `FS01` — confirmed they align with the share permissions, granting `Modify` to `Finance-Users`.
6. Opened **Active Directory Users and Computers**, located `mchen` in `OU=Marketing,OU=Users,DC=corp,DC=local`.
7. Moved the user object to `OU=Finance,OU=Users,DC=corp,DC=local` per the department transfer procedure.
8. Added `mchen` to the `Finance-Users` security group.
9. Removed `mchen` from the `Marketing-Users` security group per manager approval.
10. Had Mike log off and log back on to refresh his Kerberos token and group membership.
11. Mike attempted to access `\\FS01\Finance` — access was granted successfully.
12. Verified he could open, edit, and save a test document in the share.

## Resolution

Mike's account had not been added to the `Finance-Users` Active Directory security group as part of his department transfer. The share and NTFS permissions on `\\FS01\Finance` restrict access to members of this group. After adding his account to `Finance-Users`, moving his AD object to the Finance OU, and removing his old Marketing group membership, Mike was able to access the Finance share after a fresh login.

## Close Notes

- Access to `\\FS01\Finance` confirmed working after group membership update.
- User object moved to the correct OU to ensure proper GPO application for Finance department policies.
- Old Marketing group membership removed to follow the principle of least privilege.
- Noted that the HR onboarding/transfer checklist did not include a step for IT group membership updates. Recommended adding this step to the transfer process documentation.
- No related incidents — this was an isolated access provisioning issue.
