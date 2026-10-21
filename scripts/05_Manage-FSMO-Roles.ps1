<#
.SYNOPSIS
    Queries and Transfers FSMO (Flexible Single Master Operations) Roles between DCs.
.DESCRIPTION
    Provides automated audit and graceful role transfer for Schema, Domain Naming,
    PDC Emulator, RID Master, and Infrastructure Master roles.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [ValidateSet("Query", "TransferToADC1", "TransferToDC01")]
    [string]$Action = "Query",

    [string]$DC01 = "DC01.mahialjaber.me",
    [string]$ADC1 = "ADC1.mahialjaber.me"
)

Import-Module ActiveDirectory

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   FSMO ROLE AUDIT & MANAGEMENT TOOL                      " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# Current state
Write-Host "[*] Querying current FSMO role holders across forest & domain..." -ForegroundColor Yellow
$forest = Get-ADForest
$domain = Get-ADDomain

[PSCustomObject]@{
    "SchemaMaster"         = $forest.SchemaMaster
    "DomainNamingMaster"   = $forest.DomainNamingMaster
    "PDCEmulator"          = $domain.PDCEmulator
    "RIDMaster"            = $domain.RIDMaster
    "InfrastructureMaster" = $domain.InfrastructureMaster
} | Format-List

if ($Action -eq "TransferToADC1") {
    Write-Host "[!] Initiating graceful role transfer of all 5 roles to $ADC1..." -ForegroundColor Yellow
    Move-ADDirectoryServerOperationMasterRole -Identity $ADC1 -OperationMasterRole SchemaMaster, DomainNamingMaster, PDCEmulator, RIDMaster, InfrastructureMaster -Confirm:$false
    Write-Host "[+] All 5 FSMO roles transferred to $ADC1 successfully." -ForegroundColor Green
}
elseif ($Action -eq "TransferToDC01") {
    Write-Host "[!] Initiating graceful role transfer of all 5 roles back to $DC01..." -ForegroundColor Yellow
    Move-ADDirectoryServerOperationMasterRole -Identity $DC01 -OperationMasterRole SchemaMaster, DomainNamingMaster, PDCEmulator, RIDMaster, InfrastructureMaster -Confirm:$false
    Write-Host "[+] All 5 FSMO roles returned to $DC01 successfully." -ForegroundColor Green
}
