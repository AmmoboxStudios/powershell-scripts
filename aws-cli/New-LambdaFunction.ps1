$csvFilePath = "${PSScriptRoot}\functions.csv"

# Check if the CSV file exists
if (!(Test-Path -Path $csvFilePath)) {
  Write-Output "$csvFilePath doesn't exist"
  return
}

$expectedHeaders = @("Name", "Runtime", "Role", "Handler", "Profile", "Region", "EnvironmentVariables")
$actualHeaders = (Get-Content -Path $csvFilePath -TotalCount 1) -split ',' | ForEach-Object { $_.Trim() }
$missingHeaders = $expectedHeaders | Where-Object { $_ -notin $actualHeaders }

# Check if the expected headers are missing
if ($missingHeaders.Count) {
  Write-Host "CSV doesn't have expected headers: $($expectedHeaders -join ','). "
  Write-Host "Actual headers: $($actualHeaders -join ',')."
  return
} 

$functions = Import-Csv $csvFilePath

foreach ($function in $functions) {
  $functionName = $function.Name
  $runtime = $function.Runtime
  $role = $function.Role
  $handler = $function.Handler
  $awsProfile = $function.Profile
  $awsRegion = $function.Region
  $EnvironmentVariables = $function.EnvironmentVariables

  # Create the Lambda function
  aws lambda create-function `
    --function-name $functionName `
    --role $role `
    --runtime $runtime `
    --handler $handler `
    --profile $awsProfile `
    --region $awsRegion `
    --zip-file fileb://lambda.zip

  # Wait for the function to become active
  do {
    $functionState = aws lambda get-function --function-name $functionName --profile $awsProfile --region $awsRegion --output json | ConvertFrom-Json | % Configuration | % State
    Write-Output "$functionName is $functionState"
    Start-Sleep -Seconds 1
  } until ($functionState -eq "Active")

  # Update function configuration
  aws lambda update-function-configuration --function-name $functionName --timeout 30 --profile $awsProfile --region $awsRegion --output table

  if ($null -ne $EnvironmentVariables) {
    if (Test-Path -Path $EnvironmentVariables) {
      # Read environment variables from file
      $json = Get-Content -Path $EnvironmentVariables
      aws lambda update-function-configuration --function-name $functionName --environment Variables=$json --profile $awsProfile --region $awsRegion --output table
    }
    else {
      Write-Output "$EnvironmentVariables doesn't exist, skipping"
    }
  }

  # Publish a new version of the function and create aliases
  aws lambda publish-version --function-name $functionName --profile $awsProfile --region $awsRegion --output table
  aws lambda create-alias --function-name $functionName --function-version '$LATEST' --name production --profile $awsProfile --region $awsRegion --output table
  aws lambda create-alias --function-name $functionName --function-version '$LATEST' --name staging --profile $awsProfile --region $awsRegion --output table
}
