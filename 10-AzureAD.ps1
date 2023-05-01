# Copyright (c) 2023 YA-androidapp(https://github.com/YA-androidapp) All rights reserved.


.".\02-Auth.ps1"


Write-Host "認証"
Connect-AzureAD -Credential $credential

# サインインできたことを確認
$Config = Get-Config
$username = $Config.USERNAME
(Get-AzureADUser -ObjectId $username) | Select-Object -Property Mail

Write-Host "ユーザーを検索"
Get-AzureADUser -SearchString "Admin"

Pause
