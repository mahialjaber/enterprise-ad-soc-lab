# Enterprise Active Directory Security Auditing Baseline

To transition an operational Active Directory environment into a high-visibility security sensor for SOC monitoring, the following **Advanced Audit Policy Configurations** must be configured via Group Policy (`Default Domain Controllers Policy`):

```
Computer Configuration
└── Policies
    └── Windows Settings
        └── Security Settings
            └── Advanced Audit Policy Configuration
                └── Audit Policies
```

---

## 1. Mandatory Audit Policy Settings

| Category | Subcategory | Recommended Setting | Generated Event IDs | SOC Significance |
| :--- | :--- | :---: | :---: | :--- |
| **Account Logon** | Audit Kerberos Authentication Service | **Success & Failure** | `4768`, `4771` | Detects **AS-REP Roasting** and Kerberos password spraying. |
| **Account Logon** | Audit Kerberos Service Ticket Operations | **Success & Failure** | `4769`, `4770` | Detects **Kerberoasting** (RC4 ticket requests). |
| **Account Management** | Audit User Account Management | **Success & Failure** | `4720`, `4722`, `4724`, `4726`, `4738` | Detects rogue user creation, password resets, and account enabling. |
| **Account Management** | Audit Security Group Management | **Success & Failure** | `4728`, `4732`, `4756` | Flags unauthorized additions to `Domain Admins` or privileged groups. |
| **DS Access** | Audit Directory Service Access | **Success & Failure** | `4662` | Critical: Detects unauthorized **DCSync** replication attempts. |
| **DS Access** | Audit Directory Service Changes | **Success** | `5136`, `5137`, `5141` | Tracks attribute modifications on sensitive AD objects. |
| **Logon/Logoff** | Audit Logon | **Success & Failure** | `4624`, `4625` | Detects brute force, credential stuffing, and lateral movement. |
| **Logon/Logoff** | Audit Special Logon | **Success** | `4672` | Audits administrative privilege assignment at logon. |
| **Policy Change** | Audit Audit Policy Change | **Success & Failure** | `4719` | Detects tampering with security auditing baselines. |

---

## 2. Deploying via PowerShell (Auditpol)

Run on `DC01` in an elevated Administrator prompt:

```powershell
# Kerberos Authentication & Service Tickets
auditpol /set /subcategory:"Kerberos Authentication Service" /success:enable /failure:enable
auditpol /set /subcategory:"Kerberos Service Ticket Operations" /success:enable /failure:enable

# User & Group Management
auditpol /set /subcategory:"User Account Management" /success:enable /failure:enable
auditpol /set /subcategory:"Security Group Management" /success:enable /failure:enable

# Directory Service Object Access (DCSync Telemetry)
auditpol /set /subcategory:"Directory Service Access" /success:enable /failure:enable
auditpol /set /subcategory:"Directory Service Changes" /success:enable /failure:disable

# Logon & Privilege Assignment
auditpol /set /subcategory:"Logon" /success:enable /failure:enable
auditpol /set /subcategory:"Special Logon" /success:enable /failure:disable
```
