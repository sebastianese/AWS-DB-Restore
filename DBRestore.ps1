import-module AWSPowerShell.NetCore

function Restore-PostgreSql{
$ErrorActionPreference = "Continue"
if(Get-AWSCredential  usa)
{
Remove-AWSCredentialProfile usa -Confirm:$false
}
Set-AWSCredential -AccessKey $env:AWSAccessCDSP -SecretKey $env:AWSSecretCDSP -StoreAs usa # Saved as Jenkins global credentials

#Function Parameters
$bucket = "bucket-name"
$RdsInstance = "rds-instance-endpoint"
$RestoreFolder = "\var\lib\jenkins\backups\$bucket\"
$Pass = $env:postgrespass # Saved as Jenkins global credential

if (!(Test-Path $RestoreFolder)) {

    New-Item -Path $RestoreFolder -Type Directory}

set-location $RestoreFolder
Get-ChildItem $RestoreFolder  | Remove-Item -Force -Recurse -Confirm:$false
Get-ChildItem $RestoreFolder  | Remove-Item -Force -Recurse -Confirm:$false


#Start Session
Initialize-AWSDefaultConfiguration -ProfileName usa -Region us-west-2


# Repeat this block per each db
$db = "*name.tar"
$bname = Get-S3Object -Region us-west-2 -BucketName $bucket | where {$_.Key -like $db} | Sort-Object -Property LastModified -Descending | Select-Object -First 1 | Select-Object -ExpandProperty BucketName
$Backup = Get-S3Object -Region us-west-2 -BucketName $bucket | where {$_.Key -like $db} | Sort-Object -Property LastModified -Descending | Select-Object -First 1 | Select-Object -ExpandProperty Key
Write-Verbose "Downloading backup: $Backup" -Verbose
Read-S3Object -BucketName $bname -Key $Backup -File $Backup -Region us-west-2

#Termianate Session
Remove-AWSCredentialProfile usa -Confirm:$false


#PG Restore Routine
$FilesToRestore = Get-ChildItem -Recurse | where {$_.Name -like "*tar"} | select -ExpandProperty FullName

Foreach ($File in $FilesToRestore) {
$env:PGPASSWORD = $Pass
$DbName =  Split-Path -Path $File -Leaf
$DbNameShort = $DbName.Substring(0,$DbName.Length-4)
Write-Verbose "Dropping and re-creating the Public Schema for $DbNameShort" -Verbose
psql -U nesroot -h "$RdsInstance" -d "$DbNameShort" -c 'DROP SCHEMA public CASCADE;CREATE SCHEMA public;GRANT ALL ON SCHEMA public TO root;'


Write-Verbose "Restoring DB: $DbNameShort with file $File " -Verbose
(pg_restore --host "$RdsInstance" --port "5432" --username "root" --no-password --dbname "$DbNameShort" --schema "public" --verbose "$File")
 }
exit 0
}


Function Restore-MongoDB{
$ErrorActionPreference = "Continue"
if(Get-AWSCredential  usa)
{
Remove-AWSCredentialProfile usa -Confirm:$false
}
Set-AWSCredential -AccessKey $env:AWSAccessCDSP -SecretKey $env:AWSSecretCDSP -StoreAs usa # Saved as Jenkins global credentials

Set-AWSCredential usa

#Function Parameters
$bucket = "bucket-name"
$Mongohost = "mongo-hostname:27017"
$RestoreFolder = "\var\lib\jenkins\backups\$bucket\"
$MongoUser = "mongo-user"
$MongoPass = $env:MongoPass # Saved as Jenkins global credentials


if (!(Test-Path $RestoreFolder)) {

    New-Item -Path $RestoreFolder -Type Directory}

set-location $RestoreFolder
Get-ChildItem $RestoreFolder  | Remove-Item -Force -Recurse -Confirm:$false
Get-ChildItem $RestoreFolder  | Remove-Item -Force -Recurse -Confirm:$false


#Start Session

#Start Session
Initialize-AWSDefaultConfiguration -ProfileName usa -Region us-west-2


#repeat block for each collection
$db = "*collection-name.tar"
$bname = Get-S3Object  -Region us-west-2 -BucketName $bucket | where {$_.Key -like $db} | Sort-Object -Property LastModified -Descending | Select-Object -First 1 | Select-Object -ExpandProperty BucketName
$Backup = Get-S3Object  -Region us-west-2 -BucketName $bucket | where {$_.Key -like $db} | Sort-Object -Property LastModified -Descending | Select-Object -First 1 | Select-Object -ExpandProperty Key
Write-Verbose "Downloading backup: $Backup" -Verbose
Read-S3Object -BucketName $bname -Key $Backup -File $Backup  -Region us-west-2

#Termianate Session
Remove-AWSCredentialProfile usa -Confirm:$false

#Restore Routine
$FilesToRestore = Get-ChildItem -Recurse | where {$_.Name -like "*tar"} | select -ExpandProperty FullName

Foreach ($File in $FilesToRestore) {
$DbName =  Split-Path -Path $File -Leaf
Write-Verbose "Restoring DB: $DbNameShort with file $File " -Verbose
mongorestore --username $MongoUser --password $MongoPass --drop --gzip --authenticationDatabase admin --ssl  --archive=$File --host $MongoHost
 }

exit 0
}
