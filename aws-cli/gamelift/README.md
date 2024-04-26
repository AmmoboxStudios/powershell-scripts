## Update-FleetScalingConfig

### Input

Comma separated value of **fleets.csv** within the script folder (use either Alias / FleetId)

Refer [here](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/gamelift/update-fleet-capacity.html) for references of the parameter values

| AliasName | FleetId                                    | Region    | Profile   | TargetValue | Desired | Min | Max |
| --------- | ------------------------------------------ | --------- | --------- | ----------- | ------- | --- | --- |
| aliasName | fleet-12345678-abc-defg-hijk-lmnopqrstuvwx | us-east-1 | myProfile | 10          | 1       | 0   | 5   |

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

DeleteScalingPolicy for us-east-1 with name: 1PercentAvailableGameSessions
PutScalingPolicy for us-east-1 with 10 % of available game sessions
--------------------------------------------
|             PutScalingPolicy             |
+------+-----------------------------------+
|  Name|  10PercentAvailableGameSessions   |
+------+-----------------------------------+
```
