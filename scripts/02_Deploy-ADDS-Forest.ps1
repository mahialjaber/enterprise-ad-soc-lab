<#
.SYNOPSIS
    Automated Active Directory Forest Root Deployment Script for Windows Server 2022.
.DESCRIPTION
    Installs AD DS binaries, management tools, and promotes the server to the Forest Root Domain Controller.
#>

[CmdletBinding()]
param (
    [string]$DomainName = "mahialjaber.me",
    [string]$DomainNetbiosName = "MAHIALJABER",
    [string]$ForestMode = "WinThreshold", # Windows Server 2016 functional level
    [string]$DomainMode = "WinThreshold"
)

Write-Host "[*] Step 1: Installing AD-Domain-Services and RSAT Management Tools..." -ForegroundColor Cyan
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

Write-Host "[*] Step 2: Prompting for secure Directory Services Restore Mode (DSRM) Password..." -ForegroundColor Cyan
$DSRM_Credential = Get-Credential -UserName "Administrator" -Message "Enter the DSRM Administrator Password:"

Write-Host "[*] Step 3: Initializing Forest Root Domain: $DomainName ($DomainNetbiosName)..." -ForegroundColor Yellow

Install-ADDSForest `
    -CreateDnsDelegation:$false `
    -DatabasePath "C:\Windows\NTDS" `
    -DomainMode $DomainMode `
    -DomainName $DomainName `
    -DomainNetbiosName $DomainNetbiosName `
    -ForestMode $ForestMode `
    -InstallDns:$true `
    -LogPath "C:\Windows\NTDS" `
    -NoRebootOnCompletion:$false `
    -SysvolPath "C:\Windows\SYSVOL" `
    -SafeModeAdministratorPassword $DSRM_Credential.Password `
    -Force:$true
