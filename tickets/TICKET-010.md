# TICKET-010: Cannot Log Into osTicket Portal

| Field              | Details                                      |
|--------------------|----------------------------------------------|
| **Ticket ID**      | TICKET-010                                   |
| **Date**           | 2026-02-02                                   |
| **Requester**      | Support Team Agent (Jane Doe)                |
| **Environment**    | osTicket v1.18, Ubuntu Server 22.04, Apache 2.4, PHP 8.1, MySQL 8.0 |
| **Priority**       | Medium                                       |
| **Status**         | Closed                                       |
| **Tags**           | osticket, permissions, agent-access           |
| **Time to Resolve**| 15 minutes                                   |
| **Related Lab**    | [Lab 04 - osTicket](../labs/lab-04-osticket.md) |
| **Related Incident** | N/A                                        |

---

## Problem Statement

Jane Doe, a support team agent, reported that she is unable to access the osTicket agent panel. When she navigates to the agent login page and enters her credentials, she receives an "Access Denied" error message. She confirmed her username and password are correct and that she has not changed them recently.

---

## Questions Asked

1. **When did this issue start?**
   - Started this morning. She was able to log in without issues last Friday.

2. **Are you able to access the end-user ticket portal (client side)?**
   - Yes, the client-facing portal loads fine. Only the agent panel is blocked.

3. **Have you tried resetting your password?**
   - Yes, used the "Forgot My Password" link, reset her password, and still gets "Access Denied" after logging in.

4. **Did you recently change computers or browsers?**
   - No, same laptop and same browser (Chrome) as always.

5. **Have any other agents reported the same issue?**
   - No, other agents on the team can log in normally.

6. **Were there any administrative changes made to osTicket recently?**
   - The admin mentioned reorganizing departments over the weekend to prepare for a new team structure.

---

## Troubleshooting Steps

1. **Verified the agent's credentials** by attempting a login from the admin side — confirmed the username and password were correct and the account was active (not locked or disabled).

2. **Checked the agent's account status** in the osTicket Admin Panel under **Agents > Agents**:
   - Jane Doe's account was listed and marked as "Active."
   - However, her **Department** assignment was blank — she was not assigned to any department.

3. **Reviewed recent administrative changes:**
   - The admin had reorganized departments over the weekend and created new department structures.
   - During the reorganization, Jane's original department ("General Support") was renamed and restructured.
   - Jane's agent profile lost its department assignment during the change, which caused osTicket to deny her access to the agent panel.

4. **Reassigned Jane to the correct department:**
   - Navigated to **Admin Panel > Agents > Agents > Jane Doe**.
   - Under the **Access** tab, assigned her **Primary Department** to "Technical Support" (the new department name).
   - Assigned her **Role** to "Expanded Access" to match her team's permissions.
   - Saved the changes.

5. **Tested agent login** by having Jane log in from her workstation:
   - Login was successful. She was able to access the agent panel, view her assigned tickets, and respond to a test ticket.

---

## Resolution

Jane Doe's "Access Denied" error was caused by a missing department assignment on her agent account. During a weekend department reorganization by the admin, her original department was restructured and her agent profile lost its department link. Without a department assignment, osTicket denied access to the agent panel. The issue was resolved by reassigning her to the correct department ("Technical Support") and verifying her role permissions in the admin panel.

---

## Close Notes

- Jane confirmed she can log in and access all her tickets and queues.
- Advised the osTicket administrator to verify all agent department assignments after making structural changes to departments.
- Recommended creating a checklist for department reorganizations to ensure no agents lose access.
- No other agents were affected; Jane's was the only profile that lost its assignment during the change.
