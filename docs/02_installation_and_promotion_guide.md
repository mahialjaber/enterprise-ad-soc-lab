# Active Directory Installation & Domain Controller Promotion Guide

This guide details the step-by-step procedure for deploying Windows Server 2022 and promoting it to the primary domain controller of a new forest root domain (`mahialjaber.me`).

---

## 1. Operating System Preparation

1. **Virtual Machine Provisioning:**
   * Hypervisor: VMware Workstation Pro 17
   * Guest OS: Windows Server 2022 Datacenter (Desktop Experience)
   * Resources: 4 vCPUs, 8,192 MB RAM, 60 GB NVMe Virtual Disk
   * Network Adapter: VMnet8 NAT (`192.168.10.0/24`)

2. **System Renaming & IP Configuration:**
   * Rename the host to `DC01` (avoids auto-generated NetBIOS conflicts).
   * Configure static IPv4 parameters:
     * IP Address: `192.168.10.10`
     * Subnet Mask: `255.255.255.0`
     * Gateway: `192.168.10.2`
     * Preferred DNS: `127.0.0.1`

---

## 2. Installing AD DS Role & Promoting Forest Root

### Step 1: Install AD DS Binaries
Via PowerShell:
```powershell
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
```

### Step 2: Forest Root Promotion
Execute `Install-ADDSForest`:
```powershell
Install-ADDSForest `
    -CreateDnsDelegation:$false `
    -DatabasePath "C:\Windows\NTDS" `
    -DomainMode "WinThreshold" `
    -DomainName "mahialjaber.me" `
    -DomainNetbiosName "MAHIALJABER" `
    -ForestMode "WinThreshold" `
    -InstallDns:$true `
    -LogPath "C:\Windows\NTDS" `
    -NoRebootOnCompletion:$false `
    -SysvolPath "C:\Windows\SYSVOL" `
    -SafeModeAdministratorPassword (ConvertTo-SecureString -AsPlainText -Force "YourSecurePassword") `
    -Force:$true
```

---

## 3. Post-Promotion Verification

1. Verify directory services database integrity:
   ```cmd
   dcdiag /v
   ```
2. Verify SYSVOL and NETLOGON shares:
   ```cmd
   net share
   ```
3. Test DNS resolution of the domain:
   ```cmd
   nslookup mahialjaber.me
   ```
