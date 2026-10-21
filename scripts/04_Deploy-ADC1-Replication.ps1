<#
.SYNOPSIS
    Automated Deployment Script for Additional Domain Controller (ADC1 / ADC01).
.DESCRIPTION
    Runs on the secondary server: sets static IP, points DNS to DC01, installs AD DS,
    and promotes the node as an Additional Domain Controller in the existing domain.
#>

[CmdletBinding()]
param (
    [string]$InterfaceAlias = "Ethernet0",
    [string]$IPAddress = "192.168.10.40",
    [string]$Gateway = "192.168.10.2",
    [string]$PrimaryDC_DNS = "192.168.10.10",
    [string]$DomainName = "mahialjaber.me"
)

Write-Host "[*] Step 1: Assigning Static Networking & Preferred DNS (pointing to DC01)..." -ForegroundColor Cyan
New-NetIPAddress -InterfaceAlias $InterfaceAlias -IPAddress $IPAddress -PrefixLength 24 -DefaultGateway $Gateway
Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ServerAddresses $PrimaryDC_DNS

Write-Host "[*] Step 2: Testing connectivity to Primary DC..." -ForegroundColor Cyan
if (!(Test-Connection -ComputerName $PrimaryDC_DNS -Count 2 -Quiet)) {
    Write-Error "Cannot reach Primary DC at $PrimaryDC_DNS. Verify VMware VMnet8 connectivity."
    return
}

Write-Host "[*] Step 3: Installing AD-Domain-Services role..." -ForegroundColor Cyan
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

Write-Host "[*] Step 4: Prompting for Domain Admin credentials..." -ForegroundColor Cyan
$DomainCred = Get-Credential -UserName "$DomainName\Administrator" -Message "Enter Domain Admin Credentials:"
$DSRM_Credential = Get-Credential -UserName "Administrator" -Message "Enter DSRM Password for ADC1:"

Write-Host "[*] Step 5: Promoting ADC1 as Replica Domain Controller..." -ForegroundColor Yellow
Install-ADDSDomainController `
    -DomainName $DomainName `
    -Credential $DomainCred `
    -InstallDns:$true `
    -SafeModeAdministratorPassword $DSRM_Credential.Password `
    -NoRebootOnCompletion:$false `
    -Force:$true
