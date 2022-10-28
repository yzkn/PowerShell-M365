$Config = Get-Config
$credentialPath = $Config.CREDENTIAL_PATH
$username = $Config.USERNAME
$password = Get-Content $credentialPath | ConvertTo-SecureString


Write-Host "認証"
Add-PowerAppsAccount -Username $username -Password $password

Write-Host "環境一覧"
Write-Host "    全ての環境"
Get-AdminPowerAppEnvironment
Write-Host "    既定環境"
Get-AdminPowerAppEnvironment -Default
# Write-Host "    環境のGUIDから"
# Get-AdminPowerAppEnvironment –EnvironmentName 'Default-********-****-****-****-************'

Write-Host "アプリ一覧"
Write-Host "    テナント内の全てのアプリ"
Get-AdminPowerApp
# Write-Host "    特定の環境に含まれるアプリ"
# Get-AdminPowerAppEnvironment -EnvironmentName '17b630e0-****-****-****-************' | Get-AdminPowerApp

Write-Host "フロー一覧"
Write-Host "    テナント内の全てのフロー"
Get-AdminFlow
# Write-Host "    特定の環境に含まれるフロー"
# Get-AdminPowerAppEnvironment -EnvironmentName '17b630e0-****-****-****-************' | Get-AdminFlow

Pause
