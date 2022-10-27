# Copyright (c) 2022 YA-androidapp(https://github.com/YA-androidapp) All rights reserved.


function Install-AzureADModule {
    Install-Module -Name AzureAD -Force -AllowClobber
    Write-Host "Azure AD module has been installed"
}

function Install-SPOModule {
    Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Force -AllowClobber
    Install-Module -Name SharePointPnPPowerShellOnline -Force -AllowClobber
    Write-Host "SPO module has been installed"
}

function Install-TeamsModule {
    Install-Module -Name MicrosoftTeams -Force -AllowClobber
    Write-Host "Teams module has been installed"
}

function Install-ExchangeOnline {
    Install-Module -Name ExchangeOnlineManagement -Force -AllowClobber
    Write-Host "EXO module has been installed"
}

function Install-PowerAppsModule {
    # PowerrShell Coreでは利用できない
    Install-Module -Name Microsoft.PowerApps.Administration.PowerShell -Force -AllowClobber
    Install-Module -Name Microsoft.PowerApps.PowerShell -Force -AllowClobber
    Write-Host "Power Apps module has been installed"

    # # 管理者権限がない場合
    # Install-Module -Name Microsoft.PowerApps.Administration.PowerShell -Scope CurrentUser
    # Install-Module -Name Microsoft.PowerApps.PowerShell -AllowClobber -Scope CurrentUser
}

function Get-Config {
    $Path = "settings.ini"

    $Config = @{}
    Get-Content $Path | % { $Config += ConvertFrom-StringData $_ }

    return $Config
}

function Pause {
    if ($psISE) {
        $null = Read-Host 'Press Enter Key...'
    }
    else {
        Write-Host "Press Any Key..."
        (Get-Host).UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
    }
}


function Install-Modules {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    Write-Host $PSVersionTable["PSVersion"].Major

    if (!$isAdmin) {
        Start-Process pwsh "-File `"$PSCommandPath`"" -Verb RunAs
        exit
    }
    else {
        Set-ExecutionPolicy RemoteSigned
        Write-Host "Set-ExecutionPolicy has been set"

        Install-AzureADModule
        Install-SPOModule
        Install-TeamsModule
        Install-ExchangeOnline
        Install-PowerAppsModule

        Pause
    }
}


Install-Modules





# ここから実処理

# 事前準備（認証情報を事前にファイルに書き出しておく）
$Config = Get-Config
$credentialPath = $Config.CREDENTIAL_PATH
if (!(Test-Path $credentialPath)) {
    $username = $Config.USERNAME

    $tmpCred = Get-Credential -Credential $username
    $tmpCred.Password | ConvertFrom-SecureString | Set-Content $credentialPath
}


# サインイン
$Config = Get-Config
$credentialPath = $Config.CREDENTIAL_PATH
$username = $Config.USERNAME

$password = Get-Content $credentialPath | ConvertTo-SecureString
$credential = New-Object System.Management.Automation.PsCredential $username, $password
Connect-AzureAD -Credential $Credential

# サインインできたことを確認
(Get-AzureADUser -ObjectId $username) | Select-Object -Property Mail

# ユーザーを検索
Get-AzureADUser -SearchString "Admin"



# Microsoft.PowerApps.Administration.PowerShell

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
Write-Host "    特定の環境に含まれるアプリ"
Get-AdminPowerAppEnvironment -EnvironmentName '17b630e0-****-****-****-************' | Get-AdminPowerApp

Write-Host "フロー一覧"
Write-Host "    テナント内の全てのフロー"
Get-AdminFlow
Write-Host "    特定の環境に含まれるフロー"
Get-AdminPowerAppEnvironment -EnvironmentName '17b630e0-****-****-****-************' | Get-AdminFlow

Pause
