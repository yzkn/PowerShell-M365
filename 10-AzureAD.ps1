# サインインできたことを確認
$Config = Get-Config
$username = $Config.USERNAME
(Get-AzureADUser -ObjectId $username) | Select-Object -Property Mail

# ユーザーを検索
Get-AzureADUser -SearchString "Admin"

Pause
