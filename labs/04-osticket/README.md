# Lab 04: osTicket — Help Desk Ticketing System

## Objective

Install and configure **osTicket** on an Ubuntu 22.04 VM running a full LAMP stack with MariaDB as the database backend. Set up administrative, agent, and end-user accounts to simulate a realistic help desk environment. Configure organizational structure including departments, teams, help topics, SLA plans, and canned responses. Create and resolve tickets using the 12-ticket sample pack located in the `/tickets` folder, walking through every stage of the ticket lifecycle from submission to closure. Troubleshoot common osTicket issues including permission errors, email fetching, and PHP configuration problems.

By the end of this lab you will understand how a ticketing system routes, prioritizes, and tracks IT support requests in a production-like environment.

---

## Tools Used

| Tool | Purpose |
|------|---------|
| **Ubuntu 22.04 LTS** (VM) | Host operating system for the LAMP stack |
| **Apache2** | Web server serving the osTicket application |
| **PHP 8.1** | Server-side runtime with required extensions |
| **MariaDB** | Relational database storing tickets, users, and configuration |
| **osTicket v1.18.x** | Open-source help desk ticketing system |
| **Web browser** | Access admin panel, agent panel, and user portal |
| **SSH client** | Remote terminal access for server administration |

---

## Diagram Description

```
┌─────────────────────────────────────────────────────────┐
│                    Ubuntu 22.04 VM                       │
│              (192.168.1.20 / localhost)                  │
│                                                         │
│  ┌─────────┐   ┌─────────┐   ┌──────────────────────┐  │
│  │ Apache2 │──▶│ PHP 8.1 │──▶│      MariaDB         │  │
│  │ :80     │   │ module  │   │ DB: osticket_db       │  │
│  └────┬────┘   └─────────┘   └──────────────────────┘  │
│       │                                                  │
│       ▼                                                  │
│  ┌──────────────────────────────────────────────────┐   │
│  │              osTicket v1.18.x                     │   │
│  │                                                    │   │
│  │  /scp/admin.php  ─── Admin Panel (config)         │   │
│  │  /scp/           ─── Agent Panel (ticket work)    │   │
│  │  /               ─── User Portal (submit tickets) │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
         ▲               ▲                ▲
         │               │                │
    ┌────┴────┐   ┌──────┴─────┐   ┌─────┴──────┐
    │  Admin  │   │   Agents   │   │   Users     │
    │ Browser │   │  Browser   │   │  Browser    │
    └─────────┘   └────────────┘   └────────────┘
```

- **Admin Panel** — `http://192.168.1.20/osticket/scp/admin.php` — Full system configuration: departments, SLA plans, help topics, email settings, and agent management.
- **Agent Panel** — `http://192.168.1.20/osticket/scp/` — Ticket queue, assignment, response, and resolution workspace for help desk staff.
- **User Portal** — `http://192.168.1.20/osticket/` — End-user interface for submitting new tickets and checking ticket status.

---

## Build Steps

### Part A — Install the LAMP Stack

**1. Provision and update the Ubuntu 22.04 VM**

```bash
sudo apt update && sudo apt upgrade -y
```

Confirm the release version:

```bash
lsb_release -a
```

**2. Install Apache2**

```bash
sudo apt install apache2 -y
sudo systemctl enable apache2
sudo systemctl start apache2
```

Verify Apache is running by navigating to `http://192.168.1.20` in a browser — you should see the default Apache2 Ubuntu page.

**3. Install MariaDB**

```bash
sudo apt install mariadb-server mariadb-client -y
sudo systemctl enable mariadb
sudo systemctl start mariadb
```

**4. Secure the MariaDB installation**

```bash
sudo mysql_secure_installation
```

When prompted:
- Set a root password — choose a strong password and record it securely.
- Remove anonymous users — **Yes**
- Disallow root login remotely — **Yes**
- Remove test database — **Yes**
- Reload privilege tables — **Yes**

**5. Install PHP 8.1 with required extensions**

