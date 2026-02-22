# TICKET-001: Password Reset Request

| Field              | Details                                      |
|--------------------|----------------------------------------------|
| **Date**           | 2026-01-05                                   |
| **Requester**      | Sarah Johnson, HR Department                 |
| **Environment**    | Windows 10 Pro, Active Directory Domain      |
| **Tags**           | active-directory, password-reset, account-lockout |
| **Time to Resolve**| 15 minutes                                   |
| **Related Lab**    | [Lab 01 - Active Directory](../labs/01-active-directory-basics/) |
| **Related Incident** | [INC-001 - Account Lockouts After GPO Change](../incidents/INC-001-account-lockouts-gpo.md) |

---

## Problem Statement

Sarah Johnson from HR called the helpdesk reporting that she is completely locked out of her Windows domain account. She attempted to log in several times this morning and now receives the message: **"The referenced account is currently locked out and may not be logged on to."** She has an urgent payroll deadline and needs access restored immediately.

## Questions Asked

1. **When did the issue start?** — This morning around 8:15 AM when she first tried to log in.
2. **Did you recently change your password?** — Yes, she changed it Friday afternoon before leaving for the weekend.
3. **How many times did you attempt to log in?** — Approximately five or six times using what she believed was the new password.
4. **Are you connecting from your usual workstation?** — Yes, her assigned desktop on the second floor (HR-PC-012).
5. **Did anyone else try to log in to your machine?** — No, she is the only user of that workstation.
6. **Have you experienced this issue before?** — No, this is the first time.

## Troubleshooting Steps

1. Opened **Active Directory Users and Computers** on the domain controller.
2. Located the user account `sjohnson` in the `OU=HR,OU=Users,DC=corp,DC=local`.
3. Checked the **Account** tab — confirmed the account was locked out. The `Lockout Time` field showed 2026-01-05 08:22 AM.
4. Reviewed the account lockout policy via `gpresult /r` — confirmed the GPO `Corp-Security-Policy` enforces a lockout threshold of **5 invalid attempts** with a **30-minute lockout duration**.
5. Checked the **Security Event Log** on the domain controller for Event ID 4740 (Account Lockout) — confirmed five failed logon attempts originating from `HR-PC-012` between 08:15 and 08:22 AM.
6. Unlocked the account by clearing the **"Unlock account"** checkbox in AD.
7. Reset the password to a temporary value and checked **"User must change password at next logon."**
8. Had Sarah log in at her workstation with the temporary password.
9. Walked her through setting a new password that meets the domain complexity requirements (minimum 8 characters, uppercase, lowercase, number, special character).
10. Confirmed she could log in successfully and access her HR applications.

## Resolution

The account was locked out due to exceeding the five-attempt lockout threshold defined in the `Corp-Security-Policy` GPO. Sarah had changed her password on Friday but was entering the old password on Monday morning. The account was unlocked in Active Directory, the password was reset, and login was confirmed. Sarah was educated on the domain password policy and advised to use the self-service password reset portal for future lockouts.

## Close Notes

- Account unlocked and password reset completed successfully.
- Verified the lockout was caused by user error, not a credential-stuffing attack or misconfigured service account.
- Noted that the recent GPO change (see INC-001) reduced the lockout threshold from 10 to 5 attempts, which may increase the frequency of lockout tickets. Recommended updating the employee communication about the new policy.
- Sent Sarah a link to the self-service password reset enrollment page.
