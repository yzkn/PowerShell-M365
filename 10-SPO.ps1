# Copyright (c) 2022 YA-androidapp(https://github.com/YA-androidapp) All rights reserved.


$filename = "fields.csv"
$siteUrl = "https://contoso.sharepoint.com/sites/ColumnsTestTeam"
$list = "LIST_NAME"


Connect-PnPOnline -Url $siteUrl

# サイト一覧
Get-PnPWeb

# リスト一覧
Get-PnPList

# 列一覧
Get-PnPField -List $list | Select-Object Title, InternalName, TypeDisplayName, Required, MaxLength, Hidden | Export-Csv -NoTypeInformation $filename -Encoding UTF8
