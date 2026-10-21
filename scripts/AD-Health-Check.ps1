<#
.SYNOPSIS
    Active Directory Comprehensive Health and Replication Diagnostic Script.
.DESCRIPTION
    Executes automated health checks: AD inbound/outbound replication summary,
    forest-wide synchronization, DCDIAG test suites, SYSVOL/NETLOGON share status,
    and active domain controller discovery.
.EXAMPLE
    .\AD-Health-Check.ps1
#>

Write-Host "==========================================================" -ForegroundColor Green
Write-Host "   ACTIVE DIRECTORY HEALTH & REPLICATION DIAGNOSTIC       " -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green

Write-Host "`n[*] 1. Inbound/Outbound Replication Summary (repadmin /replsummary):" -ForegroundColor Cyan
repadmin /replsummary

Write-Host "`n[*] 2. Triggering Forest-Wide Immediate Synchronization (repadmin /syncall /AdeP):" -ForegroundColor Cyan
repadmin /syncall /AdeP

Write-Host "`n[*] 3. Core DC Diagnostic Tests (dcdiag):" -ForegroundColor Cyan
dcdiag /test:replications /q
dcdiag /test:dns /q

Write-Host "`n[*] 4. Validating SYSVOL and NETLOGON Shares:" -ForegroundColor Cyan
net share | Where-Object { $_ -match "SYSVOL|NETLOGON" }

Write-Host "`n[*] 5. Active Domain Controllers Discovery:" -ForegroundColor Cyan
Get-ADDomainController -Filter * | Select-Object Name, IPv4Address, Site, OperatingSystem | Format-Table -AutoSize

Write-Host "[+] AD Health Check Execution Complete." -ForegroundColor Green
