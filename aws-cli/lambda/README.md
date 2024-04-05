## New-LambdaFunction

### Input

Comma separated value of **functions.csv** within the script folder

| Name      | Runtime    | Role                       | Handler       | Profile     | Region    |
| --------- | ---------- | -------------------------- | ------------- | ----------- | --------- |
| function1 | nodejs20.x | arn:aws:iam::xxx:role/role | index.handler | aws-profile | us-east-1 |

## Get-LambdaEnv

### Input

```ps1
.\Get-LambdaEnv.ps1 -awsProfile profile -awsRegion region
```

## Get-LambdaVpcConfig

### Input

```ps1
.\Get-LambdaVpcConfig.ps1 -awsProfile profile -awsRegion region
```

### Output

Comma separated value files for the lambda functions environment variables with the function name itself `$functionName.csv`

`function1.csv`

| FunctionName | MYSQL_PASS | MYSQL_PORT | MYSQL_USER | MYSQL_TABLE_1 | MYSQL_DB | MYSQL_HOST |
| ------------ | ---------- | ---------- | ---------- | ------------- | -------- | ---------- |
| function1    | pass       | 3306       | user       | table         | db       | rds        |

## Set-LambdaEnv

### Input

```ps1
.\Set-LambdaEnv.ps1 -awsProfile profile -awsRegion region -folderPath "cf-env-var-mapping\player"
```

### Demo


https://github.com/AmmoboxStudios/powershell-scripts/assets/112679984/7e56d9ad-dc8c-4b5c-aa3b-8337c47e75d4


