[CmdletBinding(DefaultParameterSetName = "DefaultSet")]
param(
    [string][Parameter(ParameterSetName = "DefaultSet")]
    $AwsProfile = "AwsProfile",
    [string][Parameter(ParameterSetName = "DefaultSet")]
    $AwsRegion = "ap-southeast-1",
    [string][Parameter(ParameterSetName = "DefaultSet")]
    $FleetId = "fleet-xxx"
)

$buildId = aws gamelift describe-fleet-attributes --fleet-ids  $FleetId --profile $AwsProfile --region $AwsRegion | ConvertFrom-Json | % FleetAttributes | % BuildId
$sdkVersion = aws gamelift describe-build --build-id $buildId --profile $AwsProfile --region $AwsRegion | ConvertFrom-Json | % Build | % ServerSdkVersion
$computeList = aws gamelift list-compute --fleet-id  $FleetId --profile $AwsProfile --region $AwsRegion | ConvertFrom-Json | % ComputeList
$computeName = $computeList[0] | % ComputeName
$computeIp = $computeList[0] | % IpAddress

if ($sdkVersion -lt 5) {
  $pem = aws gamelift get-instance-access --instance-id $computeName --fleet-id $FleetId --profile $AwsProfile --region $AwsRegion --query 'InstanceAccess.Credentials.Secret' --output text
}

$pemFile = "$PSScriptRoot/$($AwsProfile).pem"
Set-Content -Path $pemFile -Value $pem

icacls $pemFile /reset | Out-Null
icacls $pemFile /grant:r "$($env:username):(r)" | Out-Null
icacls $pemFile /inheritance:r | Out-Null

aws gamelift update-fleet-port-settings --fleet-id  $FleetId --inbound-permission-authorizations "FromPort=22,ToPort=22,IpRange=0.0.0.0/0,Protocol=TCP" --profile $AwsProfile --region $AwsRegion

Write-Output "ssh -i $pemFile gl-user-remote@$computeIp"