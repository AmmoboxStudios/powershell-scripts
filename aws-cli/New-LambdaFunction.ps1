$csvFilePath = "${PSScriptRoot}\functions.csv"

$expectedHeaders = @("Name", "Runtime", "Role", "Handler", "Profile", "Region")
$actualHeaders = (Get-Content -Path $csvFilePath -TotalCount 1) -split ',' | ForEach-Object { $_.Trim() }
$missingHeaders = $expectedHeaders | Where-Object { $_ -notin $actualHeaders }

if ($missingHeaders.Count) {
  Write-Host "CSV doesn't have expected headers: $($expectedHeaders -join ','). "
  Write-Host "Actual headers: $($actualHeaders -join ',')."
  return
} 
$functions = Import-Csv $csvFilePath

if (!(Test-Path -Path $csvFilePath)) {
  Write-Output "$csvFilePath doesn't exist"
  return
}

foreach ($function in $functions) {
  $functionName = $function.Name
  $runtime = $function.Runtime
  $role = $function.Role
  $handler = $function.Handler
  $awsProfile = $function.Profile
  $awsRegion = $function.Region

  aws lambda create-function `
    --function-name $functionName `
    --role $role `
    --runtime $runtime `
    --handler $handler `
    --profile $awsProfile `
    --region $awsRegion `
    --zip-file fileb://lambda.zip

  Start-Sleep -Seconds 1

  aws lambda publish-version --function-name $functionName --profile --profile $awsProfile --region $awsRegion

  aws lambda create-alias --function-name $functionName --function-version 1 --name production --profile $awsProfile --region $awsRegion
  aws lambda create-alias --function-name $functionName --function-version 1 --name staging --profile $awsProfile --region $awsRegion
}