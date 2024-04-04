$csvFilePath = "${PSScriptRoot}\fleets.csv"

if (!(Test-Path -Path $csvFilePath)) {
  Write-Output "$csvFilePath doesn't exist"
  return
}

$expectedHeaders = @("Id", "TargetValue", "Region", "Profile", "Min", "Max")
$actualHeaders = (Get-Content -Path $csvFilePath -TotalCount 1) -split ',' | ForEach-Object { $_.Trim() }
$missingHeaders = $expectedHeaders | Where-Object { $_ -notin $actualHeaders }

if ($missingHeaders.Count) {
  Write-Host "CSV doesn't have expected headers: $($expectedHeaders -join ','). "
  Write-Host "Actual headers: $($actualHeaders -join ',')."
  return
} 
$fleets = Import-Csv $csvFilePath

foreach ($fleet in $fleets) {
  $fleetId = $fleet.Id
  $targetValue = $fleet.TargetValue
  $minSize = $fleet.Min
  $maxSize = $fleet.Max
  $awsRegion = $fleet.Region
  $awsProfile = $fleet.Profile

  Write-Output "Running aws cli for $awsProfile ..."

  Write-Output "UpdateFleetCapacity of $awsRegion with min: $minSize & max: $maxSize"

  aws gamelift update-fleet-capacity `
    --fleet-id $fleetId `
    --min-size $minSize `
    --max-size $maxSize `
    --profile $awsProfile `
    --region $awsRegion `
    --output table

  aws gamelift describe-fleet-capacity `
    --fleet-id $fleetId `
    --profile $awsProfile `
    --region $awsRegion `
    --output table

  Write-Output "PutScalingPolicy for $awsRegion with $targetValue % of available game sessions"

  aws gamelift put-scaling-policy `
    --fleet-id $fleetId `
    --name "${targetValue}PercentAvailableGameSessions" `
    --policy-type "TargetBased" `
    --metric-name "PercentAvailableGameSessions" `
    --target-configuration "TargetValue=$targetValue" `
    --region $awsRegion `
    --profile $awsProfile `
    --output table

} 