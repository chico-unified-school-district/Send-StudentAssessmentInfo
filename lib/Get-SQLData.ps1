function Get-SQLData ($dbParams, $table, $baseSql, $sqlVars) {
 process {
  $sql = if ($table -and $sqlVars) {
   $baseSql -f $table, $sqlVars
  }
  elseif ($table) {
   $baseSql -f $table
  }
  elseif ($sqlVars) {
   $baseSql -f $sqlVars
  }
  else { $baseSql }
  $results = Invoke-SqlCmd @dbParams -TrustServerCertificate:$true -Query $sql
  Write-Host ("{0},Results Count: {1},`n{2}" -f $MyInvocation.MyCommand.Name, @($results).count, $sql)
  $results
 }
}