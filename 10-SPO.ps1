# Copyright (c) 2023 YA-androidapp(https://github.com/YA-androidapp) All rights reserved.


.".\02-Auth.ps1"


$filename = "fields.csv"
$siteUrl = "https://contoso.sharepoint.com/sites/contoso"
$tenantAdministrationSiteUrl = "https://contoso-admin.sharepoint.com/"
$listName = "Fabrikam"


# サインイン

# SharePoint Online 管理シェル

Connect-SPOService -Url $tenantAdministrationSiteUrl -credential $credential

Write-Host "ユーザー一覧"
Get-SPOUser -Site $siteUrl

Write-Host "サイト一覧"
Get-SPOSite -Limit ALL
# Get-SPOSite -Identity $siteUrl


# PnP PowerShell

Connect-PnPOnline -Url $siteUrl -Credentials $credential

Write-Host "ユーザー一覧"
# Get-PnPUser
Get-PnPUser | Where-Object Email -eq "admin@contoso.onmicrosoft.com"

Write-Host "サイト一覧"
Get-PnPWeb

Write-Host "リスト一覧"
Get-PnPList

Write-Host "列一覧"
Get-PnPField -List $listName | Select-Object Title, InternalName, TypeDisplayName, Required, MaxLength, Hidden | Export-Csv -NoTypeInformation $filename -Encoding UTF8