```bash
sudo apt install php8.1 libapache2-mod-php8.1 php8.1-mysql php8.1-gd \
  php8.1-imap php8.1-intl php8.1-apcu php8.1-mbstring php8.1-xml \
  php8.1-cli php8.1-curl php8.1-zip -y
```

Verify the PHP version:

```bash
php -v
```

Restart Apache to load the PHP module:

```bash
sudo systemctl restart apache2
```

---

### Part B — Create the osTicket Database

**6. Create the database and a dedicated database user**

```bash
sudo mysql -u root -p
```

```sql
CREATE DATABASE osticket_db DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'osticket_user'@'localhost' IDENTIFIED BY 'StrongPassword123!';
GRANT ALL PRIVILEGES ON osticket_db.* TO 'osticket_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

> **Note:** Replace `StrongPassword123!` with a unique password. Never reuse passwords across services.

---

### Part C — Download and Install osTicket

**7. Download osTicket v1.18.x**

```bash
cd /tmp
wget https://github.com/osTicket/osTicket/releases/download/v1.18.1/osTicket-v1.18.1.zip
```

> Check the [osTicket releases page](https://github.com/osTicket/osTicket/releases) for the latest v1.18.x release.

**8. Extract and deploy osTicket to the web root**

```bash
sudo mkdir -p /var/www/html/osticket
sudo unzip osTicket-v1.18.1.zip -d /var/www/html/osticket
```

The archive extracts into `upload/` and `scripts/` directories:

```bash
sudo mv /var/www/html/osticket/upload/* /var/www/html/osticket/
sudo rmdir /var/www/html/osticket/upload
```

**9. Prepare the configuration file**

```bash
cd /var/www/html/osticket/include
sudo cp ost-sampleconfig.php ost-config.php
sudo chmod 0666 ost-config.php
```

The installer needs write access during setup. We lock this down after installation.

**10. Set file ownership**

```bash
sudo chown -R www-data:www-data /var/www/html/osticket
```

**11. Configure the Apache virtual host**

Create a configuration file:

```bash
sudo nano /etc/apache2/sites-available/osticket.conf
```

Add the following:

```apache
<VirtualHost *:80>
    ServerName 192.168.1.20
    DocumentRoot /var/www/html/osticket

    <Directory /var/www/html/osticket>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/osticket_error.log
    CustomLog ${APACHE_LOG_DIR}/osticket_access.log combined
</VirtualHost>
```

Enable the site and required Apache modules:

```bash
sudo a2ensite osticket.conf
sudo a2enmod rewrite
sudo systemctl restart apache2
```

**12. Run the osTicket web installer**

Open a browser and navigate to:

```
http://192.168.1.20/osticket/setup/
```

The installer runs prerequisite checks. Resolve any warnings (missing PHP extensions, wrong permissions) before proceeding.

Fill in the installer fields:

| Field | Value |
|-------|-------|
| Helpdesk Name | IT Support Lab |
| Default Email | support@itsupportlab.local |
| Admin First Name | Lab |
| Admin Last Name | Admin |
| Admin Email | admin@itsupportlab.local |
| Admin Username | lab_admin |
| Admin Password | (choose a strong password) |
| MySQL Hostname | localhost |
| MySQL Database | osticket_db |
| MySQL Username | osticket_user |
| MySQL Password | (the password from step 6) |

Click **Install Now**. The installer creates the database tables and writes the configuration.

---

### Part D — Post-Installation Security

**13. Remove the setup directory**

```bash
sudo rm -rf /var/www/html/osticket/setup
```

**14. Lock down the configuration file**

```bash
sudo chmod 0644 /var/www/html/osticket/include/ost-config.php
```

These two steps are critical. The osTicket dashboard itself warns you until both are completed.

---

### Part E — Configure the Admin Panel

Log in to the **Admin Panel** at `http://192.168.1.20/osticket/scp/admin.php`.

#### 15. Create Departments

Navigate to **Admin Panel → Agents → Departments** and create:

| Department | Description |
|------------|-------------|
| **SysAdmins** | Server, infrastructure, and critical system issues |
| **Support** | General end-user support and desktop issues |
| **Networking** | Network connectivity, VPN, firewall, and DNS issues |

> The default "Support" department already exists — rename or repurpose it as needed.

#### 16. Create Teams

Navigate to **Admin Panel → Agents → Teams** and create:

| Team | Members | Purpose |
|------|---------|---------|
| **Level I Support** | Frontline agents | Initial triage and common issues |
| **Level II Support** | Senior agents | Escalated and complex issues |

#### 17. Create Agent Accounts

Navigate to **Admin Panel → Agents → Agents → Add New Agent**:

| Agent | Email | Department | Role | Team |
|-------|-------|------------|------|------|
| **Jane Doe** | jane@itsupportlab.local | SysAdmins | Department Manager | Level II Support |
| **John Smith** | john@itsupportlab.local | Support | All Access | Level I Support |

For each agent:
1. Set a username and password on the **Account** tab.
2. Assign the primary department and role on the **Access** tab.
3. Add team membership on the **Teams** tab.
4. Grant permissions appropriate to their role on the **Permissions** tab.

#### 18. Create User Accounts

Navigate to **Agent Panel → Users → Add User**:

| User | Email |
|------|-------|
| **Karen User** | karen@itsupportlab.local |
| **Ken User** | ken@itsupportlab.local |

These accounts represent end users who submit tickets through the user portal.

#### 19. Configure Help Topics

Navigate to **Admin Panel → Manage → Help Topics** and create:

| Help Topic | Priority | Department | SLA Plan |
|------------|----------|------------|----------|
| **Business Critical Outage** | Emergency | SysAdmins | SEV-A |
| **Personal Computer Issues** | Normal | Support | SEV-C |
| **Equipment Request** | Low | Support | SEV-C |
| **Password Reset** | Normal | Support | SEV-B |
| **General Inquiry** | Low | Support | SEV-C |

#### 20. Configure SLA Plans

Navigate to **Admin Panel → Manage → SLA** and create:

| SLA Plan | Grace Period | Schedule | Use Case |
|----------|-------------|----------|----------|
| **SEV-A** | 1 hour | 24/7 | Critical outages — entire mobile banking infrastructure down, revenue-impacting systems |
| **SEV-B** | 4 hours | 24/7 | Urgent issues — department-wide software failures, password resets for VIPs |
| **SEV-C** | 8 hours | Monday–Friday, 8 AM–5 PM (business hours) | Standard requests — equipment orders, general inquiries |

SLA timers start when a ticket is created and pause outside the defined schedule for business-hours plans.

#### 21. Create Canned Responses

Navigate to **Admin Panel → Manage → Canned Responses → Add New Response**:

**Response 1 — Password Reset Instructions**

> Subject: Password Reset — Next Steps
>
> Hello,
>
> To reset your password, please follow these steps:
> 1. Navigate to https://password.itsupportlab.local
> 2. Enter your username and click "Forgot Password."
> 3. Check your email for the reset link (check spam/junk if not found within 5 minutes).
> 4. Create a new password that meets our complexity requirements (12+ characters, uppercase, lowercase, number, special character).
>
> If you continue to experience issues, reply to this ticket and we will assist further.

**Response 2 — Ticket Received Acknowledgment**

> Subject: We've Received Your Request
>
> Hello,
>
> Thank you for contacting IT Support. Your ticket has been received and assigned to a technician. You can expect an initial response within the timeframe defined by our SLA for this issue type.
>
> You can check your ticket status at any time by visiting our support portal.

**Response 3 — Escalation Notice**

> Subject: Your Ticket Has Been Escalated
>
> Hello,
>
> Your ticket has been escalated to our Level II Support team for further investigation. A senior technician will review your issue and follow up with you shortly.
>
> We appreciate your patience.

**Response 4 — Resolution Confirmation**

> Subject: Issue Resolved — Please Confirm
>
> Hello,
>
> We believe the issue described in your ticket has been resolved. Could you please confirm that everything is working as expected?
>
> If the problem persists, reply to this ticket within 48 hours and we will reopen it. Otherwise, this ticket will be automatically closed.

---

### Part F — Ticket Workflow (12-Ticket Sample Pack)

Reference the sample tickets in the [`/tickets`](../../tickets/) folder. Each ticket file describes a scenario with user details, help topic, priority, and resolution steps.

#### General Workflow for Each Ticket

**Step 1 — Submit the ticket (User Portal)**

1. Open the user portal at `http://192.168.1.20/osticket/`.
2. Click **Open a New Ticket**.
3. Enter the user's email (e.g., `karen@itsupportlab.local`).
4. Select the appropriate **Help Topic**.
5. Fill in the subject and description from the sample ticket.
6. Click **Create Ticket**.

**Step 2 — Triage the ticket (Agent Panel)**

1. Log in as an agent (e.g., Jane Doe or John Smith).
2. Open the ticket from the queue.
3. Verify or set the correct **Priority**, **SLA Plan**, and **Department**.
4. Assign the ticket to the appropriate agent or team.
5. Post an internal note documenting the triage decision.

**Step 3 — Work the ticket**

1. The assigned agent investigates the issue.
2. Use **canned responses** where appropriate (e.g., password reset instructions).
3. Post replies to the user with updates and questions.
4. Update the ticket status as work progresses (Open → In Progress).
5. If the issue requires escalation, reassign to Level II Support and change the SLA if needed.

**Step 4 — Resolve and close the ticket**

1. Post a final reply describing the resolution.
2. Change the ticket status to **Resolved**.
3. The user confirms the fix (or the ticket auto-closes after the grace period).
4. Status moves to **Closed**.

#### Ticket Lifecycle Summary

```
User submits ticket
        │
        ▼
   ┌─────────┐
   │  Open    │ ◄── Ticket created, awaiting triage
   └────┬────┘
        │  Agent picks up / assigns
        ▼
   ┌──────────┐
   │ Assigned  │ ◄── Assigned to agent or team
   └────┬─────┘
        │  Agent begins work
        ▼
  ┌────────────┐
  │ In Progress │ ◄── Agent investigating / responding
  └─────┬──────┘
        │  Issue fixed
        ▼
   ┌──────────┐
   │ Resolved  │ ◄── Agent posts resolution
   └────┬─────┘
        │  User confirms or grace period expires
        ▼
   ┌─────────┐
   │ Closed   │ ◄── Ticket complete
   └─────────┘
```

Work through all 12 sample tickets, varying assignments between agents, departments, and SLA levels to practice different scenarios.

---

### Part G — Troubleshooting Practice

#### Agent can't see tickets

**Symptom:** An agent logs in but sees an empty ticket queue.

**Cause:** The agent's department or permission settings don't match the tickets in the queue.

**Fix:**
1. Go to **Admin Panel → Agents → Agents**.
2. Select the agent and check the **Access** tab.
3. Verify the agent has access to the correct department(s).
4. On the **Permissions** tab, confirm the agent has "View" and "Reply" permissions for the relevant ticket scopes.
5. Check if the tickets are assigned to a different team — add the agent to that team if needed.

#### Cron job for email fetching

osTicket uses a cron job to fetch emails from configured mailboxes and convert them to tickets. In a lab environment, set up the cron job safely without exposing real credentials:

```bash
# Run manually to test
sudo -u www-data php /var/www/html/osticket/api/cron.php
```

To automate (runs every 5 minutes):

```bash
sudo crontab -u www-data -e
```

Add the following line:

```
*/5 * * * * php /var/www/html/osticket/api/cron.php
```

> **Lab safety note:** In a lab environment you do not need to connect a real email account. The cron job also handles other background tasks like SLA escalation and overdue ticket alerts, so it is worth enabling even without email fetching.

#### Email fetch demo (safe configuration)

To demonstrate email piping without using real credentials:

1. Navigate to **Admin Panel → Emails → Emails → Add New Email**.
2. Enter a fictional address like `support@itsupportlab.local`.
3. Skip the IMAP/POP3 configuration (leave mail fetching disabled).
4. Tickets can still be created manually through the user portal — email fetching is optional for lab purposes.

If you want to test actual email fetching, use a dedicated throwaway email account on a local mail server (e.g., Postfix on the same VM) rather than a personal or corporate mailbox.

#### Attachment upload errors

**Symptom:** Users or agents receive errors when uploading attachments.

**Fix:**

1. Check PHP upload limits in `/etc/php/8.1/apache2/php.ini`:

```ini
upload_max_filesize = 16M
post_max_size = 20M
```

2. Restart Apache after changes:

```bash
sudo systemctl restart apache2
```

3. Verify the attachments directory has correct permissions:

```bash
ls -la /var/www/html/osticket/attachments/
# Should be owned by www-data:www-data with 755 permissions
sudo chown -R www-data:www-data /var/www/html/osticket/attachments/
sudo chmod 755 /var/www/html/osticket/attachments/
```

---

## Validation Steps

After completing the build, verify that osTicket is fully operational:

| # | Check | How to Verify | Expected Result |
|---|-------|---------------|-----------------|
| 1 | Admin panel accessible | Navigate to `http://192.168.1.20/osticket/scp/admin.php` | Login page loads, no security warnings about `setup/` directory or `ost-config.php` |
| 2 | Agent panel accessible | Log in as Jane Doe or John Smith | Agent dashboard shows ticket queue |
| 3 | User portal accessible | Navigate to `http://192.168.1.20/osticket/` | Ticket submission form is available |
| 4 | Create a test ticket | Submit a ticket from the user portal as Karen User | Ticket appears in the agent queue |
| 5 | Assign a ticket | As an agent, assign the test ticket to yourself | Ticket status changes to "Assigned," agent name appears |
| 6 | Reply to a ticket | Post a reply using a canned response | User receives the response (visible in ticket thread) |
| 7 | Verify SLA timer | Create a ticket with SEV-A SLA | Due date shows 1 hour from creation, timer counts down |
| 8 | Resolve a ticket | Change ticket status to "Resolved" then "Closed" | Ticket moves through lifecycle states correctly |
| 9 | Verify departments | Check that SysAdmins, Support, and Networking exist | All three departments are listed under Admin → Agents → Departments |
| 10 | Verify help topics | Check that all five help topics are configured | Topics appear in the user portal dropdown |
| 11 | Verify cron job | Run `sudo -u www-data php /var/www/html/osticket/api/cron.php` manually | No errors; overdue alerts fire if applicable |
| 12 | Check Apache error log | Run `sudo tail -20 /var/log/apache2/osticket_error.log` | No critical errors |

