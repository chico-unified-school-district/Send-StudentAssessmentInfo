[cmdletbinding()]
param (
 [Parameter(Mandatory = $True)]
 [Alias('DCs')]
 [string[]]$DomainControllers,
 [Parameter(Mandatory = $True)]
 [System.Management.Automation.PSCredential]$ADCredential,
 [Parameter(Mandatory = $True)]
 [string]$OrgUnit,
 [Parameter(Mandatory = $True)]
 [string]$SISServer,
 [Parameter(Mandatory = $True)]
 [string]$SISDatabase,
 [Parameter(Mandatory = $True)]
 [System.Management.Automation.PSCredential]$SISCredential,
 # [Parameter(Mandatory = $True)]
 # [int[]]$SiteCodes,
 [Parameter(Mandatory = $True)]
 [System.Management.Automation.PSCredential]$EmailCredential,
 [Parameter(Mandatory = $false)]
 [string[]]$Bcc,
 [Alias('wi')]
 [switch]$WhatIf
)


function Get-StudentTAData ($sqlParams, $baseSql) {
 process {
  Write-Host ('{0}' -f $MyInvocation.MyCommand.Name)

 }
}

function Get-ActiveAD ($ou) {
 Write-Verbose $MyInvocation.MyCommand.name
 # 'gecos' stores Aeries STU.GR (grade level)
 $adProperties = @(
  'employeeId'
  'departmentNumber'
  'department'
  'gecos'
  'givenname'
  'sn'
  'Enabled'
 )
 $allStuParams = @{
  Filter     = "homePage -like '*@*' -and employeeId -like '*'"
  SearchBase = $ou
  Properties = $adProperties
 }

 $output = Get-ADUser @allStuParams | Where-Object {
  $_.samAccountName -match "^\b[a-zA-Z][a-zA-Z]\d{5,6}\b$" -and
  # $_.employeeId -match "^\d{5,6}$" -and
  $_.title -notmatch 'test' -and
  $_.AccountExpirationDate -isnot [datetime] -and
  # $_.LastLogonDate -is [datetime] -and
  $_.Enabled -eq $True
 } | Sort-Object employeeId
 Write-Verbose ('{0}, Count: {1}' -f $MyInvocation.MyCommand.name, $output.count)
 $output
}

function New-StuObj {
 process {
  Write-Host ('{0}' -f $MyInvocation.MyCommand.Name)

 }
}

# ==================== Main =====================
# Imported Functions
. .\lib\Clear-SessionData.ps1
. .\lib\Get-SQLData.ps1
. .\lib\Load-Module.ps1
. .\lib\New-ADSession.ps1
. .\lib\Select-DomainController.ps1
. .\lib\Show-TestRun.ps1

Show-TestRun

'SqlServer' | Load-Module

$sqlParamsSIS = @{
 Server     = $SISServer
 Database   = $SISDatabase
 Credential = $SISCredential
 # TrustServerCertificate = $true
}

$dc = Select-DomainController $DomainControllers
New-ADSession $dc $ADCredential 'Get-ADUser'

$adData = Get-StudentTAData $dc $OrgUnit $ADCredential

$purpleFoldersSql = Get-Content .\sql\all-queries.sql -Raw

$purpleFolderData = Get-SqlData -dbParams $sqlParamsSIS -baseSql $purpleFoldersSql
$purpleFolderData
# Get-ADStudents
# Compare-Data