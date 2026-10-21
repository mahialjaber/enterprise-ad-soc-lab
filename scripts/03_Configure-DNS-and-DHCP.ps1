<#
.SYNOPSIS
    Configures Active Directory Integrated DNS, Upstream Forwarders, Reverse Lookup Zones, and DHCP Scope.
.DESCRIPTION
    Ensures complete forward/reverse PTR lookups and dynamic IP provisioning for domain workstations.
#>

[CmdletBinding()]
param (
    [string]$DomainName = "mahialjaber.me",
    [string]$SubnetID = "192.168.10.0/24",
    [string]$ScopeStart = "192.168.10.50",
    [string]$ScopeEnd = "192.168.10.254",
    [string]$SubnetMask = "255.255.255.0",
    [string]$Router = "192.168.10.2",
    [string]$DNSPrimary = "192.168.10.10"
)

Write-Host "[*] 1. Ensuring DNS Feature & RSAT Management Tools are installed..." -ForegroundColor Cyan
Install-WindowsFeature -Name DNS -IncludeManagementTools

Write-Host "[*] 2. Configuring Upstream Public DNS Forwarders (Cloudflare & Google)..." -ForegroundColor Cyan
Set-DnsServerForwarder -IPAddress 1.1.1.1, 8.8.8.8 -PassThru

Write-Host "[*] 3. Adding Reverse Lookup Zone: $SubnetID (AD-Integrated)..." -ForegroundColor Cyan
Add-DnsServerPrimaryZone -NetworkId $SubnetID -ReplicationScope "Domain" -DynamicUpdate "Secure" -PassThru

Write-Host "[*] 4. Installing DHCP Server Role..." -ForegroundColor Cyan
Install-WindowsFeature -Name DHCP -IncludeManagementTools

Write-Host "[*] 5. Authorizing DHCP Server in Active Directory..." -ForegroundColor Cyan
Add-DhcpServerInDC -DnsName "dc01.$DomainName" -IPAddress $DNSPrimary

Write-Host "[*] 6. Creating Enterprise DHCP Scope..." -ForegroundColor Cyan
Add-DhcpServerv4Scope -Name "Domain Clients Scope" -StartRange $ScopeStart -EndRange $ScopeEnd -SubnetMask $SubnetMask -State Active

Write-Host "[*] 7. Setting DHCP Scope Options (Router 003, DNS 006, Domain 015)..." -ForegroundColor Cyan
Set-DhcpServerv4OptionValue -ScopeId "192.168.10.0" -OptionId 3 -Value $Router
Set-DhcpServerv4OptionValue -ScopeId "192.168.10.0" -OptionId 6 -Value $DNSPrimary
Set-DhcpServerv4OptionValue -ScopeId "192.168.10.0" -OptionId 15 -Value $DomainName

Write-Host "[+] DNS and DHCP configuration finished successfully!" -ForegroundColor Green
