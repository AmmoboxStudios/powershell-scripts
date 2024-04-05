[CmdletBinding()]
param (
  [Parameter(Mandatory)]
  [string]$awsProfile,
  [Parameter(Mandatory)]
  [string]$awsRegion
)

$functions = aws lambda list-functions --profile $awsProfile --region $awsRegion | ConvertFrom-Json | ForEach-Object { $_.Functions }

foreach ($function in $functions) {
  $functionName = $function.FunctionName

  Write-Output "Processing function: $functionName"

  $functionConfig = aws lambda get-function-configuration --function-name $functionName --profile $awsProfile --region $awsRegion | ConvertFrom-Json

  $newObject = New-Object PSObject -Property @{
    FunctionName = $functionName
  }

  # Adding VPC configuration
  $vpcConfig = $functionConfig.VpcConfig
  if ($vpcConfig) {
    $newObject | Add-Member -MemberType NoteProperty -Name "SubnetIds" -Value ($vpcConfig.SubnetIds -join ',')
    $newObject | Add-Member -MemberType NoteProperty -Name "SecurityGroupIds" -Value ($vpcConfig.SecurityGroupIds -join ',')
    $newObject | Add-Member -MemberType NoteProperty -Name "VpcId" -Value $vpcConfig.VpcId
  }

  $newObject | Export-Csv -Path "$functionName.csv" -NoTypeInformation
}
