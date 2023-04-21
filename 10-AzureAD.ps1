.".\00-Util.ps1"


# サインイン
$Config = Get-Config
$credentialPath = $Config.CREDENTIAL_PATH
$username = $Config.USERNAME

$password = Get-Content $credentialPath | ConvertTo-SecureString
$credential = New-Object System.Management.Automation.PsCredential $username, $password
Connect-AzureAD -Credential $Credential

# サインインできたことを確認
$Config = Get-Config
$username = $Config.USERNAME
(Get-AzureADUser -ObjectId $username) | Select-Object -Property Mail

# ユーザーを検索
Get-AzureADUser -SearchString "Admin"

Pause
