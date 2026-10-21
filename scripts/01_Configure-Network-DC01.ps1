<#
.SYNOPSIS
    Pre-flight network adapter configuration script for Primary Domain Controller (DC01).
.DESCRIPTION
    Sets static IP addressing, subnet mask, default gateway, and loopback DNS on DC01.
    Subnet: 192.168.10.0/24 | Domain: mahialjaber.me
#>

[CmdletBinding()]
param (
    [string]$InterfaceAlias = "Ethernet0",
    [string]$IPAddress = "192.168.10.10",
    [byte]$PrefixLength = 24,
    [string]$Gateway = "192.168.10.2",
    [string[]]$DNSServers = @("127.0.0.1", "192.168.10.10")
)

Write-Host "[*] Configuring Static Network Interface: $InterfaceAlias" -ForegroundColor Cyan

# Remove existing IP / DHCP
Get-NetIPAddress -InterfaceAlias $InterfaceAlias -ErrorAction SilentlyContinue | Remove-NetIPAddress -Confirm:$false

# Assign Static IPv4 Address
New-NetIPAddress -InterfaceAlias $InterfaceAlias -IPAddress $IPAddress -PrefixLength $PrefixLength -DefaultGateway $Gateway

# Configure DNS Client Resolution
Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ServerAddresses $DNSServers

# Disable IPv6 for Lab Predictability
Disable-NetAdapterBinding -InterfaceAlias $InterfaceAlias -ComponentID ms_tcpip6 -ErrorAction SilentlyContinue

Write-Host "[+] Network configuration complete for DC01 ($IPAddress/24) Gateway: $Gateway" -ForegroundColor Green
ipconfig /all
