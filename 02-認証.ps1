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

Pause