---

## Troubleshooting

### 500 Internal Server Error

**Check Apache error logs first:**

```bash
sudo tail -50 /var/log/apache2/osticket_error.log
```

Common causes:
- **Missing PHP extension** — Compare installed extensions (`php -m`) against osTicket requirements. Install any missing ones with `sudo apt install php8.1-<extension>` and restart Apache.
- **Broken `.htaccess`** — Ensure `mod_rewrite` is enabled (`sudo a2enmod rewrite`) and the virtual host allows `AllowOverride All`.
- **File permission issues** — The web root should be owned by `www-data:www-data`.

### Database Connection Errors

**Symptom:** "Unable to connect to the database" or blank pages after installation.

**Checks:**
1. Verify MariaDB is running: `sudo systemctl status mariadb`
2. Test the credentials manually:
   ```bash
   mysql -u osticket_user -p osticket_db
   ```
3. Confirm the database name, username, and password in `/var/www/html/osticket/include/ost-config.php` match what you created in step 6.
4. Check that the MariaDB socket exists: `ls -la /var/run/mysqld/mysqld.sock`

### Permission Denied on Attachments

```bash
# Check current ownership
ls -la /var/www/html/osticket/ | grep attachments

# Fix ownership and permissions
sudo chown -R www-data:www-data /var/www/html/osticket/attachments
sudo chmod -R 755 /var/www/html/osticket/attachments
```

