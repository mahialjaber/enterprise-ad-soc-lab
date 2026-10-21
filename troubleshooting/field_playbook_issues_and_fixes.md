# Active Directory Engineering: Field Troubleshooting Playbook

This document captures real-world production engineering challenges, failures encountered during deployment, root-cause analyses, and resolution playbooks.

---

## Issue 1: Missing DNS Management MMC Snap-in (`dnsmgmt.msc`)

### Symptoms
Attempting to open DNS Manager via `Win + R` → `dnsmgmt.msc` or Server Manager Tools produces an error indicating the management snap-in is not installed or the executable cannot be located.

### Root Cause
During the role installation wizard or automated feature deployment, the remote administration management tools sub-feature (`RSAT-DNS-Server`) was omitted.

### Remediation Playbook (PowerShell Instant Hotfix)
Execute in an elevated Administrator PowerShell prompt:

```powershell
# 1. Install DNS Role along with the complete GUI MMC management tools
Install-WindowsFeature -Name DNS -IncludeManagementTools

# 2. Configure public authoritative recursive forwarders (Cloudflare & Google)
Set-DnsServerForwarder -IPAddress 8.8.8.8, 1.1.1.1

# 3. Create AD-Integrated Reverse Lookup Zone for the lab subnet
Add-DnsServerPrimaryZone -NetworkID "192.168.10.0/24" -ReplicationScope "Domain" -DynamicUpdate "Secure"
```

---

## Issue 2: Secondary Domain Controller (ADC1) Failing Domain Join / Promotion

### Symptoms
Promoting `ADC1` fails with error: *"An Active Directory domain controller for the domain 'mahialjaber.me' could not be contacted."*

### Root Cause
`ADC1` network adapter had DNS set to default gateway (`192.168.10.2`) or `127.0.0.1` before the role was installed. Client machines cannot resolve `_ldap._tcp.dc._msdcs.mahialjaber.me` SRV records through standard consumer gateways.

### Remediation Playbook
1. Before promotion, explicitly set Preferred DNS to point to the primary DC (`192.168.10.10`):
   ```powershell
   New-NetIPAddress -InterfaceAlias "Ethernet0" -IPAddress 192.168.10.40 -PrefixLength 24 -DefaultGateway 192.168.10.2
   Set-DnsClientServerAddress -InterfaceAlias "Ethernet0" -ServerAddresses 192.168.10.10
   ```
2. Flush client resolver and query DC SRV records:
   ```cmd
   ipconfig /flushdns
   nslookup -type=SRV _ldap._tcp.dc._msdcs.mahialjaber.me
   ```
3. Proceed with `Install-ADDSDomainController`.

---

## Issue 3: Inbound AD DS Replication Inconsistencies Between DC01 and ADC1

### Symptoms
Objects created in `first ou` on `DC01` do not immediately populate on `ADC1`.

### Root Cause
Replication schedule latency or RPC port blockage between domain controllers.

### Diagnostic & Resolution Sequence
```cmd
:: 1. Check replication topology and link status
repadmin /showrepl

:: 2. Check summary status across all DCs
repadmin /replsummary

:: 3. Force immediate forest-wide synchronization across all partitions (Configuration, Schema, Domain)
repadmin /syncall /AdeP

:: 4. Run deep replication diagnostic
dcdiag /test:replications
```

---

## Issue 4: FSMO Role Management via Command-Line (`ntdsutil`)

When graphical consoles are unavailable, FSMO roles must be transferred via `ntdsutil`:

```cmd
ntdsutil
roles
connections
connect to server DC01.mahialjaber.me
q
transfer schema master
transfer naming master
transfer pdc
transfer rid master
transfer infrastructure master
q
q
```
Verify role transfer:
```cmd
netdom query fsmo
```
