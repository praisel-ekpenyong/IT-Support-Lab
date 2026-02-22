# IT Support Lab Portfolio

## Hiring Manager Quick Start

This portfolio demonstrates hands-on IT support skills through 5 structured labs, 12 sample helpdesk tickets, 4 simulated incident responses, and 3 PowerShell automation scripts. All work was completed in virtualized lab environments. Click any link below to dive in.

| What | Count | Link |
|------|-------|------|
| Labs | 5 | [View Labs](labs/) |
| Tickets | 12 | [View Tickets](tickets/) |
| Incidents | 4 | [View Incidents](incidents/) |
| Scripts | 3 | [View Scripts](scripts/) |
| Skills Matrix | — | [View Skills](docs/skills-matrix.md) |
| Resume Bullets | 6 | [View Resume Bullets](docs/resume-bullets.md) |
| STAR Stories | 4 | [View STAR Stories](docs/star-stories.md) |

## Labs Overview

| Lab | Description | Link |
|-----|-------------|------|
| Lab 01: Active Directory Basics | AD DS, DNS, GPO, file shares, domain join | [View Lab](labs/01-active-directory-basics/) |
| Lab 02: Networking Basics | IP addressing, subnetting, diagnostics, troubleshooting | [View Lab](labs/02-networking-basics/) |
| Lab 03: Windows Troubleshooting | Event Viewer, services, SFC/DISM, printer fix, remote support | [View Lab](labs/03-windows-troubleshooting/) |
| Lab 04: osTicket | LAMP stack deployment, ticket lifecycle, SLA configuration | [View Lab](labs/04-osticket/) |
| Lab 05: PowerShell Basics | Disk space report, event log export, password reset scripts | [View Lab](labs/05-powershell-basics/) |

## Tickets & Incidents

The [tickets/](tickets/) directory contains 12 helpdesk tickets that demonstrate the full ticket lifecycle — from initial intake and triage through troubleshooting, resolution, and closure. Each ticket follows a consistent template with priority, category, and resolution notes.

The [incidents/](incidents/) directory contains 4 simulated incident responses that walk through structured incident handling including detection, containment, resolution, and post-incident review.

Tickets and incidents are cross-referenced where applicable, linking related scenarios across both directories.

## Repository Structure

```
├── README.md
├── labs/
│   ├── 01-active-directory-basics/
│   ├── 02-networking-basics/
│   ├── 03-windows-troubleshooting/
│   ├── 04-osticket/
│   └── 05-powershell-basics/
├── tickets/
├── incidents/
├── scripts/
├── templates/
└── docs/
```

## Tools & Technologies

- **Windows Server** — Active Directory, DNS, Group Policy, file shares
- **AD DS** — User/group management, OUs, domain join
- **DNS** — Forward/reverse lookup zones, record management
- **osTicket** — Helpdesk ticketing system deployment and configuration
- **PowerShell** — Scripting for automation (disk reports, event logs, password resets)
- **Ubuntu Server** — LAMP stack hosting for osTicket
- **Apache** — Web server configuration
- **MariaDB / MySQL** — Database backend for osTicket
- **VirtualBox** — Virtualized lab environments
- **Event Viewer** — Windows log analysis and troubleshooting
- **SFC / DISM** — System file integrity and image repair
- **TCP/IP** — IP addressing, subnetting, and network diagnostics

## How to Use This Portfolio

**Hiring managers:** Start with the [Quick Start](#hiring-manager-quick-start) table above, then explore individual labs or the [Skills Matrix](docs/skills-matrix.md) for a consolidated view of demonstrated competencies. Each lab includes step-by-step documentation and screenshots.

**Fellow learners:** Feel free to browse the labs for study reference. The [templates/](templates/) directory contains reusable templates for tickets, incidents, and lab write-ups.

---

> **Disclaimer:** All scenarios in this portfolio are simulated in isolated lab environments. No real production systems, employers, or certifications are represented.