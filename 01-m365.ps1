# Copyright (c) 2022 YA-androidapp(https://github.com/YA-androidapp) All rights reserved.


# 既にインストールされているかどうかに関わらずインストールする場合は$True
set-variable -name ForceInstall -value $True -option constant
# 管理者権限を必須とする場合は$True
set-variable -name RunAsAdmin -value $True -option constant


$moduleNamesCore = @(
    # AzureAD
    "AzureAD",
    # ExchangeOnline
    "ExchangeOnlineManagement",
    # SPO
    "Microsoft.Online.SharePoint.PowerShell",
    "SharePointPnPPowerShellOnline",
    # Teams
    "MicrosoftTeams"
)

$moduleNamesDesktop = @(
    # AzureAD
    "AzureAD",
    # ExchangeOnline
    "ExchangeOnlineManagement",
    # PowerApps(for Windows PowerShell only)
    "Microsoft.PowerApps.Administration.PowerShell",
    "Microsoft.PowerApps.PowerShell",
    # SPO
    "Microsoft.Online.SharePoint.PowerShell",
    "SharePointPnPPowerShellOnline",
    # Teams
    "MicrosoftTeams"
)


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
    param (
        [boolean]$AdminScope
    )

    Write-Host "PSEdition:" $PSVersionTable['PSEdition']
    if ($PSVersionTable['PSEdition'] -eq "Core") {
        # PowerShell Core
        $moduleNames = $moduleNamesCore
    }
    else {
        # Windows PowerShell
        $moduleNames = $moduleNamesDesktop
    }

    $moduleNames | ForEach-Object {
        Write-Host $_ -NoNewline

        if ($AdminScope) {
            # 管理者権限
            if ($ForceInstall) {
                Install-Module -Force -AllowClobber -Name $_
                Write-Host " module has been installed for Admin" -NoNewline
            }
            else {
                $isInstalled = (Get-Module -ListAvailable -Name $_).Count -gt 0
                $installedVersion = (Get-Module -Name $_ -ListAvailable).Version
                $latestVersion = (Find-Module -Name $_ -AllVersions | Sort-Object Version -Descending | Select-Object -First 1).Version
                if (!$isInstalled -and ($installedVersion -ne $latestVersion)) {
                    Install-Module -Force -AllowClobber -Name $_
                    Write-Host " module has been installed for Admin" -NoNewline
                }
            }
        }
        else {
            # ユーザー権限
            if ($ForceInstall) {
                Install-Module -Force -AllowClobber -Name $_ -Scope CurrentUser
                Write-Host " module has been installed for CurrentUser" -NoNewline
            }
            else {
                $isInstalled = (Get-Module -ListAvailable -Name $_).Count -gt 0
                if (!$isInstalled -and ($installedVersion -ne $latestVersion)) {
                    Install-Module -Force -AllowClobber -Name $_ -Scope CurrentUser
                    Write-Host " module has been installed for CurrentUser" -NoNewline

                }
            }
        }

        # 改行を出力
        Write-Host ""
    }
}

function Main {
    # 管理者権限の判定
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if (!$isAdmin) {
        # 管理者権限で起動されていない場合
        if (!$RunAsAdmin) {
            # カレントユーザー向けにモジュールをインストール
            Install-Modules $RunAsAdmin
        }
        else {
            # 新規に管理者権限で起動
            Start-Process pwsh "-File `"$PSCommandPath`"" -Verb RunAs
            exit
        }
    }
    else {
        # 管理者権限で起動されている場合
        Set-ExecutionPolicy RemoteSigned
        Write-Host "Set-ExecutionPolicy has been set"

        Install-Modules $RunAsAdmin

        Pause
    }
}


Main
