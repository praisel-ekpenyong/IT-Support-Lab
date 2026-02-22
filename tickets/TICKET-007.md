# TICKET-007: New Employee Account Setup

| Field              | Details                                      |
|--------------------|----------------------------------------------|
| **Ticket ID**      | TICKET-007                                   |
| **Date**           | 2026-01-12                                   |
| **Requester**      | HR Department (on behalf of new hire Alex Rivera) |
| **Environment**    | Windows Server 2022, Active Directory Domain Services, Microsoft Exchange |
| **Priority**       | Medium                                       |
| **Status**         | Closed                                       |
| **Tags**           | active-directory, user-provisioning, onboarding |
| **Time to Resolve**| 30 minutes                                   |
| **Related Lab**    | [Lab 01 - Active Directory](../labs/01-active-directory-basics/) |
| **Related Incident** | N/A                                        |

---

## Problem Statement

HR submitted a request to provision a new user account for Alex Rivera, who is joining the Finance team on Monday, January 19th. The new hire needs an Active Directory account, a corporate email address, and appropriate group memberships for the Finance department. HR also requested that the account be ready for first-day login with a temporary password.

---

## Questions Asked

1. **What is the new hire's full legal name and preferred display name?**
   - Full name: Alejandro "Alex" Rivera. Display name: Alex Rivera.

2. **What department and job title should be assigned?**
   - Department: Finance. Title: Financial Analyst I.

3. **Who is the new hire's direct manager?**
   - Reports to Sandra Chen, Finance Director.

4. **Are there any shared drives or specific applications the user needs access to?**
   - Needs access to the Finance shared drive (\\\\fileserver\\finance), SAP, and the budgeting portal.

5. **Should the account follow the standard naming convention (first initial + last name)?**
   - Yes, username should be arivera@contoso.local.

6. **Does the new hire need a VPN account for remote access?**
   - Not at this time; they will be fully on-site during onboarding.

---

## Troubleshooting Steps

1. **Opened Active Directory Users and Computers (ADUC)** on the domain controller and navigated to the Finance organizational unit (OU).

2. **Created the new user account** with the following details:
   - **Username:** arivera
   - **UPN:** arivera@contoso.local
   - **Display Name:** Alex Rivera
   - **Job Title:** Financial Analyst I
   - **Department:** Finance
   - **Manager:** Sandra Chen

3. **Set a temporary password** following company policy (must be changed on first login). Enabled the "User must change password at next logon" flag.

4. **Added the account to the appropriate security groups:**
   - `Finance-Users` (grants access to Finance shared drive)
   - `SAP-Users` (grants access to SAP application)
   - `BudgetPortal-Access` (grants access to the budgeting portal)
   - `AllEmployees` (standard group for all staff)

5. **Configured the email account** in Exchange Admin Center:
   - Created a mailbox linked to the AD account.
   - Primary SMTP address: alex.rivera@contoso.com.
   - Added the user to the Finance distribution list.

6. **Tested the account** by logging into a test workstation with the new credentials to confirm:
   - Successful domain login.
   - Access to the Finance shared drive.
   - Email send/receive functionality in Outlook.

7. **Documented the credentials** and securely sent the temporary password to HR via the internal secure credential-sharing tool.

---

## Resolution

Successfully created the Active Directory account for Alex Rivera in the Finance OU. The account was configured with proper group memberships for Finance department resources, including shared drives, SAP, and the budgeting portal. An Exchange mailbox was provisioned and the user was added to the Finance distribution list. Login and resource access were verified on a test workstation. Temporary credentials were securely delivered to HR for the new hire's first day.

---

## Close Notes

- Account is active and ready for use on the new hire's start date (January 19, 2026).
- HR has been notified and received the temporary credentials through the secure credential-sharing tool.
- Reminded HR to submit a separate request if VPN access is needed in the future.
- New hire orientation checklist updated to reflect IT provisioning is complete.
