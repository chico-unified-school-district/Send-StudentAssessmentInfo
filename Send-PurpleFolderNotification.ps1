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

function Format-EmailObj ($baseHtml) {
 process {
  #TODO
  $_.message = $baseHtml -f $blahblah
  Write-Verbose ()'{0}.{1}' -f $MyInvocation.MyCommand.Name, $_.)
}
$_
}

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
  $_.title -notmatch 'test' -and
  $_.AccountExpirationDate -isnot [datetime] -and
  # $_.LastLogonDate -is [datetime] -and
  $_.Enabled -eq $True | Select-Object -Property @{n = 'departmentNumber'; e = {} }
 }
 Write-Host ('{0}, Count: {1}' -f $MyInvocation.MyCommand.name, @($output).count) -F Green
 $output
}

function Send-PwMsg {
 begin {
  $mailParams = @{
   From       = '<{0}>' -f $EmailCredential.Username
   Subject    = 'CUSD Password Expires Soon'
   BodyAsHTML = $True
   SMTPServer = 'smtp.office365.com'
   Cred       = $EmailCredential # use a valid Office365 account with Flow rules in place to prevent SPAM warnings.
   UseSSL     = $True
   Port       = 587
  }
  if ( $Bcc ) { $mailParams.Bcc = $Bcc } # Add Bcc to outgoing email messages.
 }
 process {
  $mailParams.Body = $_.html
  $mailParams.To = "<$($_.mail1)>", "<$($_.mail2)>"
  $msg = $MyInvocation.MyCommand.Name, ($mailParams.To -join ','), ((Get-Date $_.expireDate -f 'D').Replace(',', ''))
  Write-Host ('{0},{1},{2}' -f $msg)
  if (!$WhatIf) { Send-MailMessage @mailParams }
  $mailParams
 }
}

# ==================== Main =====================
if ($Verbose) { $VerbosePreference = 'Continue' } # Imported, non-compiled module functions do not honor local session preferences
# TODO
Remove-Module CommonScriptFunctions
$moduleCommands = 'Clear-SessionData', 'New-ADSession', 'New-SqlOperation', 'Select-DomainController', 'Show-TestRun'
# Import-Module -Name CommonScriptFunctions -Cmdlet $moduleCmds
Import-Module -Name 'G:\My Drive\CUSD\Scripts\Powershell\MyModules\CommonScriptFunctions\CommonScriptFunctions.psm1'


if ($Whatif) { Show-TestRun }


$sqlParamsSIS = @{
 Server     = $SISServer
 Database   = $SISDatabase
 Credential = $SISCredential
}

# $dc = Select-DomainController $DomainControllers
# New-ADSession -dc $dc -cmdlets 'Get-ADUser' -Credential $ADCredential

# $adData = Get-StudentTAData $dc $OrgUnit $ADCredential

# $adData = Get-ActiveAD $OrgUnit
# Compare-Data $purpleFolderData $adData # Look for siteCode change

# 2 pipelines - 1 for admin and 1 for counselors

$adminSql = Get-Content .\sql\admin.sql -Raw
$adminData = New-SqlOperation @sqlParamsSIS -Query $adminSql | ConvertTo-Csv | ConvertFrom-Csv
$adminData.count

$adminData | Select-Latest | Format-EmailObj $adminMsg | Send-Email

# $counselorSql = Get-Content .\sql\counselors.sql -Raw
# $counselorData = New-SqlOperation @sqlParamsSIS -Query $counselorSql | ConvertTo-Csv | ConvertFrom-Csv
# $counselorData.count

if ($Whatif) { Show-TestRun }