Also verify that the PHP `upload_tmp_dir` is writable by `www-data`.

### PHP Version Compatibility

osTicket v1.18.x requires PHP 8.0 or 8.1. PHP 8.2+ may cause deprecation warnings or errors.

```bash
# Check active PHP version
php -v

# Check which PHP module Apache is using
apache2ctl -M | grep php
```

If you have multiple PHP versions installed, ensure Apache is using the correct one:

```bash
sudo a2dismod php8.2
sudo a2enmod php8.1
sudo systemctl restart apache2
```

### Cron Job Not Running

**Symptom:** SLA timers don't escalate, overdue alerts never fire, and email fetching (if configured) doesn't work.

**Checks:**
1. Verify the cron entry exists:
   ```bash
   sudo crontab -u www-data -l
   ```
2. Test the cron script manually:
   ```bash
   sudo -u www-data php /var/www/html/osticket/api/cron.php
   ```
3. Check for PHP errors in the output. Common issues include incorrect file paths or PHP CLI using a different `php.ini` than Apache.
4. Ensure the `www-data` user has read access to the osTicket files.

---

## What I Learned

1. **Ticketing systems are organizational infrastructure, not just software.** Configuring departments, SLA plans, and help topics forces you to think about how support requests flow through an organization — who handles what, how urgently, and by when.

