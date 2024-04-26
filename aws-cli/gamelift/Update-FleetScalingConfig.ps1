$csvFilePath = "${PSScriptRoot}\fleets.csv"

if (!(Test-Path -Path $csvFilePath)) {
  Write-Output "$csvFilePath doesn't exist"
  return
}

$expectedHeaders = @("AliasName", "FleetId", "TargetValue", "Region", "Profile", "Desired", "Min", "Max")
$actualHeaders = (Get-Content -Path $csvFilePath -TotalCount 1) -split ',' | ForEach-Object { $_.Trim() }
$missingHeaders = $expectedHeaders | Where-Object { $_ -notin $actualHeaders }

if ($missingHeaders.Count) {
  Write-Host "CSV doesn't have expected headers: $($expectedHeaders -join ','). "
  Write-Host "Actual headers: $($actualHeaders -join ',')."
  return
} 
$fleets = Import-Csv $csvFilePath

foreach ($fleet in $fleets) {
  $aliasName = $fleet.AliasName
  $fleetId = $fleet.Id
  $targetValue = $fleet.TargetValue
  $desired = $fleet.Desired
  $minSize = $fleet.Min
  $maxSize = $fleet.Max
  $awsRegion = $fleet.Region
  $awsProfile = $fleet.Profile

  Write-Output "Running aws cli for $awsProfile ..."

  if ($null -ne $aliasName) {
    $gameliftAliases = aws gamelift list-aliases --profile $awsProfile --region $awsRegion | ConvertFrom-Json | % Aliases
    $fleetId = $gameliftAliases | Where-Object Name -eq $aliasName | Select-Object -ExpandProperty RoutingStrategy | % FleetId
  }

  Write-Output "UpdateFleetCapacity of $awsRegion with min: $minSize & max: $maxSize"

  aws gamelift update-fleet-capacity `
    --fleet-id $fleetId `
    --desired-instances $desired `
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

  $scalingPolicies = aws gamelift describe-scaling-policies --fleet-id $fleetId --profile $awsProfile --region $awsRegion |  ConvertFrom-Json | % ScalingPolicies

  if ($null -ne $scalingPolicies) {
    foreach ($scalingPolicy in $scalingPolicies) {
      $scalingPolicyName = $scalingPolicy.Name
      $scalingPolicyStatus = $scalingPolicy.Status

      if ($scalingPolicyStatus -ne 'DELETED') {
        Write-Output "DeleteScalingPolicy for $awsRegion with name: $scalingPolicyName"

        aws gamelift delete-scaling-policy `
          --fleet-id $fleetId `
          --name $scalingPolicyName `
          --profile $awsProfile `
          --region $awsRegion `
      }
      
    }
  }

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