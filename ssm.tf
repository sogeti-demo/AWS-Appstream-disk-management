resource "aws_ssm_document" "foo" {
  name          = "Bulk_appstream_vhdx_increase"
  document_type = "Command"


  content = jsonencode(
    {
      description = "Command Document Example JSON Template"
      mainSteps = [
        {
          action = "aws:runPowerShellScript"
          inputs = {
            runCommand = [
              "",
              "$diskpart_commands = @\"",
              "select vdisk file=\"C:\\scripts\\temp\\Profile.vhdx\"",
              "detail vdisk",
              "expand vdisk maximum=10000",
              "select vdisk file=\"C:\\scripts\\temp\\Profile.vhdx\"",
              "attach vdisk",
              "list volume",
              "select volume 1",
              "extend",
              "list volume",
              "detach vdisk",
              "\"@",
              "",
              "Set-Content -Path 'c:\\scripts\\diskpart-script.txt' -Value $diskpart_commands",
              "",
              "$timestamp = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()",
              "aws logs put-log-events --log-group-name {{ logGroupName }} --log-stream-name {{ logstreamname }} --log-events timestamp=$timestamp,message=\"Starting execution at windows-level.\"",
              "",
              "$env:Path = [System.Environment]::GetEnvironmentVariable(\"Path\",\"Machine\")",
              "# get list of drives to be increased",
              "$list= \"{{HashList}}\" -split ','",
              "",
              "# make folder to put files temporarly in",
              "$tempFolderPath = \"c:\\scripts\\temp\"",
              "$localDestinationFilePath = \"$tempFolderPath\\Profile.vhdx\"",
              "$sourceBucket = \"{{ S3AppsettingsBuckets }}\"",
              "New-Item -ItemType Directory -Path $tempFolderPath -Force",
              "",
              "# loop through list to perform following actions per item in list",
              "foreach ($id in $list) {",
              "    $outputstring =  \"check number: $id\"",
              "    Write-Output $outputstring",
              "    ",
              "    # download appsettings drive",
              "    $sourceKey = \"Windows/v6/Server-2019/SettingsGroup/federated\"",
              "    ",
              "    aws s3 cp s3://$sourceBucket/$sourcekey/$id/Profile.vhdx $localDestinationFilePath --no-progress",
              "    ",
              "    # perform Diskpart commands -> change content of txt file",
              "    diskpart /s c:\\scripts\\diskpart-script.txt > logfile.txt",
              "    ",
              "    $FileContent = Get-Content 'logfile.txt'",
              "    $Matches = Select-String -InputObject $FileContent -Pattern ' successfully' -AllMatches",
              "    if ($Matches.Matches.Count -eq 6) {",
              "        ",
              "        ",
              "        # upload the new drive to s3",
              "        aws s3 cp $localDestinationFilePath s3://$sourceBucket/$sourceKey/$id/Profile.vhdx --no-progress",
              "        ",
              "        aws s3 cp logfile.txt s3://$sourceBucket/$sourcekey/$id/logfile.txt --no-progress",
              "        ",
              "        $tableName = \"{{ DynamoTable }}\"",
              "        ",
              "        $dbitem = \"{\\`\"UserHash\\`\":{\\`\"S\\`\":\\`\"$id\\`\"},\\`\"overwrite\\`\":{\\`\"BOOL\\`\":false},\\`\"size\\`\":{\\`\"N\\`\":\\`\"5\\`\"}}\"",
              "        ",
              "        aws dynamodb put-item --table-name $tableName --item $dbitem",
              "        ",
              "        ",
              "        Write-Output 'finished updating DynamoDB table.'",
              "        $timestamp = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()",
              "        aws logs put-log-events --log-group-name {{ logGroupName }} --log-stream-name {{ logstreamname }} --log-events timestamp=$timestamp,message=\"User $id processed correctly.\"",
              "        ",
              "    }",
              "    else {",
              "        $timestamp = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()",
              "        aws logs put-log-events --log-group-name {{ logGroupName }} --log-stream-name {{ logstreamname }} --log-events timestamp=$timestamp,message=\"Something went wrong processing user $id. Please check the logs\"",
              "        ",
              "    }",
              "    aws s3 cp logfile.txt s3://$sourceBucket/$sourcekey/$id/logfile.txt --no-progress",
              "    # Delete appsettings from server",
              "    Remove-Item -Path \"logfile.txt\" -Force",
              "    Remove-Item -Path \"$tempFolderPath\\Profile.vhdx\" -Force",
              "    ",
              "}",
              "",
              "",
              "",
              "$timestamp = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()",
              "aws logs put-log-events --log-group-name {{ logGroupName }} --log-stream-name {{ logstreamname }} --log-events timestamp=$timestamp,message=\"Ending execution at Windows-level and turning system off...\"",
              "        ",
              "shutdown -s -t 0"
            ]
          }
          name = "example"
        },
      ]
      parameters = {
        HashList = {
          default     = "false"
          description = "A list of Appstream userhashes to be increased"
          type        = "String"
        },
        DynamoTable = {
          default     = "false"
          description = "The dynamoDB table to write values into"
          type        = "String"
        },
        S3AppsettingsBuckets = {
          default     = "false"
          description = "Thebucket in which Appstream appsettings are kept"
          type        = "String"
        },
        logGroupName = {
          default     = "false"
          description = "The loggroup in which to write logs"
          type        = "String"
        },
        logstreamname = {
          default     = "false"
          description = "name of the log stream"
          type        = "String"
        }
      }
      schemaVersion = "2.2"
  })
}