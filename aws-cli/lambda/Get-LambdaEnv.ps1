[CmdletBinding()]
param (
  [Parameter(Mandatory)]
  [string]$awsProfile,
  [Parameter(Mandatory)]
  [string]$awsRegion
)

$functions = aws lambda list-functions --profile $awsProfile --region $awsRegion | ConvertFrom-Json | % Functions

foreach ($function in $functions) {
  $functionName = $function.FunctionName

  Write-Output "Processing function: $functionName"

  $functionConfig = aws lambda get-function-configuration --function-name $functionName --profile $awsProfile --region $awsRegion | ConvertFrom-Json

  $newObject = New-Object PSObject -Property @{
    FunctionName = $functionName
  }

  foreach ($key in $functionConfig.Environment.Variables.PSObject.Properties.Name) {
    $newObject | Add-Member -MemberType NoteProperty -Name $key -Value $functionConfig.Environment.Variables.$key
  }

  $newObject | Export-Csv -Path "$functionName.csv" -NoTypeInformation
}