2. **SLA plans create accountability.** Defining grace periods and schedules (24/7 vs. business hours) transforms vague expectations into measurable deadlines. Watching the SLA timer count down on a SEV-A ticket makes the concept of service-level agreements concrete.

3. **Role-based access controls prevent chaos at scale.** Limiting which agents see which departments and what actions they can take mirrors real enterprise environments where a desktop support tech should not be modifying firewall rules.

4. **The LAMP stack requires every layer to work together.** A single misconfigured PHP extension, a wrong file permission, or a MariaDB credential mismatch breaks the entire application. Troubleshooting osTicket means understanding Apache, PHP, and MariaDB as interconnected systems.

5. **Canned responses and templates save time without sacrificing quality.** Pre-written responses for common scenarios (password resets, escalation notices) ensure consistent communication and let agents focus on problem-solving rather than drafting repetitive emails.

---

## Evidence Checklist

Capture the following screenshots to document your lab work:

| # | Screenshot | What It Shows |
|---|-----------|---------------|
| 1 | osTicket web installer prerequisites page | All checks passed (green), PHP extensions loaded |
| 2 | osTicket installer completion page | "Congratulations" message confirming successful install |
| 3 | Admin Panel dashboard | Logged in as lab_admin, no security warnings |
| 4 | Departments list | SysAdmins, Support, and Networking departments visible |
| 5 | Teams list | Level I Support and Level II Support teams configured |
| 6 | Agents list | Jane Doe and John Smith with correct department assignments |
| 7 | Help Topics list | All five help topics with associated SLA plans |
| 8 | SLA Plans list | SEV-A (1 hr/24×7), SEV-B (4 hr/24×7), SEV-C (8 hr/business) |
| 9 | Canned Responses list | All four canned responses created |
| 10 | User portal — new ticket form | Help topic dropdown showing all configured topics |
| 11 | Ticket created by Karen User | Ticket visible in agent queue with correct help topic |
| 12 | Ticket assigned to agent | Ticket detail showing assigned agent and SLA timer |
| 13 | Agent reply using canned response | Canned response inserted into ticket reply |
| 14 | Ticket resolved and closed | Ticket status showing "Closed" with full thread history |
| 15 | SLA timer on a SEV-A ticket | Due date showing 1-hour deadline with countdown |
| 16 | Apache error log (clean) | `tail` output showing no critical errors — [View sample output](../../docs/screenshots/lab04-osticket-install-check.txt) |

- [x] All 16 evidence items above captured and available in `docs/screenshots/`
