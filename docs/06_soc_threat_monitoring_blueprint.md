# SOC Threat Monitoring & Active Directory Detection Blueprint

Active Directory is the primary target for advanced persistent threats (APTs) and ransomware operators during internal network compromise. This document maps core AD operations to attacker tradecraft, MITRE ATT&CK techniques, and specific Windows Event IDs.

---

## 1. Threat Mapping & Critical Windows Event IDs

| Attack Vector | MITRE ATT&CK ID | Mechanism | Event ID | SIEM Detection Logic |
| :--- | :--- | :--- | :---: | :--- |
| **Kerberoasting** | T1558.003 | Adversary requests TGS tickets for accounts with SPNs using weak RC4 encryption (`0x17`) to crack offline. | **4769** | `EventCode=4769 TicketOptions=0x40810000 TicketEncryptionType=0x17 ServiceName!="*$" ServiceName!="krbtgt"` |
| **AS-REP Roasting** | T1558.004 | Requests Kerberos TGT without pre-authentication for accounts with `DONT_REQ_PREAUTH` enabled. | **4768** | `EventCode=4768 PreAuthType=0 TicketEncryptionType=0x17` |
| **Pass-the-Hash / Lateral Movement** | T1550.002 | Uses extracted NTLM hashes to authenticate across workstations via SMB or WinRM. | **4624** | `EventCode=4624 LogonType=3 AuthenticationPackageName="NTLM" KeyLength=0` |
| **DCSync Attack** | T1003.006 | Simulates a Domain Controller via Directory Replication Service (DRS) to pull password hashes (Mimikatz `lsadump::dcsync`). | **4662** | `EventCode=4662 ObjectType="19195a5b-6da0-11d0-afd3-00c04fd930c9" AccessMask="0x100" SubjectUserName!="*$" ` |
| **Privilege Escalation** | T1098 / T1078 | Adding unauthorized accounts to `Domain Admins`, `Enterprise Admins`, or `Schema Admins`. | **4728**, **4732**, **4756** | `EventCode IN (4728, 4732, 4756) TargetUserName="Domain Admins"` |
| **Account Creation & Manipulation** | T1136.002 | Adversary establishes persistence by creating backdoored domain accounts. | **4720**, **4738** | `EventCode=4720` or `EventCode=4738` outside standard change windows. |
| **Brute Force / Password Spray** | T1110.001 / .003 | Multiple logon failures across multiple accounts from a single host. | **4625**, **4771** | `EventCode=4625 SubStatus="0xC000006A" | stats count by SourceNetworkAddress, TargetUserName` |

---

## 2. Telemetry Architecture for Wazuh & Splunk

To bridge this Active Directory domain with our upcoming SIEM deployment:

```
[ Domain Controller (DC01) ]
  ├── Windows Security Event Log (Auditpol Baseline)
  ├── Microsoft-Windows-Sysmon/Operational (Event IDs 1, 3, 7, 8, 10, 11, 22)
  │
  ├── Wazuh Agent (Active Directory Integration) ────► [ Wazuh Manager (Rocky Linux) ]
  │                                                           └── Custom Alert Rules
  │
  └── Splunk Universal Forwarder (outputs.conf)  ────► [ Splunk Enterprise (Ubuntu) ]
                                                              └── Enterprise Security Dashboards
```

---

## 3. Top 5 AD Detection Rules (Sigma Ready)

### Rule 1: Suspicious Kerberos TGS Request (Kerberoasting)
```yaml
title: Potential Kerberoasting Ticket Request
status: production
logsource:
  product: windows
  service: security
detection:
  selection:
    EventID: 4769
    TicketOptions: '0x40810000'
    TicketEncryptionType: '0x17'
  filter:
    ServiceName|endswith: '$'
  condition: selection and not filter
level: high
```

### Rule 2: Non-DC Requesting Directory Replication (DCSync)
```yaml
title: Potential DCSync Replication Request by Non-DC Account
status: production
logsource:
  product: windows
  service: security
detection:
  selection:
    EventID: 4662
    Properties|contains:
      - '1131f6ad-9c07-11d1-f79f-00c04fc2dcd2' # DS-Replication-Get-Changes-All
      - '1131f6aa-9c07-11d1-f79f-00c04fc2dcd2' # DS-Replication-Get-Changes
  filter:
    SubjectUserName|endswith: '$'
  condition: selection and not filter
level: critical
```
