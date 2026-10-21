# Group Policy Infrastructure & WMI Filtering

Group Policy Objects (GPOs) allow administrators to centrally enforce security baselines, software settings, and user environments across thousands of endpoints.

---

## 1. The LSDOU Precedence Hierarchy

Group Policies are applied in a strict, deterministic sequence. In case of conflicting settings, the policy evaluated **last** wins:

1. **Local Group Policy (`gpedit.msc`):** Evaluated first. Overwritten by all domain-level policies.
2. **Site-level GPO:** Overwrites Local GPO.
3. **Domain-level GPO:** Overwrites Site and Local GPOs.
4. **Parent Organizational Unit (OU) GPO:** Overwrites Domain, Site, and Local GPOs.
5. **Child Organizational Unit GPO:** Overwrites Parent OU (closest container to the object wins).
6. **Enforced GPO (No Override):** Absolute winner. Cannot be overridden by child GPOs, even if "Block Inheritance" is enabled on the OU.

---

## 2. Windows Management Instrumentation (WMI) Filtering

Standard GPOs apply to all objects in the targeted OU unless filtered by Security Groups or WMI queries. WMI Filters evaluate system hardware/OS properties before applying the GPO.

### Scenario A: Target Windows 11 Clients Only
Avoids deploying Windows 11-specific configurations to legacy Windows 10 endpoints:
```sql
SELECT * FROM Win32_OperatingSystem WHERE Version LIKE "10.0.22%" AND ProductType = "1"
```

### Scenario B: Target 64-Bit Workstations (Exclude Domain Controllers)
Protects Domain Controllers from desktop baseline policies:
```sql
SELECT * FROM Win32_OperatingSystem WHERE Version LIKE "10.0%" AND ProductType = "1" AND OSArchitecture = "64-bit"
```
*(Explanation: `ProductType = "1"` targets Client Workstations. `ProductType = "2"` targets Domain Controllers. `ProductType = "3"` targets Member Servers).*

---

## 3. Client Verification Commands

```cmd
:: Refresh GPO settings immediately
gpupdate /force

:: View applied and filtered-out GPOs
gpresult /r

:: Generate comprehensive HTML diagnostics report
gpresult /h C:\gpo_audit_report.html
```
