[cmdletbinding()]
param (
 [Parameter(Mandatory = $True)]
 [string]$SISServer,
 [Parameter(Mandatory = $True)]
 [string]$SISDatabase,
 [Parameter(Mandatory = $True)]
 [System.Management.Automation.PSCredential]$SISCredential,
 [Parameter(Mandatory = $True)]
 [System.Management.Automation.PSCredential]$EmailCredential,
 [Parameter(Mandatory = $false)]
 [string[]]$Bcc,
 [Alias('wi')]
 [switch]$WhatIf
)

function Get-Priors ($csvFile) {
 process {
  Write-Host ('{0},{1}' -f $MyInvocation.MyCommand.Name, $csvFile) -F Green
  if (!(Test-Path $csvFile)) { 'key' | Out-File $csvFile }
  Import-Csv $csvFile
 }
}

function Format-Obj ($type) {
 process {
  $obj = '' | Select-Object dbRow, msg, subject, type, key
  $leaveDate = Get-Date $_.'SC Leave Date' -F yyyyMMdd
  $obj.key = $_.ID + $_.School + $leaveDate
  $obj.dbRow = $_
  $obj.type = $type
  $obj
 }
}

function Format-EmailMsg ($baseMsg) {
 process {
  $msg = $baseMsg -replace 'STU.ID', $_.dbRow.ID
  $msg = $msg -replace 'STU.FN', $_.dbRow.FN
  $msg = $msg -replace 'STU.LN', $_.dbRow.LN
  $_.msg = $msg
  $_
 }
}

function Select-Latest ($data) {
 begin {
 }
 process {
  # Write-Host ('{0}' -f $MyInvocation.MyCommand.Name)
  $uniqueIDs = ($data | Select-Object -Property ID | Sort-Object -Property ID -Unique).ID
  Foreach ($id in $uniqueIDs) {
   $allMatching = $data | Where-Object { $_.ID -eq $id }
   # Write-Host ($allMatching | Out-String) -F Blue
   $result = $allMatching | Sort-Object -Property ID, 'SC Leave Date' -Descending | Select-Object -First 1
   # Write-Host ($result | Out-String) -F Green
   # read-host wait
   $result
  }
 }
}

function Send-Msg {
 begin {
  $mailParams = @{
   From       = '<{0}>' -f $EmailCredential.Username
   Subject    = $null
   BodyAsHTML = $True
   SMTPServer = 'smtp.office365.com'
   Cred       = $EmailCredential # use a valid Office365 account with Flow rules in place to prevent SPAM warnings.
   UseSSL     = $True
   Port       = 587
  }
  if ( $Bcc ) { $mailParams.Bcc = $Bcc } # Add Bcc to outgoing email messages.
 }
 process {
  $mailParams.Body = $_.msg
  $mailParams.To = $_.dbRow.Email
  $mailParams.Subject = 'Forward Assessment Info - ' + $_.dbRow.FN + ' ' + $_.dbRow.LN
  Write-Verbose ($mailParams | Out-String)
  $msg = $MyInvocation.MyCommand.Name, $mailParams.To,
  $_.dbRow.ID, $_.dbRow.School , $_.type
  Write-Host ('{0},{1},{2},{3},{4}' -f $msg) -F Blue
  if (!$WhatIf) {
   Try {
    Write-Debug  'Send Mail Message?'
    Send-MailMessage @mailParams
   }
   catch {
    Write-Error ('{0},{1},{2}, ERROR sending email' -f $msg)
    return
   }
  }
  $global:skip += $_.key
 }
}

function Skip-Priors ($priorData) {
 begin {
 }
 process {
  # No global skip here as it would prevent both admin and counselors from getting proper notifications
  if ($priorData.key -contains $_.key) {
   $msg = $MyInvocation.MyCommand.Name, ($_.dbRow.FN + ' ' + $_.dbRow.LN), $_.key
   Write-Host ('{0},{1},{2}' -f $msg) -F Yellow
   return
  }
  $_
 }
}

function Update-Priors ($csvFile, $priorData) {
 process {
  if ($WhatIf -or ($priorData.key -contains $_.key) -or ($global:skip -contains $_.key)) { return }
  Write-Host ('{0},{1}' -f $MyInvocation.MyCommand.Name, $_.key) -F Green
  $_.key | Out-File $csvFile -Append
 }
}

# ==================== Main =====================
# if ($Verbose) { $VerbosePreference = 'SilentlyContinue' } # Imported, non-compiled module functions do not honor local session preferences
$moduleCommands = 'Clear-SessionData', 'New-SqlOperation', 'Show-TestRun'
Import-Module -Name CommonScriptFunctions -Cmdlet $moduleCommands

if ($WhatIf) { Show-TestRun }

$sqlParamsSIS = @{
 Server     = $SISServer
 Database   = $SISDatabase
 Credential = $SISCredential
}

$priorCSV = '.\lib\priorNotifications.txt'
$priorNotifications = Get-Priors $priorCsv
$global:skip = @()

# ======== ADMIN
$adminSql = Get-Content .\sql\admin.sql -Raw
$adminData = New-SqlOperation @sqlParamsSIS -Query $adminSql | ConvertTo-Csv | ConvertFrom-Csv
'Admin Msg Count: ' + @($adminData).count

$adminMsg = Get-Content .\html\admin.html -Raw
$adminObjs = Select-Latest $adminData | Format-Obj Admin
$adminObjs | Skip-Priors $priorNotifications |
Format-EmailMsg $adminMsg | Send-Msg

# ======== COUNSELORS
$counselorSql = Get-Content .\sql\counselors.sql -Raw
$counselorData = New-SqlOperation @sqlParamsSIS -Query $counselorSql | ConvertTo-Csv | ConvertFrom-Csv
'Counselor Msg Count: ' + @($counselorData).count

$counselorMsg = Get-Content .\html\counselors.html -Raw
$counselorObjs = Select-Latest $counselorData | Format-Obj Counselors
$counselorObjs | Skip-Priors $priorNotifications |
Format-EmailMsg $counselorMsg | Send-Msg

$counselorObjs | Update-Priors $priorCSV $priorNotifications
$adminObjs | Update-Priors $priorCSV $priorNotifications

if ($WhatIf) { Show-TestRun }