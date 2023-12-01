# Copyright (c) 2023 YA-androidapp(https://github.com/YA-androidapp) All rights reserved.


# 認証

.".\02-Auth.ps1"

Write-Host "認証"
Add-PowerAppsAccount -Username $username -Password $password





# ライセンス管理・監査

Write-Host "割り当てられたユーザーライセンス (Power Apps および Power Automate) の表をエクスポートする"
Get-AdminPowerAppLicenses -OutputFilePath ".\licenses.csv"


Write-Host "Power Appsユーザーの詳細のダウンロード"
Get-AdminPowerAppsUserDetails -UserPrincipalName $username -OutputFilePath ".\adminUserDetails.txt"


Write-Host "フローユーザーの詳細のダウンロード"
Get-AdminFlowUserDetails -UserId $Global:currentSession.userId # $Global:currentSession.userId はログインユーザーのGUID





# テナント

Write-Host "テナント情報の取得"
Get-TenantDetailsFromGraph
<#
ObjectType  : Company
TenantId    : 12341234-1234-1234-1234-123412341234
Country     : SG
Language    : en
DisplayName : MSFT
Domains     : @{capabilities=Email, OfficeCommunicationsOnline; default=True; id=0123456789012345; initial=True; name=contoso.onmicrosoft.com; type=Managed}
Internal    : ...
#>


Write-Host "テナント設定の取得"
Get-TenantSettings
<#
walkMeOptOut                                   : False
disableNPSCommentsReachout                     : False
disableNewsletterSendout                       : False
disableEnvironmentCreationByNonAdminUsers      : False
disablePortalsCreationByNonAdminUsers          : False
disableSurveyFeedback                          : False
disableTrialEnvironmentCreationByNonAdminUsers : False
disableCapacityAllocationByEnvironmentAdmins   : False
disableSupportTicketsVisibleByAllUsers         : False
powerPlatform                                  : ...
#>





# 環境

Write-Host "環境一覧"

Write-Host "    全ての環境"
Get-AdminPowerAppEnvironment

Write-Host "    既定環境"
Get-AdminPowerAppEnvironment -Default

Write-Host "    環境のGUIDから"
Get-AdminPowerAppEnvironment -EnvironmentName "Default-********-****-****-****-************"
Get-AdminPowerAppEnvironment -EnvironmentName (Get-AdminPowerAppEnvironment -Default).EnvironmentName





# Power Apps

# キャンバスアプリ

Write-Host "アプリ一覧"
Write-Host "    テナント内の全てのアプリ"
Get-AdminPowerApp
<#
EnvironmentName                            : 12341234-1234-1234-1234-123412341234
DisplayName                                : YA (org12345678)
Description                                :
IsDefault                                  : False
Location                                   : japan
CreatedTime                                : 2023-11-07T00:06:28.6754489Z
CreatedBy                                  : ...
LastModifiedTime                           : 2023-11-07T00:06:38.4531374Z
LastModifiedBy                             :
CreationType                               : User
EnvironmentType                            : Trial
CommonDataServiceDatabaseProvisioningState : Succeeded
CommonDataServiceDatabaseType              : Common Data Service for Apps
Internal                                   : ...
InternalCds                                :
OrganizationId                             : 12341234-1234-1234-1234-123412341234
RetentionPeriod                            : 7
#>


# Write-Host "    特定の環境に含まれるアプリ"
# Get-AdminPowerAppEnvironment -EnvironmentName '17b630e0-****-****-****-************' | Get-AdminPowerApp

# Write-Host "    入力された表示名と一致するすべての Power Apps の一覧"
# Get-AdminPowerApp "表示名"

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


Write-Host "フロー所有者のロールの詳細"
Get-AdminFlowOwnerRole -EnvironmentName "Guid" -FlowName "Guid"



Write-Host "おすすめのアプリケーションに設定"
Get-AdminPowerApp "表示名" | Select-Object -First 1 | Set-AdminPowerAppAsFeatured
# Set-AdminPowerAppAsFeatured -AppName "GUID"


Write-Host "ヒーローアプリ（Power Appsモバイルプレーヤーのリストの一番上に表示される。ヒーローアプリは1つのみ）に設定"
Get-AdminPowerApp "表示名" | Select-Object -First 1 | Set-AdminPowerAppAsHero


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
Set-AdminPowerAppOwner -AppOwner $user.ObjectId -EnvironmentName "GUID" -AppName "GUID"


Write-Host "イン コンテキスト フロー とアプリの関連付け"
# クラウドフロー
#     非ソリューション: https://preview.flow.microsoft.com/manage/environments/<EnvironmentName>/flows/<FlowName>/details
#     ソリューション内: https://us.flow.microsoft.com/manage/environments/<EnvironmentName>/solutions/<SolutionName>/flows/<FlowName>/details
# キャンバスアプリ: https://apps.powerapps.com/play/e/<EnvironmentName>/a/<AppName>?tenantId=<TenantId>
Add-AdminFlowPowerAppContext -EnvironmentName "GUID" -FlowName "GUID" -AppName "GUID"

Remove-AdminFlowPowerAppContext -EnvironmentName "GUID" -FlowName "GUID" -AppName "GUID"

# 私の注意を必要とするフロー（テナント内の環境の数が 500 未満の場合）
$environments = Get-AdminPowerAppEnvironment
$allFlows = @()
foreach ($env in $environments) {
    Write-Host "Getting flows at risk of suspension for environment $($env.DisplayName)..."
    $flows = Get-AdminFlowAtRiskOfSuspension -EnvironmentName $env.EnvironmentName
    Write-Host "Found $($flows.Count) flows at risk of suspension."
    $allFlows += $flows
}
$allFlows | Export-Csv -Path "flows.csv" -NoTypeInformation



Write-Host "API接続一覧"
Write-Host "    既定環境にあるネイティブ接続"
Get-AdminPowerAppEnvironment -Default | Get-AdminPowerAppConnection

Write-Host "    テナントにあるカスタムコネクタ（非ソリューションのみ）"
Get-AdminPowerAppConnector


Pause
