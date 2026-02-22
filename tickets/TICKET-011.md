# TICKET-011: Email Notifications Not Sending from osTicket

| Field              | Details                                      |
|--------------------|----------------------------------------------|
| **Ticket ID**      | TICKET-011                                   |
| **Date**           | 2026-02-09                                   |
| **Requester**      | IT Manager                                   |
| **Environment**    | osTicket v1.18, Ubuntu Server 22.04, Apache 2.4, PHP 8.1, MySQL 8.0, SMTP via Gmail Workspace |
| **Priority**       | High                                         |
| **Status**         | Closed                                       |
| **Tags**           | osticket, email, smtp-configuration           |
| **Time to Resolve**| 45 minutes                                   |
| **Related Lab**    | [Lab 04 - osTicket](../labs/04-osticket/) |
| **Related Incident** | N/A                                        |

---

## Problem Statement

The IT Manager reported that osTicket has stopped sending email notifications for new tickets and agent replies. End users are not receiving confirmation emails when they submit tickets, and agents are not getting notified when new tickets arrive. The issue was first noticed when a user complained that they never received a response to a ticket submitted two days ago — the agent had replied, but the email never reached the user.

---

## Questions Asked

1. **When was the last time email notifications were working correctly?**
   - Email was working fine about a week ago. The IT Manager is unsure of the exact date it stopped.

2. **Were there any recent changes to the osTicket configuration or the email server?**
   - The organization recently migrated from a legacy SMTP relay to Gmail Workspace. The osTicket SMTP settings may not have been updated.

3. **Are any emails sending at all, or is it completely stopped?**
   - Completely stopped. No outbound emails from osTicket for at least several days.

4. **Are there any error messages visible in the osTicket dashboard or logs?**
   - The IT Manager is not sure. They have not checked the system logs.

5. **Is the osTicket server able to reach the internet and external SMTP servers?**
   - Yes, the server can browse the web and resolve DNS. No firewall changes have been made.

6. **What email address does osTicket use as the sender?**
   - support@contoso.com via Gmail Workspace SMTP.

---

## Troubleshooting Steps

1. **Checked the osTicket System Logs** via **Admin Panel > Dashboard > System Logs**:
   - Found repeated errors: `SMTP Error: Could not authenticate` and `SMTP connect() failed` dating back to five days ago — aligning with the SMTP migration timeline.

2. **Reviewed current SMTP configuration** under **Admin Panel > Emails > Emails > support@contoso.com > Remote Mailbox**:
   - **SMTP Server:** smtp.oldrelay.contoso.local (the legacy SMTP relay — no longer active)
   - **SMTP Port:** 25
   - **Authentication:** None
   - This confirmed the SMTP settings were still pointing to the decommissioned legacy relay.

3. **Updated SMTP settings** to point to Gmail Workspace:
   - **SMTP Server:** smtp.gmail.com
   - **SMTP Port:** 587
   - **Encryption:** TLS
   - **Authentication:** Enabled
   - **Username:** support@contoso.com
   - **Password:** (entered the Gmail Workspace app password generated for osTicket)

4. **Verified Gmail Workspace app password** was correctly generated:
   - Confirmed with the IT Manager that an app password had been created for the support@contoso.com account in Google Admin.
   - Ensured "Less secure app access" was not required since app passwords bypass that restriction.

5. **Tested SMTP connectivity from the server** via command line to confirm the server could reach Gmail's SMTP:
   ```
   openssl s_client -starttls smtp -connect smtp.gmail.com:587
   ```
   - Connection was successful, TLS handshake completed, and the SMTP banner was received.

6. **Sent a test email from osTicket** using the built-in "Send Test Email" feature under **Admin Panel > Emails > Diagnostic**:
   - First test failed — discovered the "From Name" field was blank, causing Gmail to reject the message.
   - Updated the "From Name" to "Contoso IT Support" and retested.
   - Second test email was received successfully in the inbox within seconds.

7. **Verified end-to-end notification flow:**
   - Created a test ticket from the user portal as an end user.
   - Confirmed the end user received the "Ticket Created" confirmation email.
   - Replied to the ticket as an agent and confirmed the user received the reply notification.
   - Confirmed agents received a "New Ticket Alert" email when the test ticket was created.

---

## Resolution

Email notifications had stopped because osTicket's SMTP configuration was still pointing to the decommissioned legacy SMTP relay (smtp.oldrelay.contoso.local) after the organization migrated to Gmail Workspace. The SMTP server, port, encryption, and authentication settings were updated to use Gmail Workspace's SMTP (smtp.gmail.com:587 with TLS and app password authentication). A missing "From Name" field was also corrected. Full email functionality was restored and verified with end-to-end testing.

---

## Close Notes

- All outbound email notifications from osTicket are functioning correctly.
- Verified that new ticket confirmations, agent reply notifications, and agent alerts are all sending.
- Advised the IT Manager to add SMTP configuration checks to the post-migration checklist for future infrastructure changes.
- Recommended setting up an email delivery monitoring alert so that SMTP failures are detected sooner.
- Documented the Gmail Workspace SMTP configuration for osTicket in the internal knowledge base.
