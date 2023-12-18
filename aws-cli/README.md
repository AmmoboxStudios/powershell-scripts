# AWS CLI Powershell Scripts

## Pre-requisites

- Access Keys from [AWS account and IAM credentials](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-prereqs.html)
- [Install](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) aws cli v2 `msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi /qn`
- Configure aws cli [profile](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html) with `aws configure --profile myProfile`

## Update-FleetScalingConfig

### Input

Comma separated value of **fleets.csv** within the script folder

Id | Region | Profile | TargetValue | Min | Max
--- | --- | --- | --- | --- | --- |
fleet-12345678-abc-defg-hijk-lmnopqrstuvwx | us-east-1 | myProfile | 1 | 1 | 1

### Output

```
----------------------------------------------------------------------------------------------------------
|                                           UpdateFleetCapacity                                          |
+----------+---------------------------------------------------------------------------------------------+
|  FleetArn|  arn:aws:gamelift:us-east-1:123456789012:fleet/fleet-12345678-abc-defg-hijk-lmnopqrstuvwx   |
|  FleetId |  fleet-12345678-abc-defg-hijk-lmnopqrstuvwx                                                 |
|  Location|  us-east-1                                                                                  |
+----------+---------------------------------------------------------------------------------------------+

----------------------------------------------------------------------------------------------------------------
|                                             DescribeFleetCapacity                                            |
+--------------------------------------------------------------------------------------------------------------+
||                                                FleetCapacity                                               ||
|+--------------+---------------------------------------------------------------------------------------------+|
||  FleetArn    |  arn:aws:gamelift:us-east-1:123456789012:fleet/fleet-12345678-abc-defg-hijk-lmnopqrstuvwx   ||
||  FleetId     |  fleet-12345678-abc-defg-hijk-lmnopqrstuvwx                                                 ||
||  InstanceType|  c4.large                                                                                   ||
||  Location    |  us-east-1                                                                                  ||
|+--------------+---------------------------------------------------------------------------------------------+|
|||                                              InstanceCounts                                              |||
||+-------------------------------------------------------------------------------+--------------------------+||
|||  ACTIVE                                                                       |  1                       |||
|||  DESIRED                                                                      |  1                       |||
|||  IDLE                                                                         |  1                       |||
|||  MAXIMUM                                                                      |  1                       |||
|||  MINIMUM                                                                      |  1                       |||
|||  PENDING                                                                      |  0                       |||
|||  TERMINATING                                                                  |  0                       |||
||+-------------------------------------------------------------------------------+--------------------------+||
```
