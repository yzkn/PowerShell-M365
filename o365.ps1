# Copyright (c) 2022 YA-androidapp(https://github.com/YA-androidapp) All rights reserved.


function Install-AzureADModule {
    Install-Module -Name AzureAD -Force -AllowClobber
    Write-Host "Azure AD module has been installed"
}

function Install-SPOModule {
    Install-Module -Name Microsoft.Online.SharePoint.PowerShell -Force -AllowClobber
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
    if ($PSVersionTable["PSVersion"].Major -lt 7) {
        Invoke-Expression "& { $(Invoke-RestMethod https://aka.ms/install-powershell.ps1) } -UseMSI"
        exit
    }
    else {
        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
        $isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

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

            Pause
        }
    }
}


Install-Modules





# ここから実処理

# 事前準備（認証情報を事前にファイルに書き出しておく）
$credentialPath = "C:\Users\<EXAMPLE>\Desktop\credential.dat"
$username = "admin@EXAMPLE.onmicrosoft.com"
$tmpCred = Get-Credential
$tmpCred.Password | ConvertFrom-SecureString | Set-Content $credentialPath



# サインイン
# $username = "admin@EXAMPLE.onmicrosoft.com"
$password = Get-Content $credentialPath | ConvertTo-SecureString
$credential = New-Object System.Management.Automation.PsCredential $username, $password
$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $credential -Authentication Basic -AllowRedirection
Import-PSSession $session -DisableNameChecking

# サインインできたことを確認
Get-User $username | FL
