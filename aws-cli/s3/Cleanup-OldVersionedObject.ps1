$csvFilePath = "${PSScriptRoot}\objects.csv"

$expectedHeaders = @("Bucket", "Prefix", "EndpointUrl", "AwsProfile")
$actualHeaders = (Get-Content -Path $csvFilePath -TotalCount 1) -split ',' | ForEach-Object { $_.Trim() }
$missingHeaders = $expectedHeaders | Where-Object { $_ -notin $actualHeaders }

if ($missingHeaders.Count) {
  Write-Host "CSV doesn't have expected headers: $($expectedHeaders -join ','). "
  Write-Host "Actual headers: $($actualHeaders -join ',')."
  return
} 
$objects = Import-Csv $csvFilePath

if (!(Test-Path -Path $csvFilePath)) {
  Write-Output "$csvFilePath doesn't exist"
  return
}

function Get-SumInGB {
  param(
    [object[]]$Object
  )
  Process {
    if ($null -eq $Object) {
      return 0
    }

    $Sum = $Object | Measure-Object -Property Size -Sum | % Sum

    if ($Sum -eq 0) { $SumInGB = 0 }
    else { $SumInGB = [math]::round($Sum / 1GB, 2) }
    return $SumInGB
  }
}

foreach ($object in $objects) {
  $bucket = $object.Bucket
  $prefix = $object.Prefix
  $endpointUrl = $object.EndpointUrl
  $awsProfile = $object.AwsProfile

  $versions = aws s3api list-object-versions --bucket $bucket --prefix $prefix --endpoint-url=$endpointUrl --profile $awsProfile | ConvertFrom-Json | % Versions
  $allVersions = $versions | Where-Object Key -match '.zip' # only select zip file format
  $allVersionsGB = Get-SumInGB($allVersions)
  $latestVersions = $allVersions | Where-Object IsLatest -eq $true
  $latestVersionsGB = Get-SumInGB($latestVersions)
  $oldVersions = $allVersions | Where-Object IsLatest -eq $false
  $oldVersionsGB = Get-SumInGB($oldVersions)

  Write-Output "`n=== Bucket: $bucket | Prefix : $prefix ==="
  Write-Output "`nTotal: $($allVersions.Count) ($allVersionsGB GB) | Latest: $($latestVersions.Count) ($latestVersionsGB GB) | Old: $($oldVersions.Count) ($oldVersionsGB GB)`n"

  foreach ($item in $oldVersions) {
    $objectKey = $item.Key
    $versionId = $item.VersionId
    Write-Output "Deleting $objectKey : $versionId"
    aws s3api delete-object --bucket $bucket --key $objectKey --endpoint-url=$endpointUrl --profile $awsProfile --key $objectKey --version-id $versionId
  }

  if ($oldVersions.Count -ne 0) {
    Write-Output "`nCleanup completed, $oldVersionsGB GB storage recovered"
  } else {
    Write-Output "No cleanup required"
  }
}
