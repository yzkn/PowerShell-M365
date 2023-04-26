# Copyright (c) 2023 YA-androidapp(https://github.com/YA-androidapp) All rights reserved.


.".\00-Util.ps1"


$Config = Get-Config
$credentialPath = $Config.CREDENTIAL_PATH
$username = $Config.USERNAME
$password = Get-Content $credentialPath | ConvertTo-SecureString


Write-Host "認証"
Add-PowerAppsAccount -Username $username -Password $password


Write-Host "Power Appsユーザーの詳細のダウンロード"
Get-AdminPowerAppsUserDetails -UserPrincipalName $username -OutputFilePath '.\adminUserDetails.txt'
Write-Host "割り当てられたユーザーライセンスのリストをエクスポートする"
Get-AdminPowerAppLicenses -OutputFilePath '.\licenses.csv'
Write-Host "フローユーザーの詳細のダウンロード"
Get-AdminFlowUserDetails –UserId $Global:currentSession.userId # $Global:currentSession.userId はユーザーのGUID


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

Write-Host "    ユーザー毎の所有するアプリ数"
Get-AdminPowerApp | Select-Object -ExpandProperty Owner | Select-Object -ExpandProperty displayname | Group-Object

Write-Host "    環境毎のアプリ数"
Get-AdminPowerApp | Select-Object -ExpandProperty EnvironmentName | Group-Object | ForEach-Object { New-Object -TypeName PSObject -Property @{ DisplayName = (Get-AdminPowerAppEnvironment -EnvironmentName $_.Name | Select-Object -ExpandProperty displayName); Count = $_.Count } }

Write-Host "    環境で削除されたキャンバス アプリのリスト"
$defaultEnv = Get-AdminPowerAppEnvironment -Default
Get-AdminDeletedPowerAppsList -EnvironmentName $defaultEnv.EnvironmentName
# 削除されたキャンバスアプリを回復
# Get-AdminRecoverDeletedPowerApp -AppName 'AppName' -EnvironmentName 'EnvironmentName'

Write-Host "フロー一覧"
Write-Host "    テナント内の全てのフロー"
Get-AdminFlow
# Write-Host "    特定の環境に含まれるフロー"
# Get-AdminPowerAppEnvironment -EnvironmentName '17b630e0-****-****-****-************' | Get-AdminFlow
Get-AdminFlow | Export-Csv -Path '.\FlowExport.csv'

Write-Host "おすすめのアプリケーション"
Get-AdminPowerApp 'ToDoリスト' | Select-Object -First 1 | Set-AdminPowerAppAsFeatured


Write-Host "ヒーローアプリ（Power Appsモバイルプレーヤーのリストの一番上に表示される。ヒーローアプリは1つのみ）"
Get-AdminPowerApp 'ToDoリスト' | Select-Object -First 1 | Set-AdminPowerAppAsHero


Write-Host "キャンバスアプリのアクセス許可"
# ユーザーIDを取得
# .".\10-AzureAD.ps1"
$user = Get-AzureADUser -ObjectID $username | Select-Object DisplayName, UserPrincipalName, ObjectId
Get-AdminPowerAppRoleAssignment -UserId $user.ObjectId | FT # 指定されたユーザー、全環境、全アプリ
# Get-AdminPowerAppRoleAssignment -EnvironmentName [Guid] -UserId [Guid]
# Get-AdminPowerAppRoleAssignment -AppName [Guid] -EnvironmentName [Guid] -UserId [Guid]
# Get-AdminPowerAppRoleAssignment -AppName [Guid] -EnvironmentName [Guid]

# Set-AdminPowerAppRoleAssignment -PrincipalType {User/Group/Tenant} -PrincipalObjectId [Guid] -RoleName {CanView/CanViewWithShare/CanEdit} -AppName [Guid] -EnvironmentName Default-[Guid]


Write-Host "フローのアクセス許可"
# ユーザーIDを取得
# .".\10-AzureAD.ps1"
$user = Get-AzureADUser -ObjectID $username | Select-Object DisplayName, UserPrincipalName, ObjectId
# Get-AdminFlowOwnerRole -FlowName [Guid] -EnvironmentName [Guid] -Owner $user.ObjectId
Get-AdminFlow | Select-Object -Last 1 | ForEach-Object {
    Get-AdminFlowOwnerRole -FlowName $_.FlowName -EnvironmentName $_.EnvironmentName -Owner $user.ObjectId
}

# Set-AdminFlowOwnerRole -PrincipalType {User/Group} -PrincipalObjectId [Guid] -RoleName {CanView/CanEdit} -FlowName [Guid] -EnvironmentName Default-[Guid]


Write-Host "キャンバスアプリの所有者" # $user.ObjectId / $Global:currentSession.userId 両方ユーザーのGUID
Set-AdminPowerAppOwner -AppOwner $user.ObjectId -EnvironmentName 'EnvironmentName' -AppName 'AppName'


Pause
