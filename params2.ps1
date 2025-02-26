$global:params = @{
 dcs             = 'Mainframe.chico.usd', 'optimus.chico.usd', 'kickoff.chico.usd'
 ADCredential    = $ADTasks
 OrgUnit         = $StudentOU
 SISServer       = $sisServer
 # SISDatabase     = $sisDB
 SISDatabase     = $SISTestDB
 SISCredential   = $AeriesCreds
 EmailCredential = $JenkinsAlerts
 Bcc             = 'jcooper@chicousd.net'
}
$params
ls -recurse -filter *.ps1 | Unblock-File